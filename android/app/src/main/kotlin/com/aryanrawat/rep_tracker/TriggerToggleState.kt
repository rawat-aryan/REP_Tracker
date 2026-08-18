package com.aryanrawat.rep_tracker

import android.content.Context

/**
 * The one piece of state this milestone deliberately holds outside the
 * file contract — see ADR-004. In-memory only, never written to
 * context.json (Dart-only writer, I6), never survives the process dying.
 * Seeded once from context.json's `activeSet` so an OS-respawned service
 * still starts from the right side of the toggle.
 */
object TriggerToggleState {
    private var initialized = false
    private var running = false

    @Synchronized
    fun isRunning(context: Context): Boolean {
        seedIfNeeded(context)
        return running
    }

    /** Flips the toggle, appends the matching event, returns the new state. */
    @Synchronized
    fun toggle(context: Context): Boolean {
        seedIfNeeded(context)
        running = !running
        TriggerJournal.appendEvent(context, if (running) "setStarted" else "setEnded")
        return running
    }

    @Synchronized
    fun reset() {
        initialized = false
        running = false
    }

    private fun seedIfNeeded(context: Context) {
        if (initialized) return
        running = TriggerJournal.contextSaysActive(context)
        initialized = true
    }
}
