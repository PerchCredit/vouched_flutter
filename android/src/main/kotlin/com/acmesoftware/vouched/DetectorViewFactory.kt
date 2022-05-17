package com.acmesoftware.vouched

import android.content.Context
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory
import java.lang.Exception

class DetectorViewFactory(
    private val methodChannel: MethodChannel,
    private val eventChannel: EventChannel
) :
    PlatformViewFactory(StandardMessageCodec.INSTANCE) {

    @Suppress("UNCHECKED_CAST")
    override fun create(context: Context?, viewId: Int, args: Any?): PlatformView {
        if (args == null) throw IllegalArgumentException("args should not be empty")
        if(context == null) throw Exception("No context to attach view")

        return DetectorView(methodChannel, eventChannel, context, args as Map<String, Any>)
    }
}