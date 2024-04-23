package com.anhquan.unisync.core.plugins.gallery

import android.Manifest
import android.content.ContentUris
import android.content.pm.PackageManager
import android.graphics.Bitmap
import android.os.Build
import android.provider.MediaStore
import android.util.Size
import androidx.core.content.ContextCompat
import com.anhquan.unisync.core.Device
import com.anhquan.unisync.core.DeviceConnection
import com.anhquan.unisync.core.plugins.UnisyncPlugin
import com.anhquan.unisync.models.DeviceMessage
import java.io.ByteArrayOutputStream
import java.io.IOException

class GalleryPlugin(device: Device) :
    UnisyncPlugin(device, DeviceMessage.Type.GALLERY) {
    private object Method {
        const val GET_GALLERY = "get_gallery"
        const val GET_IMAGE = "get_image"
        const val GET_THUMBNAIL = "get_thumbnail"
    }

    data class Media(
        val id: Long,
        val name: String,
        val size: Long,
        val mimeType: String,
    )

    private val collectionUri = MediaStore.Images.Media.getContentUri(MediaStore.VOLUME_EXTERNAL)

    override fun listen(
        header: DeviceMessage.DeviceMessageHeader,
        data: Map<String, Any?>,
        payload: DeviceConnection.Payload?
    ) {
        super.listen(header, data, payload)
        when (header.method) {
            Method.GET_GALLERY -> {
                sendResponse(
                    Method.GET_GALLERY,
                    mapOf(
                        "gallery" to queryGallery().map { m ->
                            mapOf(
                                "id" to m.id,
                                "name" to m.name,
                                "size" to m.size,
                                "mimeType" to m.mimeType
                            )
                        }
                    )
                )
            }

            Method.GET_IMAGE -> {
                getImage((data["id"] as Double).toLong())?.let {
                    sendResponse(
                        Method.GET_IMAGE,
                        mapOf(
                            "image" to data["id"]
                        ),
                        payload = it
                    )
                }
            }

            Method.GET_THUMBNAIL -> {
                getThumbnail(
                    (data["id"] as Double).toLong(),
                    (data["width"] as Double).toInt(),
                    (data["height"] as Double).toInt()
                )?.let {
                    sendResponse(
                        Method.GET_THUMBNAIL,
                        mapOf(
                            "image" to data["id"]
                        ),
                        payload = it
                    )
                }
            }
        }
    }

    private fun queryGallery(): List<Media> {
        val projection = arrayOf(
            MediaStore.Images.Media._ID,
            MediaStore.Images.Media.DISPLAY_NAME,
            MediaStore.Images.Media.SIZE,
            MediaStore.Images.Media.MIME_TYPE,
        )
        val images = mutableListOf<Media>()
        context.contentResolver.query(
            collectionUri,
            projection,
            null,
            null,
            null
        )?.use { cursor ->
            val idColumn = cursor.getColumnIndexOrThrow(MediaStore.Images.Media._ID)
            val displayNameColumn =
                cursor.getColumnIndexOrThrow(MediaStore.Images.Media.DISPLAY_NAME)
            val sizeColumn = cursor.getColumnIndexOrThrow(MediaStore.Images.Media.SIZE)
            val mimeTypeColumn = cursor.getColumnIndexOrThrow(MediaStore.Images.Media.MIME_TYPE)

            while (cursor.moveToNext()) {
                val id = cursor.getLong(idColumn)
                val name = cursor.getString(displayNameColumn)
                val size = cursor.getLong(sizeColumn)
                val mimeType = cursor.getString(mimeTypeColumn)

                val image = Media(id, name, size, mimeType)
                images.add(image)
            }
        }
        return images.filter {
            listOf("image/png", "image/jpg", "image/jpeg").contains(it.mimeType)
        }
    }

    private fun queryImage(id: Long): Media? {
        val projection = arrayOf(
            MediaStore.Images.Media.DISPLAY_NAME,
            MediaStore.Images.Media.SIZE,
            MediaStore.Images.Media.MIME_TYPE,
        )
        var image: Media? = null
        context.contentResolver.query(
            collectionUri,
            projection,
            "${MediaStore.Images.Media._ID} = $id",
            null,
            null
        )?.use { cursor ->
            val displayNameColumn =
                cursor.getColumnIndexOrThrow(MediaStore.Images.Media.DISPLAY_NAME)
            val sizeColumn = cursor.getColumnIndexOrThrow(MediaStore.Images.Media.SIZE)
            val mimeTypeColumn = cursor.getColumnIndexOrThrow(MediaStore.Images.Media.MIME_TYPE)

            cursor.moveToNext()
            val name = cursor.getString(displayNameColumn)
            val size = cursor.getLong(sizeColumn)
            val mimeType = cursor.getString(mimeTypeColumn)
            image = Media(id, name, size, mimeType)

        }
        return image
    }

    private fun getImage(id: Long): DeviceConnection.Payload? {
        try {
            val size = queryImage(id)?.size ?: return null
            val uri = ContentUris.withAppendedId(collectionUri, id);
            val inputStream = context.contentResolver.openInputStream(uri) ?: return null
            return DeviceConnection.Payload(inputStream, size.toInt())
        } catch (e: IOException) {
            e.printStackTrace()
            return null
        }
    }

    private fun getThumbnail(id: Long, width: Int, height: Int): DeviceConnection.Payload? {
        return try {
            val uri = ContentUris.withAppendedId(collectionUri, id)
            val bitmap = context.contentResolver.loadThumbnail(uri, Size(width, height), null)
            return convertBitmapToByteArray(bitmap)?.let {
                DeviceConnection.Payload(it.inputStream(), it.size)
            }
        } catch (e: IOException) {
            e.printStackTrace()
            null
        }
    }

    private fun convertBitmapToByteArray(bitmap: Bitmap?): ByteArray? {
        if (bitmap == null) return null
        var baos: ByteArrayOutputStream? = null
        return try {
            baos = ByteArrayOutputStream()
            bitmap.compress(Bitmap.CompressFormat.PNG, 100, baos)
            baos.toByteArray()
        } finally {
            if (baos != null) {
                try {
                    baos.close()
                } catch (_: IOException) {
                }
            }
        }
    }

    override val requiredPermission: List<String>
        get() {
            val permissions = mutableListOf<String>()
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.UPSIDE_DOWN_CAKE) {
                permissions.addAll(arrayOf(
                    Manifest.permission.READ_MEDIA_IMAGES,
//                    Manifest.permission.READ_MEDIA_VIDEO,
//                    Manifest.permission.READ_MEDIA_VISUAL_USER_SELECTED
                ).filterNot {
                    ContextCompat.checkSelfPermission(
                        context,
                        it
                    ) == PackageManager.PERMISSION_GRANTED
                })
            } else if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                permissions.addAll(arrayOf(
                    Manifest.permission.READ_MEDIA_IMAGES,
//                    Manifest.permission.READ_MEDIA_VIDEO
                ).filterNot {
                    ContextCompat.checkSelfPermission(
                        context,
                        it
                    ) == PackageManager.PERMISSION_GRANTED
                })
            } else {
                if (ContextCompat.checkSelfPermission(
                        context,
                        Manifest.permission.READ_EXTERNAL_STORAGE
                    ) != PackageManager.PERMISSION_GRANTED
                ) {
                    permissions.add(Manifest.permission.READ_EXTERNAL_STORAGE)
                }
            }
            return permissions
        }
}