package com.aryanrawat.rep_tracker

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent

/**
 * The notification's toggle button. Reads/flips [TriggerToggleState],
 * appends the matching event via [TriggerJournal] — never opens the app
 * (§7's start/end asymmetry is deferred until a rep-entry screen exists to
 * open into, see ADR-004 / milestone 02 plan). `MORE` is a separate
 * `PendingIntent.getActivity` on the notification itself, not routed here.
 */
class TriggerActionReceiver : BroadcastReceiver() {
    companion object {
        const val ACTION_TOGGLE = "com.aryanrawat.rep_tracker.action.TOGGLE"
    }

    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action != ACTION_TOGGLE) return

        TriggerToggleState.toggle(context)

        if (TriggerForegroundService.isRunning) {
            context.startForegroundService(
                Intent(context, TriggerForegroundService::class.java)
                    .setAction(TriggerForegroundService.ACTION_REFRESH),
            )
        }
    }
}
