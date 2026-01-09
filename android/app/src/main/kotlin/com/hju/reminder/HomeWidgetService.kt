package com.hju.reminder

import android.content.Context
import android.content.Intent
import android.widget.RemoteViews
import android.widget.RemoteViewsService
import es.antonborri.home_widget.HomeWidgetPlugin
import org.json.JSONArray
import org.json.JSONObject

class HomeWidgetService : RemoteViewsService() {
    override fun onGetViewFactory(intent: Intent): RemoteViewsFactory {
        return HomeWidgetFactory(applicationContext)
    }
}

class HomeWidgetFactory(private val context: Context) : RemoteViewsService.RemoteViewsFactory {
    private var tasks = listOf<String>()

    override fun onCreate() {
        // Not used
    }

    override fun onDataSetChanged() {
        // 데이터가 변경될 때 Flutter에서 저장한 데이터를 다시 로드
        val widgetData = HomeWidgetPlugin.getData(context)
        val tasksJsonString = widgetData.getString("tasks", "[]") ?: "[]"
        val jsonArray = JSONArray(tasksJsonString)
        tasks = List(jsonArray.length()) { jsonArray.getString(it) }
    }

    override fun onDestroy() {
        // Not used
    }

    override fun getCount(): Int {
        return tasks.size
    }

    override fun getViewAt(position: Int): RemoteViews {
        // 각 항목의 View를 생성
        val views = RemoteViews(context.packageName, R.layout.home_widget_item)
        views.setTextViewText(R.id.widget_item_text, tasks[position])
        return views
    }

    override fun getLoadingView(): RemoteViews? {
        // 로딩 중에 표시할 View (null이면 기본 로딩 아이콘)
        return null
    }

    override fun getViewTypeCount(): Int {
        return 1
    }

    override fun getItemId(position: Int): Long {
        return position.toLong()
    }



    override fun hasStableIds(): Boolean {
        return true
    }
}
