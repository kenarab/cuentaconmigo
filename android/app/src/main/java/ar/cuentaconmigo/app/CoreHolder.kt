package ar.cuentaconmigo.app

import android.content.Context
import org.json.JSONObject
import uniffi.cc_core.Core
import uniffi.cc_core.SecretStore

/**
 * Single instance of the shared Rust core (core/, sdd/specs/shared-core). The app only
 * draws screens and reaches hardware; every rule lives in the core.
 */
object CoreHolder {
    @Volatile private var core: Core? = null

    fun get(context: Context): Core = core ?: synchronized(this) {
        core ?: Core(
            dataDir = context.filesDir.absolutePath,
            platform = "android",
            appVersion = BuildConfig.VERSION_NAME,
            defaultServerUrl = BuildConfig.DEFAULT_SERVER_URL,
            appEnrollCode = BuildConfig.APP_ENROLL_CODE.ifEmpty { null },
            secrets = PreferencesSecretStore(context.applicationContext),
        ).also { core = it }
    }
}

/** Device token and server URL in app-private preferences (sandboxed, never backed up). */
private class PreferencesSecretStore(context: Context) : SecretStore {
    private val prefs = context.getSharedPreferences("secrets", Context.MODE_PRIVATE)
    override fun get(key: String): String? = prefs.getString(key, null)
    override fun set(key: String, value: String?) {
        prefs.edit().apply { if (value == null) remove(key) else putString(key, value) }.apply()
    }
}

/** Official sample telegrams copied at build time from data/ocr-samples (git-ignored). */
data class Sample(val id: String, val label: String, val file: String, val election: String,
                  val distrito: String, val seccion: String, val circuito: String, val mesa: String)

fun loadSamples(context: Context): List<Sample> = runCatching {
    val json = JSONObject(context.assets.open("samples/samples.json").bufferedReader().readText())
    val list = json.getJSONArray("samples")
    (0 until list.length()).map { i ->
        val s = list.getJSONObject(i)
        val m = s.getJSONObject("mesa")
        Sample(s.getString("id"), s.getString("label"), s.getString("file"), s.optString("election"),
            m.getString("distrito"), m.getString("seccion"), m.getString("circuito"), m.getString("mesa"))
    }
}.getOrDefault(emptyList())

/** Template of the sample's election, so the server aligns the right form. */
fun Sample.templateId(): String? = when (election) {
    "balotaje-2015" -> "balotaje-2015"
    else -> null
}
