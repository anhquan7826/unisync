package com.anhquan.unisync.repository

import com.anhquan.unisync.extensions.addTo
import com.anhquan.unisync.extensions.text
import com.anhquan.unisync.models.ClientInfo
import com.anhquan.unisync.plugins.mDNSPlugin
import com.anhquan.unisync.utils.runSingle
import com.google.gson.Gson
import io.reactivex.rxjava3.disposables.CompositeDisposable
import javax.jmdns.ServiceEvent
import javax.jmdns.ServiceListener

class ConnectionRepositoryImpl(private val myClientInfo: ClientInfo) : ConnectionRepository {
    private val mdns = mDNSPlugin()
    private val disposables = CompositeDisposable()

    override fun initiate() {
        runSingle {
            mdns.apply {
                create()
//                register()
            }
        }.addTo(disposables)
    }

    override fun addListener(
        onClientAdded: (ClientInfo) -> Unit,
        onClientRemoved: (ClientInfo) -> Unit,
        onClientChanged: ((List<ClientInfo>) -> Unit)?
    ) {
        mdns.addListener(object : ServiceListener {
            override fun serviceAdded(event: ServiceEvent?) {}

            override fun serviceRemoved(event: ServiceEvent?) {
                if (event != null) {
                    val client = Gson().fromJson(event.info.text, ClientInfo::class.java)
                    onClientRemoved.invoke(client)
                }
            }

            override fun serviceResolved(event: ServiceEvent?) {
                if (event != null) {
                    val client = Gson().fromJson(event.info.text, ClientInfo::class.java)
                    onClientAdded.invoke(client)
                    onClientChanged?.invoke(mdns.getServices().map {
                        Gson().fromJson(it.text, ClientInfo::class.java)
                    })
                }
            }

        })
    }
}