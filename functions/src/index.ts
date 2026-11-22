import { defineSecret } from "firebase-functions/params";
import { HttpsError, onCall } from "firebase-functions/https";
import { AccessToken } from "livekit-server-sdk";

const livekitUrl = defineSecret("LIVEKIT_URL");
const livekitApiKey = defineSecret("LIVEKIT_API_KEY");
const livekitApiSecret = defineSecret("LIVEKIT_API_SECRET");

const TOKEN_EXPIRATION_SECONDS = 3600;
const ROOM_NAME_REGEX = /^[a-zA-Z0-9._-]{1,128}$/;

interface GenerateLiveKitTokenRequest {
  roomName?: unknown;
  role?: unknown;
}

interface GenerateLiveKitTokenResponse {
  url: string;
  roomName: string;
  token: string;
  identity: string;
  expiresAt: number;
}

export const generateLiveKitToken = onCall<
  GenerateLiveKitTokenRequest,
  Promise<GenerateLiveKitTokenResponse>
>(
  {
    region: "asia-northeast1",
    secrets: [livekitUrl, livekitApiKey, livekitApiSecret],
  },
  async (request) => {
    if (!request.auth) {
      throw new HttpsError(
        "unauthenticated",
        "Authentication is required to generate a LiveKit token.",
      );
    }

    const rawRoomName = request.data?.roomName;
    if (typeof rawRoomName !== "string") {
      throw new HttpsError(
        "invalid-argument",
        "roomName must be a non-empty string.",
      );
    }

    const roomName = rawRoomName.trim();
    if (!ROOM_NAME_REGEX.test(roomName)) {
      throw new HttpsError(
        "invalid-argument",
        "roomName must be 1-128 characters using letters, numbers, '.', '_', or '-'.",
      );
    }

    const rawRole = request.data?.role ?? "publisher";
    if (rawRole !== "publisher" && rawRole !== "subscriber") {
      throw new HttpsError(
        "invalid-argument",
        "role must be either 'publisher' or 'subscriber'.",
      );
    }

    const url = livekitUrl.value().trim();
    const apiKey = livekitApiKey.value().trim();
    const apiSecret = livekitApiSecret.value().trim();
    if (!url || !apiKey || !apiSecret) {
      throw new HttpsError(
        "failed-precondition",
        "LIVEKIT_URL, LIVEKIT_API_KEY, and LIVEKIT_API_SECRET secrets must be configured.",
      );
    }

    const identity = request.auth.uid;
    const accessToken = new AccessToken(apiKey, apiSecret, {
      identity,
      ttl: TOKEN_EXPIRATION_SECONDS,
    });
    accessToken.addGrant({
      roomJoin: true,
      room: roomName,
      canPublish: rawRole !== "subscriber",
      canSubscribe: true,
      canPublishData: true,
    });

    const token = await accessToken.toJwt();
    const expiresAt =
      Math.floor(Date.now() / 1000) + TOKEN_EXPIRATION_SECONDS;

    return {
      url,
      roomName,
      token,
      identity,
      expiresAt,
    };
  },
);
