import agoraToken from "agora-token";
import { defineSecret } from "firebase-functions/params";
import { HttpsError, onCall } from "firebase-functions/v2/https";

const { RtcRole, RtcTokenBuilder } = agoraToken;

const agoraAppId = defineSecret("AGORA_APP_ID");
const agoraAppCertificate = defineSecret("AGORA_APP_CERTIFICATE");

const TOKEN_EXPIRATION_SECONDS = 3600;
const CHANNEL_NAME_REGEX = /^[a-zA-Z0-9 !#$%&()+\-:;<=.>?@[\]^_{}|~,]{1,64}$/;

interface GenerateAgoraTokenRequest {
  channelName?: unknown;
  uid?: unknown;
  role?: unknown;
}

interface GenerateAgoraTokenResponse {
  appId: string;
  channelName: string;
  token: string;
  uid: number;
  expiresAt: number;
}

export const generateAgoraToken = onCall<
  GenerateAgoraTokenRequest,
  GenerateAgoraTokenResponse
>(
  {
    region: "asia-northeast1",
    secrets: [agoraAppId, agoraAppCertificate],
  },
  (request) => {
    if (!request.auth) {
      throw new HttpsError(
        "unauthenticated",
        "Authentication is required to generate an Agora token.",
      );
    }

    const rawChannelName = request.data?.channelName;
    if (typeof rawChannelName !== "string") {
      throw new HttpsError(
        "invalid-argument",
        "channelName must be a non-empty string.",
      );
    }

    const channelName = rawChannelName.trim();
    if (!CHANNEL_NAME_REGEX.test(channelName)) {
      throw new HttpsError(
        "invalid-argument",
        "channelName must be 1-64 valid Agora channel characters.",
      );
    }

    const rawUid = request.data?.uid ?? 0;
    if (
      typeof rawUid !== "number" ||
      !Number.isInteger(rawUid) ||
      rawUid < 0 ||
      rawUid > 0xffffffff
    ) {
      throw new HttpsError(
        "invalid-argument",
        "uid must be an integer between 0 and 4294967295.",
      );
    }

    const rawRole = request.data?.role ?? "publisher";
    if (rawRole !== "publisher" && rawRole !== "subscriber") {
      throw new HttpsError(
        "invalid-argument",
        "role must be either 'publisher' or 'subscriber'.",
      );
    }

    const appId = agoraAppId.value().trim();
    const appCertificate = agoraAppCertificate.value().trim();
    if (!appId || !appCertificate) {
      throw new HttpsError(
        "failed-precondition",
        "AGORA_APP_ID and AGORA_APP_CERTIFICATE secrets must be configured.",
      );
    }

    const role =
      rawRole === "subscriber" ? RtcRole.SUBSCRIBER : RtcRole.PUBLISHER;

    const token = RtcTokenBuilder.buildTokenWithUid(
      appId,
      appCertificate,
      channelName,
      rawUid,
      role,
      TOKEN_EXPIRATION_SECONDS,
      TOKEN_EXPIRATION_SECONDS,
    );

    const expiresAt =
      Math.floor(Date.now() / 1000) + TOKEN_EXPIRATION_SECONDS;

    return {
      appId,
      channelName,
      token,
      uid: rawUid,
      expiresAt,
    };
  },
);
