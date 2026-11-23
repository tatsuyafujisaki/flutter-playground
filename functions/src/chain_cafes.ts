import { defineSecret } from "firebase-functions/params";
import { HttpsError, onCall } from "firebase-functions/https";
import * as logger from "firebase-functions/logger";

const googlePlacesApiKey = defineSecret("GOOGLE_PLACES_API_KEY");

// Rejects calls without a valid App Check token when the ENFORCE_APP_CHECK
// environment variable is "true". Enable it only after the attestation
// providers (and debug tokens for debug builds) are registered in the Firebase
// console; otherwise every call is rejected.
function enforcesAppCheck(): boolean {
  return process.env["ENFORCE_APP_CHECK"] === "true";
}

const TEXT_SEARCH_URL = "https://places.googleapis.com/v1/places:searchText";
const SOLUTION_ID = "gmp_git_agentskills_v1";

// Includes Enterprise-tier `places.websiteUri` so that results can be filtered
// strictly by official chain domain.
const FIELD_MASK =
  "places.id,places.displayName,places.location,places.websiteUri," +
  "places.googleMapsUri";

const SEARCH_RADIUS_METERS = 500;
const PAGE_SIZE = 20;
const METERS_PER_DEGREE_LATITUDE = 111320;
const REQUEST_TIMEOUT_MILLISECONDS = 10000;
const LANGUAGE_CODE_REGEX = /^[A-Za-z]{2,3}(-[A-Za-z0-9]{2,8}){0,2}$/;

interface ChainCafe {
  // The Text Search query used to discover nearby locations of this chain.
  query: string;
  // Official website domains (exact host or subdomain) accepted for this chain.
  domains: string[];
}

const CHAIN_CAFES: ChainCafe[] = [
  { query: "Starbucks", domains: ["starbucks.co.jp", "starbucks.com"] },
  { query: "Doutor Coffee", domains: ["doutor.co.jp"] },
  { query: "Tully's Coffee", domains: ["tullys.co.jp"] },
  { query: "Komeda's Coffee", domains: ["komeda.co.jp"] },
  { query: "St. Marc Cafe", domains: ["saint-marc-hd.com"] },
  { query: "Excelsior Caffe", domains: ["doutor.co.jp"] },
  { query: "Caffe Veloce", domains: ["c-united.co.jp"] },
  { query: "Pronto", domains: ["pronto.co.jp"] },
];

interface SearchNearbyChainCafesRequest {
  latitude?: unknown;
  longitude?: unknown;
  languageCode?: unknown;
}

interface ChainCafePlace {
  id: string;
  name: string;
  latitude: number;
  longitude: number;
  websiteUri: string;
  googleMapsUri?: string;
}

interface SearchNearbyChainCafesResponse {
  places: ChainCafePlace[];
}

interface Viewport {
  low: { latitude: number; longitude: number };
  high: { latitude: number; longitude: number };
}

// The subset of the Places API (New) Place resource selected by FIELD_MASK.
interface Place {
  id?: string;
  displayName?: { text?: string };
  location?: { latitude?: number; longitude?: number };
  websiteUri?: string;
  googleMapsUri?: string;
}

/**
 * Returns whether websiteUri is an HTTP(S) URL whose host matches one of the
 * domains (exact match or subdomain).
 */
export function matchesWebsiteUri(
  domains: string[],
  websiteUri: string | undefined,
): boolean {
  if (!websiteUri || !URL.canParse(websiteUri)) {
    return false;
  }
  const url = new URL(websiteUri);
  if (url.protocol !== "http:" && url.protocol !== "https:") {
    return false;
  }
  const host = url.hostname.toLowerCase();
  return domains.some((domain) => {
    const normalized = domain.toLowerCase();
    return host === normalized || host.endsWith(`.${normalized}`);
  });
}

function clamp(value: number, min: number, max: number): number {
  return Math.min(Math.max(value, min), max);
}

function buildViewport(latitude: number, longitude: number): Viewport {
  const latitudeDelta = SEARCH_RADIUS_METERS / METERS_PER_DEGREE_LATITUDE;
  const cosLatitude = clamp(
    Math.abs(Math.cos((latitude * Math.PI) / 180)),
    1e-6,
    1,
  );
  const longitudeDelta =
    SEARCH_RADIUS_METERS / (METERS_PER_DEGREE_LATITUDE * cosLatitude);
  return {
    low: {
      latitude: clamp(latitude - latitudeDelta, -90, 90),
      longitude: clamp(longitude - longitudeDelta, -180, 180),
    },
    high: {
      latitude: clamp(latitude + latitudeDelta, -90, 90),
      longitude: clamp(longitude + longitudeDelta, -180, 180),
    },
  };
}

