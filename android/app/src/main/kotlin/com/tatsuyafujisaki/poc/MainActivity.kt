package com.tatsuyafujisaki.poc

import android.content.pm.PackageManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.security.MessageDigest

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL,
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "getSigningCertSha1" -> result.success(getSigningCertSha1())
                else -> result.notImplemented()
            }
        }
    }

    private fun getSigningCertSha1(): String? {
        val packageInfo = packageManager.getPackageInfo(
            packageName,
            PackageManager.PackageInfoFlags.of(PackageManager.GET_SIGNING_CERTIFICATES.toLong()),
        )
        val signature = packageInfo.signingInfo?.apkContentsSigners?.firstOrNull() ?: return null
        val digest = MessageDigest.getInstance("SHA-1").digest(signature.toByteArray())
        return digest.joinToString("") { "%02X".format(it) }
    }

    private companion object {
        const val CHANNEL = "com.tatsuyafujisaki.poc/signing"
    }
}
