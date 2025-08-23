package com.example.peak_pass.my_autofill_service

import android.app.assist.AssistStructure
import android.content.Context
import android.util.Log
import com.example.peak_pass.my_autofill_service.MyAutofillService.Companion.CHANNEL_NAME
import com.example.peak_pass.my_autofill_service.MyAutofillService.Companion.FLUTTER_ENGINE_ID
import com.example.peak_pass.my_autofill_service.MyAutofillService.Companion.METHOD_CHECK_AUTH
import com.example.peak_pass.my_autofill_service.MyAutofillService.Companion.METHOD_GET_AUTOFILL_DATA
import com.example.peak_pass.my_autofill_service.MyAutofillService.Companion.TAG
import com.example.peak_pass.my_autofill_service.MyAutofillService.UserData
import io.flutter.embedding.engine.FlutterEngineCache
import io.flutter.plugin.common.MethodChannel
import org.json.JSONObject

object AutofillChannel {

    fun checkDatabaseStatusWithFlutter(callback: (Boolean) -> Unit) {
        val flutterEngine = FlutterEngineCache.getInstance().get(FLUTTER_ENGINE_ID)
        // 这里如果engine 为  null, 也应该显示  auth view
        if (flutterEngine == null) {
            Log.e(TAG, "FlutterEngine not found in cache")
            callback(false)
            return
        }

        val methodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL_NAME)

        methodChannel.invokeMethod(METHOD_CHECK_AUTH, null, object : MethodChannel.Result {
            override fun success(result: Any?) {
                try {
                    Log.d(TAG, "Received database status from Flutter: $result")
                    callback(result is Boolean && result)
                } catch (e: Exception) {
                    Log.e(TAG, "Error parsing database status response", e)
                    callback(false)
                }
            }

            override fun error(errorCode: String, errorMessage: String?, errorDetails: Any?) {
                Log.e(
                    TAG,
                    "Flutter method error when checking database status: $errorCode - $errorMessage"
                )
                callback(false)
            }

            override fun notImplemented() {
                Log.e(TAG, "Flutter method 'isDatabaseUnlocked' not implemented")
                callback(false)
            }
        })
    }


    fun fetchUserDataFromFlutter(
        structure: AssistStructure,
        callback: (UserData?) -> Unit
    ) {
        Log.d(TAG, "Fetching user data")
        // 从缓存中获取 FlutterEngine

        val flutterEngine = FlutterEngineCache.getInstance().get(FLUTTER_ENGINE_ID)
        if (flutterEngine == null) {
            Log.e(TAG, "FlutterEngine not found in cache")
            callback(null)
            return
        }

        val methodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL_NAME)
        // 生成查询查询条件, 包名, domain[如果是网页的话]
        val arguments = AutofillHelper.extractDomainFromStructure(structure)

        methodChannel.invokeMethod(
            METHOD_GET_AUTOFILL_DATA,
            arguments,
            object : MethodChannel.Result {
                override fun success(result: Any?) {
                    try {
                        Log.d(TAG, "Received data from Flutter: $result")
                        if (result !is String) throw Exception("Invalid result: $result")

                        val json = JSONObject(result)

                        val username = json.optString("username")
                        val email = json.optString("email")
                        val password = json.optString("password")

                        callback(UserData(username, email, password))
                    } catch (e: Exception) {
                        Log.e(TAG, "Error parsing Flutter response", e)
                        callback(null)
                    }
                }

                override fun error(errorCode: String, errorMessage: String?, errorDetails: Any?) {
                    Log.e(TAG, "Flutter method error: $errorCode - $errorMessage")
                    callback(null)
                }

                override fun notImplemented() {
                    Log.e(TAG, "Flutter method not implemented")
                    callback(null)
                }

            })
    }

}