async function searchChainCafe(
  chain: ChainCafe,
  viewport: Viewport,
  languageCode: string | undefined,
  apiKey: string,
): Promise<ChainCafePlace[]> {
  const response = await fetch(TEXT_SEARCH_URL, {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      "X-Goog-Api-Key": apiKey,
      "X-Goog-FieldMask": FIELD_MASK,
      "X-Goog-Maps-Solution-ID": SOLUTION_ID,
    },
    body: JSON.stringify({
      textQuery: chain.query,
      includedType: "cafe",
      strictTypeFiltering: true,
      pageSize: PAGE_SIZE,
      locationRestriction: { rectangle: viewport },
      ...(languageCode === undefined ? {} : { languageCode }),
    }),
    signal: AbortSignal.timeout(REQUEST_TIMEOUT_MILLISECONDS),
  });
  if (!response.ok) {
    throw new Error(
      `Text Search for "${chain.query}" failed with HTTP ${response.status}: ` +
        (await response.text()),
    );
  }

  const body = (await response.json()) as { places?: Place[] };
  const cafes: ChainCafePlace[] = [];
  for (const place of body.places ?? []) {
    const latitude = place.location?.latitude;
    const longitude = place.location?.longitude;
    if (
      !place.id ||
      !place.websiteUri ||
      latitude === undefined ||
      longitude === undefined ||
      !matchesWebsiteUri(chain.domains, place.websiteUri)
    ) {
      continue;
    }
    cafes.push({
      id: place.id,
      name: place.displayName?.text ?? chain.query,
      latitude,
      longitude,
      websiteUri: place.websiteUri,
      ...(place.googleMapsUri ? { googleMapsUri: place.googleMapsUri } : {}),
    });
  }
  return cafes;
}

function isCoordinate(value: unknown, limit: number): value is number {
  return (
    typeof value === "number" && Number.isFinite(value) && Math.abs(value) <= limit
  );
}

export const searchNearbyChainCafes = onCall<
  SearchNearbyChainCafesRequest,
  Promise<SearchNearbyChainCafesResponse>
>(
  {
    region: "asia-northeast1",
    secrets: [googlePlacesApiKey],
  },
  async (request) => {
    if (!request.auth) {
      throw new HttpsError(
        "unauthenticated",
        "Authentication is required to search for chain cafes.",
      );
    }

    // `request.app` is set only when the App Check token was verified.
    if (enforcesAppCheck() && !request.app) {
      throw new HttpsError(
        "failed-precondition",
        "A valid App Check token is required to search for chain cafes.",
      );
    }

    const latitude = request.data?.latitude;
    const longitude = request.data?.longitude;
    if (!isCoordinate(latitude, 90) || !isCoordinate(longitude, 180)) {
      throw new HttpsError(
        "invalid-argument",
        "latitude must be within [-90, 90] and longitude within [-180, 180].",
      );
    }

    const languageCode = request.data?.languageCode ?? undefined;
    if (
      languageCode !== undefined &&
      (typeof languageCode !== "string" ||
        !LANGUAGE_CODE_REGEX.test(languageCode))
    ) {
      throw new HttpsError(
        "invalid-argument",
        "languageCode must be a BCP 47 language tag.",
      );
    }

    const apiKey = googlePlacesApiKey.value().trim();
    if (!apiKey) {
      throw new HttpsError(
        "failed-precondition",
        "The GOOGLE_PLACES_API_KEY secret must be configured.",
      );
    }

    const viewport = buildViewport(latitude, longitude);
    let results: ChainCafePlace[][];
    try {
      results = await Promise.all(
        CHAIN_CAFES.map((chain) =>
          searchChainCafe(chain, viewport, languageCode, apiKey),
        ),
      );
    } catch (error) {
      // Logs the upstream error but hides it from the client.
      logger.error("Places API Text Search failed", error);
      throw new HttpsError("unavailable", "Failed to search for chain cafes.");
    }

    const deduplicated = new Map<string, ChainCafePlace>();
    for (const place of results.flat()) {
      if (!deduplicated.has(place.id)) {
        deduplicated.set(place.id, place);
      }
    }
    return { places: [...deduplicated.values()] };
  },
);
