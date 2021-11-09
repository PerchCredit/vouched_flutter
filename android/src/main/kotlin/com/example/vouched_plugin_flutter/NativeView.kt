package com.example.vouched_plugin_flutter

import android.content.Context
import android.view.LayoutInflater
import android.view.View
import io.flutter.plugin.platform.PlatformView

internal class NativeView(context: Context, id: Int, creationParams: Map<String?, Any?>?) : PlatformView {
    private val contentView: View
//    private val textView: TextView


    override fun getView(): View {

        return contentView
    }

    override fun dispose() {}

    init {
        val layoutInflater: LayoutInflater = LayoutInflater.from(context)
        contentView = layoutInflater.inflate(R.layout.tfe_od_activity_camera, null)

    }
}