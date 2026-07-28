package com.noveno.vault

import android.app.AppOpsManager
import android.content.Context
import android.content.pm.ApplicationInfo
import android.os.Build
import android.os.Bundle
import android.provider.Settings
import android.view.WindowManager
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterFragmentActivity() {
    private val CHANNEL = "vault/device_integrity"

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        // 🔒 1. BLOQUEO DE CAPTURAS Y GRABACIÓN DE PANTALLA
        window.addFlags(WindowManager.LayoutParams.FLAG_SECURE)
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "isFakeGpsEnabled" -> result.success(isFakeGpsEnabled())
                "isUsbDebuggingEnabled" -> result.success(isUsbDebuggingEnabled())
                // 🛡️ El dispositivo solo es seguro si NO hay Fake GPS y NO hay depuración USB activa
                "isDeviceSafe" -> result.success(!isFakeGpsEnabled() && !isUsbDebuggingEnabled())
                else -> result.notImplemented()
            }
        }
    }

    // 🔌 DETECCIÓN ROBUSTA DE DEPURACIÓN USB (ADB)
    private fun isUsbDebuggingEnabled(): Boolean {
        return try {
            // 1. Estado global de depuración USB
            val adbGlobal = Settings.Global.getInt(
                contentResolver,
                Settings.Global.ADB_ENABLED,
                0
            ) != 0

            // 2. Estado seguro (Fallback para capas personalizadas de fabricantes)
            val adbSecure = Settings.Secure.getInt(
                contentResolver,
                Settings.Global.ADB_ENABLED,
                0
            ) != 0

            // 3. Depuración inalámbrica por Wi-Fi (Android 11+)
            val adbWifi = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
                Settings.Global.getInt(
                    contentResolver,
                    "adb_wifi_enabled",
                    0
                ) != 0
            } else false

            // 4. Conexión activa de debugger
            val isDebuggerAttached = android.os.Debug.isDebuggerConnected()

            adbGlobal || adbSecure || adbWifi || isDebuggerAttached
        } catch (_: Exception) {
            false
        }
    }

    // 📍 DETECCIÓN DE FAKE GPS
    @Suppress("DEPRECATION")
    private fun isFakeGpsEnabled(): Boolean {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.M) {
            val mockLocation = Settings.Secure.getString(contentResolver, Settings.Secure.ALLOW_MOCK_LOCATION)
            return !mockLocation.isNullOrEmpty() && mockLocation != "0"
        }

        val appOpsManager = getSystemService(Context.APP_OPS_SERVICE) as? AppOpsManager ?: return false

        return try {
            packageManager.getInstalledApplications(0).any { application ->
                if (application.packageName == packageName) {
                    return@any false
                }

                val isSystemApp = (application.flags and ApplicationInfo.FLAG_SYSTEM) != 0 ||
                        (application.flags and ApplicationInfo.FLAG_UPDATED_SYSTEM_APP) != 0
                if (isSystemApp) {
                    return@any false
                }

                val mode = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                    appOpsManager.unsafeCheckOpNoThrow(
                        AppOpsManager.OPSTR_MOCK_LOCATION,
                        application.uid,
                        application.packageName
                    )
                } else {
                    appOpsManager.checkOpNoThrow(
                        AppOpsManager.OPSTR_MOCK_LOCATION,
                        application.uid,
                        application.packageName
                    )
                }

                mode == AppOpsManager.MODE_ALLOWED
            }
        } catch (_: Exception) {
            false
        }
    }
}