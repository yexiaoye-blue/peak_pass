package com.example.peak_pass.my_autofill_service

import android.app.assist.AssistStructure
import android.os.CancellationSignal
import android.service.autofill.AutofillService
import android.service.autofill.FillCallback
import android.service.autofill.FillContext
import android.service.autofill.FillRequest
import android.service.autofill.SaveCallback
import android.service.autofill.SaveRequest
import android.util.Log
import android.view.autofill.AutofillId

class MyAutofillService : AutofillService() {
    companion object {
        const val TAG = "PasswordAutofillService"
        const val CHANNEL_NAME = "peak_pass_autofill"
        const val FLUTTER_ENGINE_ID = "peak_pass_flutter_engine"
        const val METHOD_GET_AUTOFILL_DATA = "getAutoFillData"
        const val METHOD_CHECK_AUTH = "isDatabaseUnlocked"
    }

    data class ParsedStructure(
        var usernameId: AutofillId? = null,
        var passwordId: AutofillId? = null,
        var emailId: AutofillId? = null
    ){
        fun toAutofillIdArray(): Array<AutofillId> {
            val ids = mutableListOf<AutofillId>()
            usernameId?.let { ids.add(it) }
            passwordId?.let { ids.add(it) }
            emailId?.let { ids.add(it) }
            return ids.toTypedArray()
        }
    }

    // 解析的数据
    data class UserData(var username: String, var email: String?, var password: String)


    override fun onFillRequest(
        request: FillRequest,
        cancellationSignal: CancellationSignal,
        callback: FillCallback
    ) {

        // 1. 获取请求中的视图结构
        val contexts: List<FillContext> = request.fillContexts
        if (contexts.isEmpty()) {
            Log.w(TAG, "No context found in request")
            callback.onSuccess(null)
            return
        }
        val structure: AssistStructure = contexts[contexts.size - 1].structure
        Log.d(TAG, "Processing structure with ${structure.windowNodeCount} windows")

        // 2. 遍历结构寻找要填充的字段
        val parsedStructure: ParsedStructure = AutofillHelper.parseStructure(structure)

        if (parsedStructure.passwordId == null) {
            Log.w(TAG, "Autofill id not found.")
            callback.onSuccess(null)
            return
        }

        // 通过Channel检查数据库是否已经开启
        AutofillChannel.checkDatabaseStatusWithFlutter { isUnlocked ->
            if (!isUnlocked) {
                val response = AutofillHelper.newAuthResponse(this, parsedStructure)
                callback.onSuccess(response)
                return@checkDatabaseStatusWithFlutter
            }

            // 通过Channel查询数据
            AutofillChannel.fetchUserDataFromFlutter(structure) { userData ->
                if (userData != null) {
                    val response = AutofillHelper.newSuccessResponse(this, userData, parsedStructure)
                    callback.onSuccess(response)
                } else {
                    Log.d(TAG, "No user data found")
                    callback.onSuccess(null)
                }
            }
        }
    }

    // TODO: 保存/登录后, 提示是否保存或更新数据库中的值
    override fun onSaveRequest(
        request: SaveRequest,
        callback: SaveCallback
    ) {
        Log.d(TAG, "onSaveRequest called")
    }
}