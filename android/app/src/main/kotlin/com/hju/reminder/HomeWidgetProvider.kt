package com.hju.reminder

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetPlugin

class HomeWidgetProvider : AppWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        for (appWidgetId in appWidgetIds) {
            // 위젯의 RemoteViews를 생성
            val views = RemoteViews(context.packageName, R.layout.home_widget_layout)

            // HomeWidgetService를 가리키는 Intent를 생성
            val intent = Intent(context, HomeWidgetService::class.java)
            intent.putExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, appWidgetId)
            intent.data = Uri.parse(intent.toUri(Intent.URI_INTENT_SCHEME))

            // 위젯의 ListView에 어댑터를 설정
            views.setRemoteAdapter(R.id.widget_list, intent)

            // 위젯 업데이트를 요청
            appWidgetManager.updateAppWidget(appWidgetId, views)
            appWidgetManager.notifyAppWidgetViewDataChanged(appWidgetId, R.id.widget_list)
        }
        super.onUpdate(context, appWidgetManager, appWidgetIds)
    }
}
