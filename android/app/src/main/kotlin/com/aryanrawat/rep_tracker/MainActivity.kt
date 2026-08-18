package com.aryanrawat.rep_tracker

import android.Manifest
import android.content.Intent
import android.content.pm.PackageManager
import android.os.Bundle
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

/**
 * Dart's only entry point into the native trigger layer (`AndroidTriggerBridge`).
 * File I/O (`context.json`/`events.jsonl`) never crosses this channel — Dart
 * writes/reads those directly at the same path Kotlin uses (§7). This
 * channel only drives the foreground service lifecycle and reports which
 * trigger tiers this build supports.
 */
class MainActivity : FlutterActivity() {
    private val channelName = "rep_tracker/trigger"

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        requestTriggerPermissionsIfNeeded()
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "startAmbientSurface", "updateAmbientSurface" -> {
                        startForegroundService(Intent(this, TriggerForegroundService::class.java))
                        result.success(null)
                    }
                    "stopAmbientSurface" -> {
                        startService(
                            Intent(this, TriggerForegroundService::class.java)
                                .setAction(TriggerForegroundService.ACTION_STOP),
                        )
                        result.success(null)
                    }
                    "availableTiers" -> result.success(listOf("ambientCard", "parityTile"))
                    else -> result.notImplemented()
                }
            }
    }

    /** No settings screen exists yet to prompt these from — ask once at
     * launch. Both requested in one call: firing `requestPermissions`
     * twice back-to-back in `onCreate` lets the second call silently
     * supersede the first before its dialog ever shows. POST_NOTIFICATIONS
     * is the standard Android 13+ ask; ACTIVITY_RECOGNITION is required for
     * `foregroundServiceType="health"` to be allowed to start at all on
     * this SDK — see the manifest comment. */
    private fun requestTriggerPermissionsIfNeeded() {
        val needed = listOf(
            Manifest.permission.POST_NOTIFICATIONS,
            Manifest.permission.ACTIVITY_RECOGNITION,
        ).filter {
            ContextCompat.checkSelfPermission(this, it) != PackageManager.PERMISSION_GRANTED
        }
        if (needed.isNotEmpty()) {
            ActivityCompat.requestPermissions(this, needed.toTypedArray(), 0)
        }
    }
}
