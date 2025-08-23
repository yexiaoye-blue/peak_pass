package com.example.peak_pass.my_autofill_service

import android.app.PendingIntent
import android.app.assist.AssistStructure
import android.app.assist.AssistStructure.ViewNode
import android.content.Context
import android.content.Intent
import android.service.autofill.Dataset
import android.service.autofill.FillResponse
import android.util.Log
import android.view.View
import android.view.autofill.AutofillValue
import android.widget.RemoteViews
import androidx.annotation.DrawableRes
import com.example.peak_pass.R
import com.example.peak_pass.my_autofill_service.MyAutofillService.Companion.TAG
import com.example.peak_pass.my_autofill_service.MyAutofillService.ParsedStructure
import com.example.peak_pass.my_autofill_service.MyAutofillService.UserData

object AutofillHelper {

    fun newSuccessResponse(
        context: Context,
        userData: UserData,
        parsedStructure: ParsedStructure
    ): FillResponse {
        val responseBuilder = FillResponse.Builder()
        val datasetBuilder = Dataset.Builder()

        // 2. 为找到的字段设置值
        if (parsedStructure.usernameId != null) {
            datasetBuilder.setValue(
                parsedStructure.usernameId!!,
                AutofillValue.forText(userData.username),
                newRemoteViews(context.packageName, userData.username, R.drawable.baseline_person_24)
            )
        }
        if (parsedStructure.passwordId != null) {
            datasetBuilder.setValue(
                parsedStructure.passwordId!!,
                AutofillValue.forText(userData.password),
                newRemoteViews(context.packageName, userData.password, R.drawable.baseline_lock_24)
            )
        }
        if (parsedStructure.emailId != null) {
            if (userData.email != null) {
                datasetBuilder.setValue(
                    parsedStructure.emailId!!,
                    AutofillValue.forText(userData.email),
                    newRemoteViews(context.packageName, userData.email!!, R.drawable.baseline_email_24)
                )
            }

        }
        // 8. 添加数据集到响应
        responseBuilder.addDataset(datasetBuilder.build())
        return responseBuilder.build();
    }

    fun newAuthResponse(context: Context, parsedStructure: ParsedStructure) :FillResponse {
        val responseBuilder = FillResponse.Builder()
        // 创建一个Intent来启动您的主应用
        val intent = context.packageManager.getLaunchIntentForPackage(context.packageName)
        intent?.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        Log.d(TAG, "intent: $intent")

        val pendingIntent = PendingIntent.getActivity(
            context,
            0,
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
        responseBuilder.setAuthentication(
            parsedStructure.toAutofillIdArray(),
            pendingIntent.intentSender,
            newRemoteViews(context.packageName, "Open PeakPass to unlock", R.drawable.baseline_phonelink_lock_24)
        )
        return responseBuilder.build()
    }

    private fun newRemoteViews(
        packageName: String,
        remoteViewsText: String,
        @DrawableRes drawableId: Int
    ): RemoteViews {
        val presentation = RemoteViews(packageName, R.layout.custom_autofill_item)
        presentation.setTextViewText(R.id.autofill_text, remoteViewsText)
        presentation.setImageViewResource(R.id.autofill_icon, drawableId)
        return presentation
    }

    /**
     * 从 AssistStructure 中提取域名信息
     */
    fun extractDomainFromStructure(structure: AssistStructure): Map<String, String?> {
        val arguments = mutableMapOf<String, String?>()

        // 遍历所有窗口节点寻找可能包含域名信息的节点
        var foundTitle = false
        var foundDomain = false
        for (i in 0 until structure.windowNodeCount) {
            if (foundTitle && foundDomain) {
                return arguments
            }

            val windowNode = structure.getWindowNodeAt(i)
            val title = windowNode.title
            if (title != null && title.isNotEmpty()) {
                val actualPackageName = title.split("/").firstOrNull()
                if (actualPackageName != null) {
                    arguments["packageName"] = actualPackageName
                } else {
                    arguments["packageName"] = title.toString()
                }
                foundTitle = true
            }

            val webDomain = windowNode.rootViewNode.webDomain
            if (webDomain != null) {
                arguments["domain"] = webDomain
                foundDomain = true
            }
        }
        return arguments
    }



    fun parseStructure(structure: AssistStructure): ParsedStructure {
        Log.d(TAG, "Parsing structure")
        val parsedStructure = ParsedStructure()

        // 遍历所有窗口节点
        for (i in 0 until structure.windowNodeCount) {
            val windowNode = structure.getWindowNodeAt(i)
            val viewNode = windowNode.rootViewNode
            parseNode(viewNode, parsedStructure)
        }
        return parsedStructure
    }

    private fun parseNode(viewNode: ViewNode?, parsedStructure: ParsedStructure) {
        // 检查当前节点是否有自动填充提示
        viewNode?.autofillHints?.forEach { hint ->
            when (hint) {
                View.AUTOFILL_HINT_USERNAME -> {
                    parsedStructure.usernameId = viewNode.autofillId
                }

                View.AUTOFILL_HINT_PASSWORD -> {
                    parsedStructure.passwordId = viewNode.autofillId
                }

                View.AUTOFILL_HINT_EMAIL_ADDRESS -> {
                    parsedStructure.emailId = viewNode.autofillId
                }
            }
        }

        // 递归遍历子节点
        for (i in 0 until (viewNode?.childCount ?: 0)) {
            val childNode = viewNode?.getChildAt(i)
            parseNode(childNode, parsedStructure)
        }
    }

}