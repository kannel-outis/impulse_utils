package bart.allen.kidflash.impulse_utils.impulse_utils

import android.content.pm.ApplicationInfo
import android.content.pm.PackageManager
import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.drawable.BitmapDrawable
import android.graphics.drawable.Drawable
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.util.Log
import androidx.annotation.NonNull
import androidx.annotation.RequiresApi

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.FlutterPlugin.FlutterPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import java.io.ByteArrayOutputStream
import java.io.File

/** ImpulseUtilsPlugin */
class ImpulseUtilsPlugin: FlutterPlugin, MethodCallHandler {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private lateinit var channel : MethodChannel
  private lateinit var flutterbinding: FlutterPluginBinding

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    this.flutterbinding = flutterPluginBinding
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "impulse_utils")
    channel.setMethodCallHandler(this)
  }


  override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
//    val handler = Handler(Looper.getMainLooper())
    if (call.method == "getPlatformVersion") {
      result.success("Android ${android.os.Build.VERSION.RELEASE}")
    } else if (call.method == "getDeviceApplications"){

      if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
        val showSystemApps = call.argument("showSystemApp") ?: false
          lateinit var success: List<Map<String, Any>>;
        CoroutineScope(Dispatchers.IO).launch {
          success = getDeviceApps(showSystemApps)
//          handler.post{
            result.success(success)
//          }
        }

      } else {
//        handler.post{
          result.error( "404","Android version cannot perform this operation", "")
//        }
      }


    } else {
      result.notImplemented()
    }
  }


  @RequiresApi(Build.VERSION_CODES.N)
  private fun getDeviceApps(showSystemApps: Boolean): List<Map<String, Any>>{
    val mutableList = mutableListOf<Map<String, Any>>()
    val packageManager = flutterbinding.applicationContext.packageManager
    val installedApps = packageManager.getInstalledApplications(PackageManager.GET_META_DATA)
    for ( app: ApplicationInfo in installedApps){

      val map = mutableMapOf<String, Any>()
      map["appName"] = app.loadLabel(packageManager).toString()
      map["packageName"] = app.packageName
      map["appPath"] = app.sourceDir
      map["appSize"] = File(app.publicSourceDir).length()
      map["isSystemApp"] = (app.flags and (ApplicationInfo.FLAG_SYSTEM or ApplicationInfo.FLAG_UPDATED_SYSTEM_APP)) != 0
      map["isDisabled"] = !app.enabled
      val bitMap = getBitMapFromDrawable(packageManager.getApplicationIcon(app))
      val outputStream = ByteArrayOutputStream()
      bitMap.compress(Bitmap.CompressFormat.PNG, 100, outputStream)
      map["appIcon"] = outputStream.toByteArray()
//      Log.d("native",  outputStream.toByteArray().toString())
      mutableList.add(map)
    }

    return mutableList
  }

  private fun getBitMapFromDrawable (drawable: Drawable) : Bitmap{
    val bitmap = Bitmap.createBitmap(drawable.intrinsicWidth, drawable.intrinsicHeight, Bitmap.Config.ARGB_8888)
    val canvas = Canvas(bitmap)
    drawable.setBounds(0,0, canvas.width, canvas.height)
    drawable.draw(canvas)
    return bitmap
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }
}
