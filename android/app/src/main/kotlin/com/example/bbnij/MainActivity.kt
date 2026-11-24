package com.example.bbnij

import android.Manifest
import android.content.ActivityNotFoundException
import android.content.ContentValues
import android.content.Intent
import android.content.pm.PackageManager
import android.media.MediaScannerConnection
import android.net.Uri
import android.os.Build
import android.os.Environment
import android.os.Handler
import android.os.Looper
import android.provider.MediaStore
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.io.File

/**
 * Hosts the `bbnij/downloads` channel, which saves files into the phone's
 * public Download/BBNIJ folder (visible in the Files / Downloads app) and opens them.
 */
class MainActivity : FlutterActivity() {
    private val mainHandler = Handler(Looper.getMainLooper())
    private var pendingLegacySave: (() -> Unit)? = null
    private var pendingLegacyResult: MethodChannel.Result? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "saveToDownloads" -> saveToDownloads(call, result)
                "openFile" -> openFile(call, result)
                else -> result.notImplemented()
            }
        }
    }

    private fun saveToDownloads(call: MethodCall, result: MethodChannel.Result) {
        val bytes = call.argument<ByteArray>("bytes")
        val fileName = call.argument<String>("fileName")
        val mimeType = call.argument<String>("mimeType") ?: "application/octet-stream"
        if (bytes == null || fileName.isNullOrBlank()) {
            result.error("bad_args", "bytes and fileName are required", null)
            return
        }

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            Thread {
                try {
                    val saved = saveWithMediaStore(bytes, fileName, mimeType)
                    mainHandler.post { result.success(saved) }
                } catch (e: Exception) {
                    mainHandler.post { result.error("save_failed", e.message, null) }
                }
            }.start()
            return
        }

        val save = { saveLegacy(bytes, fileName, mimeType, result) }
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.M ||
            checkSelfPermission(Manifest.permission.WRITE_EXTERNAL_STORAGE) == PackageManager.PERMISSION_GRANTED
        ) {
            save()
        } else {
            pendingLegacySave = save
            pendingLegacyResult = result
            requestPermissions(arrayOf(Manifest.permission.WRITE_EXTERNAL_STORAGE), STORAGE_REQUEST_CODE)
        }
    }

    /** Android 10+: no permission needed to add files to the shared Downloads collection. */
    private fun saveWithMediaStore(bytes: ByteArray, fileName: String, mimeType: String): Map<String, String> {
        val resolver = contentResolver
        val values = ContentValues().apply {
            put(MediaStore.MediaColumns.DISPLAY_NAME, fileName)
            put(MediaStore.MediaColumns.MIME_TYPE, mimeType)
            put(MediaStore.MediaColumns.RELATIVE_PATH, "${Environment.DIRECTORY_DOWNLOADS}/$SUB_FOLDER")
            put(MediaStore.MediaColumns.IS_PENDING, 1)
        }
        val uri = resolver.insert(MediaStore.Downloads.EXTERNAL_CONTENT_URI, values)
            ?: throw IllegalStateException("Could not create the file in Downloads")
        try {
            resolver.openOutputStream(uri)?.use { it.write(bytes) }
                ?: throw IllegalStateException("Could not open the file for writing")
            values.clear()
            values.put(MediaStore.MediaColumns.IS_PENDING, 0)
            resolver.update(uri, values, null, null)
        } catch (e: Exception) {
            resolver.delete(uri, null, null)
            throw e
        }

        // MediaStore may rename duplicates, e.g. "Invoice_1 (1).pdf".
        var savedName = fileName
        resolver.query(uri, arrayOf(MediaStore.MediaColumns.DISPLAY_NAME), null, null, null)?.use { cursor ->
            if (cursor.moveToFirst()) savedName = cursor.getString(0) ?: fileName
        }
        return mapOf(
            "uri" to uri.toString(),
            "path" to "${Environment.DIRECTORY_DOWNLOADS}/$SUB_FOLDER/$savedName",
        )
    }

    /** Android 9 and below: write straight into the public Download folder. */
    @Suppress("DEPRECATION")
    private fun saveLegacy(bytes: ByteArray, fileName: String, mimeType: String, result: MethodChannel.Result) {
        Thread {
            try {
                val folder = File(Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_DOWNLOADS), SUB_FOLDER)
                if (!folder.exists() && !folder.mkdirs()) throw IllegalStateException("Could not create ${folder.path}")
                val file = uniqueFile(folder, fileName)
                file.writeBytes(bytes)
                MediaScannerConnection.scanFile(this, arrayOf(file.absolutePath), arrayOf(mimeType)) { _, uri ->
                    mainHandler.post {
                        result.success(
                            mapOf(
                                "uri" to (uri ?: Uri.fromFile(file)).toString(),
                                "path" to "${Environment.DIRECTORY_DOWNLOADS}/$SUB_FOLDER/${file.name}",
                            ),
                        )
                    }
                }
            } catch (e: Exception) {
                mainHandler.post { result.error("save_failed", e.message, null) }
            }
        }.start()
    }

    private fun uniqueFile(folder: File, fileName: String): File {
        var file = File(folder, fileName)
        if (!file.exists()) return file
        val base = fileName.substringBeforeLast('.')
        val ext = fileName.substringAfterLast('.', "")
        var index = 1
        while (file.exists()) {
            file = File(folder, if (ext.isEmpty()) "$base ($index)" else "$base ($index).$ext")
            index++
        }
        return file
    }

    override fun onRequestPermissionsResult(requestCode: Int, permissions: Array<out String>, grantResults: IntArray) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        if (requestCode != STORAGE_REQUEST_CODE) return
        val save = pendingLegacySave
        val result = pendingLegacyResult
        pendingLegacySave = null
        pendingLegacyResult = null
        if (grantResults.firstOrNull() == PackageManager.PERMISSION_GRANTED) {
            save?.invoke()
        } else {
            result?.error("permission_denied", "Storage permission is required to save the file", null)
        }
    }

    private fun openFile(call: MethodCall, result: MethodChannel.Result) {
        val uri = call.argument<String>("uri")
        val mimeType = call.argument<String>("mimeType") ?: "*/*"
        if (uri.isNullOrBlank()) {
            result.error("bad_args", "uri is required", null)
            return
        }
        val intent = Intent(Intent.ACTION_VIEW).apply {
            setDataAndType(Uri.parse(uri), mimeType)
            addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION or Intent.FLAG_ACTIVITY_NEW_TASK)
        }
        try {
            startActivity(Intent.createChooser(intent, null).addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION))
            result.success(true)
        } catch (e: ActivityNotFoundException) {
            result.success(false)
        }
    }

    companion object {
        private const val CHANNEL = "bbnij/downloads"
        private const val SUB_FOLDER = "BBNIJ"
        private const val STORAGE_REQUEST_CODE = 4107
    }
}
