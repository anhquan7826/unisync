package com.anhquan.unisync.utils

import io.reactivex.rxjava3.core.Scheduler
import io.reactivex.rxjava3.core.Single
import io.reactivex.rxjava3.disposables.Disposable
import io.reactivex.rxjava3.schedulers.Schedulers

fun runSingle(
    subscribeOn: Scheduler = Schedulers.io(),
    observeOn: Scheduler = Schedulers.io(),
    onError: (e: Throwable) -> Unit = { errorLog(it.message) },
    callback: () -> Unit,
): Disposable {
    return Single.create<Unit> {
        callback.invoke()
    }.subscribeOn(subscribeOn).observeOn(observeOn).subscribe({}, onError)
}