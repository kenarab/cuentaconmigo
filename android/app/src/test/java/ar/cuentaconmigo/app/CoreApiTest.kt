package ar.cuentaconmigo.app

import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertTrue
import org.junit.Assert.fail
import org.junit.Test
import uniffi.cc_core.Core
import uniffi.cc_core.CoreException
import uniffi.cc_core.MesaRecord
import uniffi.cc_core.SecretStore
import java.io.File
import java.nio.file.Files

/** Exercises the shared core through the generated Kotlin bindings, like the app does. */
class CoreApiTest {
    private class MemorySecrets : SecretStore {
        val map = mutableMapOf<String, String>()
        override fun get(key: String) = map[key]
        override fun set(key: String, value: String?) { if (value == null) map.remove(key) else map[key] = value }
    }

    private fun core(server: String? = null) = Core(
        Files.createTempDirectory("cc-core").toString(), "android-test", "0", server, "0000", MemorySecrets())

    @Test
    fun captureLifecycleAndRules() {
        val core = core()
        val template = core.template(null)
        assertEquals("generales-2023", template.id)
        val id = core.newCapture("telegrama", null)
        core.setMesa(id, MesaRecord("01", "001", "00001", "00001"))
        core.setValue(id, "header.votantes", 10L, false)
        template.categories.forEach { cat -> template.rows.forEach { r -> core.setValue(id, "cells.${cat.id}.${r.id}", if (r.id == "blanco") 10L else 0L, false) } }
        val detail = core.capture(id)
        assertTrue(detail.issues.none { it.isError && !it.path.startsWith("mesa") })
        try { core.confirm(id, null); fail("confirm needs at least one image") } catch (e: CoreException) {
            assertTrue(e.message!!.contains("imagen"))
        }
        core.addPage(id, byteArrayOf(0xFF.toByte(), 0xD8.toByte(), 0xFF.toByte()), "photos")
        core.confirm(id, null)
        assertTrue(core.capture(id).summary.locked)
        try { core.setValue(id, "header.votantes", 1L, false); fail("locked") } catch (e: CoreException) { }
        assertEquals(1, core.listCaptures().size)
        core.deleteCapture(id) // confirmed but never sent: still deletable
        assertTrue(core.listCaptures().isEmpty())
    }

    @Test
    fun pollingPlaces() {
        val core = core()
        assertEquals(24, core.districts().size)
        val section = core.sections("01").first().id
        val place = core.places("01", section, "").first()
        val table = place.tables.first().mesa
        assertEquals(place.codigo, core.locate("01", section, table)?.codigo)
    }

    @Test
    fun serverEndToEnd() {
        val server = System.getenv("CC_TEST_SERVER").orEmpty()
        val jpegPath = System.getenv("CC_TEST_JPEG").orEmpty()
        if (server.isEmpty() || jpegPath.isEmpty()) return
        val core = core(server)
        assertTrue(core.connectIfNeeded())
        val id = core.newCapture("telegrama", null)
        core.addPage(id, File(jpegPath).readBytes(), "sample")
        val readings = core.readCells(id, 0u, "balotaje-2015")
        assertTrue(readings.aligned)
        assertTrue(readings.fields.all { it.status in setOf("read", "empty", "unreadable") })
        assertTrue(readings.fields.filter { it.status == "unreadable" }.all { it.text == "?" })
        val receipt = core.sendCapture(id)
        assertTrue(receipt.contains("chainHash"))
        assertTrue(core.capture(id).summary.sent)
        try { core.deleteCapture(id); fail("sent captures cannot be deleted") } catch (e: CoreException) {
            assertTrue(e.message!!.contains("no se puede borrar"))
        }
        assertFalse(core.capture(id).receipts.isEmpty())
    }
}
