package com.tess.fluttertesstodo

import android.annotation.SuppressLint
import android.nfc.NdefMessage
import android.nfc.NdefRecord
import android.nfc.NfcAdapter
import android.nfc.NfcEvent
import android.os.Bundle
import io.flutter.app.FlutterActivity
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.GeneratedPluginRegistrant


class MainActivity : FlutterActivity(), NfcAdapter.CreateNdefMessageCallback {

    private val LAUNCH_TYPE_APP_START = "appStart"
    private val LAUNCH_TYPE_ADD_TODO = "addTodo"
    private val LAUNCH_TYPE_EMPTY_TODO_ID = "emptyTodoId"

    private var sendId: String? = null
    private var isNfcExist = false
    private lateinit var channel: MethodChannel

    @SuppressLint("ObsoleteSdkInt")
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        GeneratedPluginRegistrant.registerWith(this)
        channel = MethodChannel(flutterView, "flutter.native/helper")
        channel.setMethodCallHandler { call, result ->
            when (call.method) {
                "sendTodoId" -> {
                    sendId = call.argument<String>("id")
                    result.success(true)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
        channel.invokeMethod(LAUNCH_TYPE_APP_START, "")

    }

    override fun onResume() {
        super.onResume()
        if (NfcAdapter.ACTION_NDEF_DISCOVERED == intent.action) {
            val rawMessages = intent.getParcelableArrayExtra(NfcAdapter.EXTRA_NDEF_MESSAGES)
            val message = rawMessages[0] as NdefMessage
            if (String(message.records[0].payload) != "") {
                channel.invokeMethod(LAUNCH_TYPE_ADD_TODO, String(message.records[0].payload))
            }
        }
    }

    override fun createNdefMessage(event: NfcEvent?): NdefMessage {
        var message = ""
        if (sendId != null) {
            message = sendId as String
        }
        val nDefRecord = NdefRecord.createMime("text/plain", message.toByteArray())
        return NdefMessage(nDefRecord)
    }

}
