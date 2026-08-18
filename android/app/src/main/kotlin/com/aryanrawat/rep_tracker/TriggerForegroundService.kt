package com.aryanrawat.rep_tracker

import android.Manifest
import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.Intent
import android.content.pm.PackageManager
import android.content.pm.ServiceInfo
import android.os.IBinder
import androidx.core.app.NotificationCompat
import androidx.core.app.ServiceCompat
import androidx.core.content.ContextCompat

/**
 * Tier 0 ambient surface (§16). Ongoing notification with the toggle action
 * plus MORE (opens the app). foregroundServiceType="health" — the honest fit
 * for a workout timer per the milestone doc; Play review will ask about it.
 *
 * Started/stopped only from Dart via the `rep_tracker/trigger` MethodChannel
 * ([MainActivity]). Refreshed by [TriggerActionReceiver] / the QS tile after
 * a toggle, so the notification's label always matches
 * [TriggerToggleState].
 */
class TriggerForegroundService : Service() {
    companion object {
        const val CHANNEL_ID = "trigger_ambient"
        const val NOTIFICATION_ID = 1
        const val ACTION_REFRESH = "com.aryanrawat.rep_tracker.action.REFRESH"
        const val ACTION_STOP = "com.aryanrawat.rep_tracker.action.STOP"

        /** Whether the service is alive — guards against starting it just to
         * refresh a notification that was never shown (e.g. a QS tile press
         * before any session exists). */
        @Volatile
        var isRunning = false
            private set
    }

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onCreate() {
        super.onCreate()
        isRunning = true
        createChannel()
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        if (intent?.action == ACTION_STOP) {
            stopSelf()
            return START_NOT_STICKY
        }
        // The OS additionally requires ACTIVITY_RECOGNITION (or another
        // health-adjacent permission) to be *granted*, not just declared,
        // before it will let a "health"-typed FGS start — see the manifest
        // comment. Denied/not-yet-answered must degrade to the dataSync
        // fallback type (also declared on the service), never crash the
        // app — a permission the user hasn't granted yet is an ordinary
        // runtime condition, not a bug. "type none" is not itself a legal
        // fallback: the OS rejects starting with no type at all once the
        // manifest declares specific types.
        val canUseHealthType = ContextCompat.checkSelfPermission(
            this,
            Manifest.permission.ACTIVITY_RECOGNITION,
        ) == PackageManager.PERMISSION_GRANTED
        ServiceCompat.startForeground(
            this,
            NOTIFICATION_ID,
            buildNotification(),
            if (canUseHealthType) {
                ServiceInfo.FOREGROUND_SERVICE_TYPE_HEALTH
            } else {
                ServiceInfo.FOREGROUND_SERVICE_TYPE_DATA_SYNC
            },
        )
        return START_STICKY
    }

    override fun onDestroy() {
        isRunning = false
        TriggerToggleState.reset()
        super.onDestroy()
    }

    private fun buildNotification(): Notification {
        val (title, subtitle) = TriggerJournal.display(this)
        val running = TriggerToggleState.isRunning(this)

        val togglePendingIntent = PendingIntent.getBroadcast(
            this,
            0,
            Intent(this, TriggerActionReceiver::class.java).setAction(TriggerActionReceiver.ACTION_TOGGLE),
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )
        val morePendingIntent = PendingIntent.getActivity(
            this,
            1,
            Intent(this, MainActivity::class.java),
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )

        return NotificationCompat.Builder(this, CHANNEL_ID)
            .setSmallIcon(R.mipmap.ic_launcher)
            .setContentTitle(title)
            .setContentText(subtitle)
            .setOngoing(true)
            .setOnlyAlertOnce(true)
            .setPriority(NotificationCompat.PRIORITY_LOW)
            .addAction(0, if (running) "END SET" else "START SET", togglePendingIntent)
            .addAction(0, "MORE", morePendingIntent)
            .build()
    }

    private fun createChannel() {
        val manager = getSystemService(NotificationManager::class.java)
        val channel = NotificationChannel(
            CHANNEL_ID,
            "Workout tracker",
            NotificationManager.IMPORTANCE_LOW,
        )
        manager.createNotificationChannel(channel)
    }
}
