package com.example.vouched_plugin_flutter

import android.content.Intent
import androidx.annotation.NonNull

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

/** VouchedPluginFlutterPlugin */
class VouchedPluginFlutterPlugin: FlutterPlugin, MethodCallHandler {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private lateinit var channel : MethodChannel
  private lateinit var flutterPluginBinding: FlutterPlugin.FlutterPluginBinding

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "vouched_plugin_flutter")
    channel.setMethodCallHandler(this)
    this.flutterPluginBinding = flutterPluginBinding

    flutterPluginBinding.platformViewRegistry.registerViewFactory("vouchedScannerCardView", NativeViewFactory())
  }

  override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
    if (call.method == "startAuth") {
      val intent = Intent(flutterPluginBinding.applicationContext, DetectorActivity::class.java)
      flutterPluginBinding.applicationContext.startActivity(intent)
    } else {
      result.notImplemented()
    }
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }
}
