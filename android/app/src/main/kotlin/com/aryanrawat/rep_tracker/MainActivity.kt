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
        requestNotificationPermissionIfNeeded()
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

    /** No settings screen exists yet to prompt this from — ask once at
     * launch, same as any Android 13+ app must. */
    private fun requestNotificationPermissionIfNeeded() {
        if (ContextCompat.checkSelfPermission(this, Manifest.permission.POST_NOTIFICATIONS) !=
            PackageManager.PERMISSION_GRANTED
        ) {
            ActivityCompat.requestPermissions(this, arrayOf(Manifest.permission.POST_NOTIFICATIONS), 0)
        }
    }
}
