package com.example.peak_pass

import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.FlutterEngineCache

class MainActivity : FlutterFragmentActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        // 缓存FlutterEngine
        FlutterEngineCache.getInstance().put("peak_pass_flutter_engine", flutterEngine)
    }
}
