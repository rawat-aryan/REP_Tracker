package com.aryanrawat.rep_tracker

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent

/**
 * The notification's toggle button. Reads/flips [TriggerToggleState],
 * appends the matching event via [TriggerJournal]. `MORE` is a separate
 * `PendingIntent.getActivity` on the notification itself, not routed here.
 *
 * Milestone 06: a press that just appended `setEnded` (the rep-entry screen
 * now exists, so §7's start/end asymmetry is no longer deferred — see
 * [TriggerAppLauncher]) brings the app forward.
 */
class TriggerActionReceiver : BroadcastReceiver() {
    companion object {
        const val ACTION_TOGGLE = "com.aryanrawat.rep_tracker.action.TOGGLE"
    }

    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action != ACTION_TOGGLE) return

        val runningNow = TriggerToggleState.toggle(context)

        if (TriggerForegroundService.isRunning) {
            context.startForegroundService(
                Intent(context, TriggerForegroundService::class.java)
                    .setAction(TriggerForegroundService.ACTION_REFRESH),
            )
        }

        if (!runningNow) TriggerAppLauncher.bringForward(context)
    }
}
