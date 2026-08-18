package com.aryanrawat.rep_tracker

import android.content.Context
import java.io.File
import java.time.Instant
import java.util.UUID
import org.json.JSONObject

/**
 * Native half of the §7 trigger contract. Reads context.json (Dart-written,
 * native-read-only — never write it from here, that would make two writers).
 * Appends events.jsonl (native-written, Dart-drained).
 *
 * Both files live in `context.filesDir` — the same path
 * `getApplicationDocumentsPath()` resolves to on Android, so Dart's
 * [AndroidTriggerBridge] and this object agree on where the files are
 * without any channel call.
 */
object TriggerJournal {
    private fun contextFile(context: Context) = File(context.filesDir, "context.json")
    private fun eventsFile(context: Context) = File(context.filesDir, "events.jsonl")

    /** Current session id from context.json, or "" if none has been written yet. */
    fun currentSessionId(context: Context): String {
        val file = contextFile(context)
        if (!file.exists()) return ""
        return runCatching { JSONObject(file.readText()).optString("sessionId", "") }
            .getOrDefault("")
    }

    /** Notification title/subtitle straight from what Dart last wrote. Falls
     * back to something inert if context.json is missing or malformed —
     * never crash the service over a display string. */
    fun display(context: Context): Pair<String, String> {
        val file = contextFile(context)
        if (!file.exists()) return "REP Tracker" to "No active session"
        return runCatching {
            val json = JSONObject(file.readText())
            val exerciseName = json.optJSONObject("currentExercise")
                ?.optString("name", "Workout") ?: "Workout"
            val setIndex = json.optInt("nextSetIndex", 1)
            exerciseName to "Set $setIndex"
        }.getOrDefault("REP Tracker" to "No active session")
    }

    /**
     * context.json's own notion of whether a set is running. Used only to
     * seed the in-memory toggle (ADR-004) when the service starts — never
     * consulted per-press, since the app never rewrites this file while
     * it's dead.
     */
    fun contextSaysActive(context: Context): Boolean {
        val file = contextFile(context)
        if (!file.exists()) return false
        return runCatching { !JSONObject(file.readText()).isNull("activeSet") }
            .getOrDefault(false)
    }

    /** Appends one line the way §7 defines it. Synchronized: the notification
     * action and the QS tile can both call this. */
    @Synchronized
    fun appendEvent(context: Context, type: String) {
        val event = JSONObject()
            .put("id", UUID.randomUUID().toString())
            .put("type", type)
            .put("at", Instant.now().toString())
            .put("sessionId", currentSessionId(context))
        eventsFile(context).appendText(event.toString() + "\n")
    }
}
