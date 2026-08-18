package com.aryanrawat.rep_tracker

import android.content.Intent
import android.service.quicksettings.Tile
import android.service.quicksettings.TileService

/** Tier 1 parity layer (§16). Same toggle as the notification, reachable
 * from Quick Settings on any screen including locked. */
class TriggerQsTileService : TileService() {
    override fun onStartListening() {
        super.onStartListening()
        refreshTileState()
    }

    override fun onClick() {
        super.onClick()
        TriggerToggleState.toggle(this)
        if (TriggerForegroundService.isRunning) {
            startForegroundService(
                Intent(this, TriggerForegroundService::class.java)
                    .setAction(TriggerForegroundService.ACTION_REFRESH),
            )
        }
        refreshTileState()
    }

    private fun refreshTileState() {
        val tile = qsTile ?: return
        val running = TriggerToggleState.isRunning(this)
        tile.state = if (running) Tile.STATE_ACTIVE else Tile.STATE_INACTIVE
        tile.label = if (running) "End set" else "Start set"
        tile.updateTile()
    }
}
