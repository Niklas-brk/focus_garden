package com.focusgarden.focus_garden

import android.app.WallpaperManager
import android.content.Context
import android.content.Intent
import android.graphics.BitmapFactory
import android.graphics.PixelFormat
import android.net.Uri
import android.os.Build
import android.provider.Settings
import android.view.Gravity
import android.view.LayoutInflater
import android.view.View
import android.view.WindowManager
import android.widget.Button
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

/**
 * Native Umsetzung des „Fokus-Schilds": ein Vollbild-Overlay, das sich im
 * Lernmodus ueber andere Apps legt (WindowManager + SYSTEM_ALERT_WINDOW). Wird
 * ueber den MethodChannel `focus_garden/blocker` von Flutter gesteuert.
 */
class MainActivity : FlutterActivity() {
    private val channelName = "focus_garden/blocker"
    private val wallpaperChannelName = "focus_garden/wallpaper"
    private var methodChannel: MethodChannel? = null
    private var overlayView: View? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        val ch = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
        methodChannel = ch
        ch.setMethodCallHandler { call, result ->
            when (call.method) {
                "hasPermission" -> result.success(Settings.canDrawOverlays(this))
                "requestPermission" -> {
                    if (Settings.canDrawOverlays(this)) {
                        result.success(true)
                    } else {
                        val intent = Intent(
                            Settings.ACTION_MANAGE_OVERLAY_PERMISSION,
                            Uri.parse("package:$packageName")
                        ).addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                        startActivity(intent)
                        result.success(false)
                    }
                }
                "showShield" -> { showShield(); result.success(true) }
                "hideShield" -> { hideShield(); result.success(true) }
                "bringToForeground" -> { bringToForeground(); result.success(true) }
                else -> result.notImplemented()
            }
        }

        // Garten-Szene als Handy-Hintergrund (Phase 3).
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, wallpaperChannelName)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "setWallpaper" -> result.success(setWallpaper(call.argument<String>("path")))
                    else -> result.notImplemented()
                }
            }
    }

    /** Legt das PNG unter [path] als Start- und Sperrbildschirm-Hintergrund fest. */
    private fun setWallpaper(path: String?): Boolean {
        if (path == null) return false
        return try {
            val bitmap = BitmapFactory.decodeFile(path) ?: return false
            val wm = WallpaperManager.getInstance(this)
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
                wm.setBitmap(
                    bitmap, null, true,
                    WallpaperManager.FLAG_SYSTEM or WallpaperManager.FLAG_LOCK
                )
            } else {
                @Suppress("DEPRECATION")
                wm.setBitmap(bitmap)
            }
            true
        } catch (_: Exception) {
            false
        }
    }

    private fun bringToForeground() {
        val intent = packageManager.getLaunchIntentForPackage(packageName)
        intent?.addFlags(
            Intent.FLAG_ACTIVITY_NEW_TASK or
                Intent.FLAG_ACTIVITY_REORDER_TO_FRONT or
                Intent.FLAG_ACTIVITY_SINGLE_TOP
        )
        startActivity(intent)
    }

    private fun showShield() {
        if (overlayView != null) return
        if (!Settings.canDrawOverlays(this)) return

        val view = LayoutInflater.from(this).inflate(R.layout.focus_shield_overlay, null)

        view.findViewById<Button>(R.id.shield_resume).setOnClickListener {
            hideShield()
            bringToForeground()
        }

        // Notfall-Abbruch mit einfacher Zwei-Tipp-Bestaetigung.
        val abortBtn = view.findViewById<Button>(R.id.shield_abort)
        var armed = false
        abortBtn.setOnClickListener {
            if (!armed) {
                armed = true
                abortBtn.text = "Wirklich abbrechen? 🥀"
            } else {
                hideShield()
                methodChannel?.invokeMethod("onAbort", null)
            }
        }

        val type = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY
        } else {
            @Suppress("DEPRECATION")
            WindowManager.LayoutParams.TYPE_PHONE
        }
        val params = WindowManager.LayoutParams(
            WindowManager.LayoutParams.MATCH_PARENT,
            WindowManager.LayoutParams.MATCH_PARENT,
            type,
            // Nicht fokussierbar: reisst Zurueck-/Tastatur-Fokus nicht an sich,
            // deckt aber als Vollbild alle Beruehrungen ab und blockiert so.
            WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE,
            PixelFormat.TRANSLUCENT
        )
        params.gravity = Gravity.CENTER

        val wm = applicationContext.getSystemService(Context.WINDOW_SERVICE) as WindowManager
        try {
            wm.addView(view, params)
            overlayView = view
        } catch (_: Exception) {
            overlayView = null
        }
    }

    private fun hideShield() {
        val view = overlayView ?: return
        overlayView = null
        val wm = applicationContext.getSystemService(Context.WINDOW_SERVICE) as WindowManager
        try {
            wm.removeView(view)
        } catch (_: Exception) {
        }
    }

    override fun onDestroy() {
        hideShield()
        super.onDestroy()
    }
}
