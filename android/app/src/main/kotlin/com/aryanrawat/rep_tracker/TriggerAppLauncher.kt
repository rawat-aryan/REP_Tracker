package com.aryanrawat.rep_tracker

import android.content.Context
import android.content.Intent

/**
 * Milestone 06 "must hold": `setEnded` brings the app forward, landing on
 * rep entry for that set. Which set/exercise is resolved entirely on the
 * Dart side by draining `events.jsonl` on resume (§7) — this just launches
 * the activity, from whichever native surface (notification action or QS
 * tile) flipped the toggle to "ended".
 */
object TriggerAppLauncher {
    fun bringForward(context: Context) {
        context.startActivity(
            Intent(context, MainActivity::class.java)
                .addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_REORDER_TO_FRONT),
        )
    }
}
