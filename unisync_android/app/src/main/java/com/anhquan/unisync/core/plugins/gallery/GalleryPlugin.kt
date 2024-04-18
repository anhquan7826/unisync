package com.anhquan.unisync.core.plugins.gallery

import android.Manifest
import android.content.ContentUris
import android.content.pm.PackageManager
import android.os.Build
import android.provider.MediaStore
import androidx.core.content.ContextCompat
import com.anhquan.unisync.core.Device
import com.anhquan.unisync.core.DeviceConnection
import com.anhquan.unisync.core.plugins.UnisyncPlugin
import com.anhquan.unisync.models.DeviceMessage
import java.io.IOException

class GalleryPlugin(device: Device) :
    UnisyncPlugin(device, DeviceMessage.Type.GALLERY) {
    private object Method {
        const val GET_GALLERY = "get_gallery"
        const val GET_IMAGE = "get_image"
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
                        payloadData = it
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
        return images
    }

    private fun getImage(id: Long): ByteArray? {
        try {
            val uri = ContentUris.withAppendedId(collectionUri, id);
            val inputStream = context.contentResolver.openInputStream(uri) ?: return null
            val buffer = ByteArray(inputStream.available())
            var bytesRead = 0
            while (bytesRead < buffer.size) {
                val count = inputStream.read(buffer, bytesRead, buffer.size - bytesRead)
                if (count == -1) break
                bytesRead += count
            }
            inputStream.close()
            return buffer
        } catch (e: IOException) {
            e.printStackTrace()
            return null
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