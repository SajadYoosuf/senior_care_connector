package com.example.app

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.content.Intent
import android.media.RingtoneManager
import android.net.Uri
import android.app.Activity

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.example.app/ringtone_picker"
    private var pendingResult: MethodChannel.Result? = null
    private val PICK_RINGTONE_REQUEST = 999

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "pickRingtone") {
                pendingResult = result
                val intent = Intent(RingtoneManager.ACTION_RINGTONE_PICKER)
                intent.putExtra(RingtoneManager.EXTRA_RINGTONE_TYPE, RingtoneManager.TYPE_ALARM)
                intent.putExtra(RingtoneManager.EXTRA_RINGTONE_TITLE, "Select Alarm Tone")
                intent.putExtra(RingtoneManager.EXTRA_RINGTONE_EXISTING_URI, null as Uri?)
                startActivityForResult(intent, PICK_RINGTONE_REQUEST)
            } else {
                result.notImplemented()
            }
        }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode == PICK_RINGTONE_REQUEST) {
            if (resultCode == Activity.RESULT_OK) {
                val uri = data?.getParcelableExtra<Uri>(RingtoneManager.EXTRA_RINGTONE_PICKED_URI)
                pendingResult?.success(uri?.toString())
            } else {
                pendingResult?.success(null)
            }
            pendingResult = null
        }
    }
}
