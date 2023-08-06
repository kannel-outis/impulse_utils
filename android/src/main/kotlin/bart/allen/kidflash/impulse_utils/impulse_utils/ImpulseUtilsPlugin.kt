package bart.allen.kidflash.impulse_utils.impulse_utils

import android.annotation.SuppressLint
import android.app.usage.StorageStatsManager
import android.content.Context
import android.content.pm.ApplicationInfo
import android.content.pm.PackageManager
import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.drawable.Drawable
import android.media.ThumbnailUtils
import android.os.Build
import android.os.CancellationSignal
import android.os.Environment
import android.os.StatFs
import android.os.storage.StorageManager
import android.provider.MediaStore.Video.Thumbnails
import android.util.Log
import android.util.Size
import androidx.annotation.NonNull
import androidx.annotation.RequiresApi
import androidx.core.content.ContextCompat.getSystemService

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
import java.io.FileOutputStream
import java.util.*

/** ImpulseUtilsPlugin */
class ImpulseUtilsPlugin: FlutterPlugin, MethodCallHandler {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private lateinit var channel : MethodChannel
  private lateinit var flutterbinding: FlutterPluginBinding
  @SuppressLint("NewApi")
  private val thumbnailSizeMiniKind: Size = /*Size(512, 384) */ Size(512,384)

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    this.flutterbinding = flutterPluginBinding
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "impulse_utils")
    channel.setMethodCallHandler(this)
  }


  @SuppressLint("SuspiciousIndentation")
  override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
//    val handler = Handler(Looper.getMainLooper())
    when (call.method) {
      "getPlatformVersion" -> result.success("Android ${android.os.Build.VERSION.RELEASE}")
      "getDeviceApplications" ->
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
          val showSystemApps = call.argument("showSystemApp") ?: false
          lateinit var success: List<Map<String, Any>>;
          CoroutineScope(Dispatchers.IO).launch {
            success = getDeviceApps(showSystemApps)
            result.success(success)
          }
        } else {
          result.error("404", "Android version cannot perform this operation", "")
        }
      "getMediaThumbnail" -> {
        val isVideo = call.argument<Boolean>("isVideo")!!
        val path = call.argument<String>("filePath")!!
        val width = call.argument<Int?>("width")
        val height = call.argument<Int?>("height")
        val outputPath = call.argument<String?>("output")
        val size =
          if (width == null || height == null) null else if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            Size(width, height)
          } else {
            null
          }
        CoroutineScope(Dispatchers.IO).launch {
          try {
            if (outputPath != null) {
              val output = getThumbNail(path, size, outputPath, isVideo)
              result.success(output)
            } else {
              val byteArray = getThumbNail(path, size, isVideo)
              result.success(byteArray)
            }
          } catch (e: Exception) {
            val error = e.localizedMessage
            result.error("404", error ?: "Something went wrong", "")
          }
        }
      }

      "getStorageInfo" -> {

        val path = call.argument<String>("path")
        CoroutineScope(Dispatchers.IO).launch {
          val resultList = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            getStorageInfo(path!!)
          } else {
            null
          }
          if(resultList != null){
            result.success(resultList)
          }else{
            result.error("404", "Android Version Does Not Support", "")
          }
        }
      }
      else -> {
        result.notImplemented()
      }
    }
  }

  @SuppressLint("NewApi")
  private fun getThumbNail(filePath: String, size: Size?, outputPath: String, isVideo: Boolean): String?{
    val file = File(filePath)
    val cancellationSignal = CancellationSignal()

    var output:String? = null
    try {
      val thumbNail =
        if(isVideo)
          if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            ThumbnailUtils.createVideoThumbnail(file, size?: thumbnailSizeMiniKind, cancellationSignal)
          } else {
            ThumbnailUtils.createVideoThumbnail(filePath, Thumbnails.MINI_KIND)
          }
        else
          if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            ThumbnailUtils.createImageThumbnail(file, size ?: thumbnailSizeMiniKind, cancellationSignal)
          } else {
            ThumbnailUtils.createImageThumbnail(filePath, Thumbnails.MINI_KIND )
          }
      val fileOutputStream = FileOutputStream(outputPath)
        fileOutputStream.write(getByteArray(thumbNail!!, useWebp = true))
        fileOutputStream.close();
       output = outputPath
      return output

    }catch ( e: Exception){
      output = null
      throw e
    }
  }

  @SuppressLint("NewApi")
  private fun getThumbNail(filePath: String, size: Size?, isVideo: Boolean): ByteArray {
    val file = File(filePath)
    val cancellationSignal = CancellationSignal()
    val bitmap =
      if(isVideo)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
          ThumbnailUtils.createVideoThumbnail(file, size?: thumbnailSizeMiniKind, cancellationSignal)
        } else {
          ThumbnailUtils.createVideoThumbnail(filePath, Thumbnails.MINI_KIND)
        }
      else
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
          ThumbnailUtils.createImageThumbnail(file, size ?: thumbnailSizeMiniKind, cancellationSignal)
        } else {
          ThumbnailUtils.createImageThumbnail(filePath, Thumbnails.MINI_KIND )
        }
    return getByteArray(bitmap!!, release = true)
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

      map["appIcon"] = getByteArray(bitMap)
      bitMap.recycle();
//      Log.d("native",  outputStream.toByteArray().toString())
      mutableList.add(map)
    }

    return mutableList
  }

  private fun getByteArray(bitmap: Bitmap, quality: Int? = null, release: Boolean = false, useWebp: Boolean = false ): ByteArray{
    val outputStream = ByteArrayOutputStream()
   bitmap.compress( if(useWebp)  Bitmap.CompressFormat.WEBP  else Bitmap.CompressFormat.PNG,   quality?:30, outputStream)
    if (release) bitmap.recycle()
    return outputStream.toByteArray()
  }

  private fun getBitMapFromDrawable (drawable: Drawable) : Bitmap{
    val bitmap = Bitmap.createBitmap(drawable.intrinsicWidth, drawable.intrinsicHeight, Bitmap.Config.ARGB_8888)
    val canvas = Canvas(bitmap)
    drawable.setBounds(0,0, canvas.width, canvas.height)
    drawable.draw(canvas)
    return bitmap
  }

  @RequiresApi(Build.VERSION_CODES.JELLY_BEAN_MR2)
  private fun getStorageInfo(path: String): Map<String, Any>{
    val stats = StatFs(path)
    val blockSize = stats.blockSizeLong
    val availableBlocks = stats.availableBlocksLong
    val totalBlocks = stats.blockCountLong
    val availableSpace = availableBlocks * blockSize
    val totalSpace = totalBlocks * blockSize
    val returnMap: Map<String, Any> = mapOf(
      "freeSize" to availableSpace,
      "totalSize" to totalSpace,
      "path" to path,
      )

    Log.d("Native_flutter", returnMap.toString())

    return returnMap
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }
}
