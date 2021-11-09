package com.example.vouched_plugin_flutter

import android.content.Context
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory
import id.vouched.android.CardDetect;
import id.vouched.android.VouchedSession;

class NativeViewFactory : PlatformViewFactory(StandardMessageCodec.INSTANCE) {
    private var cardDetect: CardDetect? = null
    protected var session: VouchedSession? = null

    override fun create(context: Context, viewId: Int, args: Any?): PlatformView {
        val creationParams = args as Map<String?, Any?>?
        return NativeView(context, viewId, creationParams)
    }
}