package com.anhquan.unisync.utils

import io.reactivex.rxjava3.core.Observable
import io.reactivex.rxjava3.core.ObservableEmitter
import io.reactivex.rxjava3.core.Scheduler
import io.reactivex.rxjava3.core.Single
import io.reactivex.rxjava3.disposables.Disposable
import io.reactivex.rxjava3.schedulers.Schedulers
import java.util.concurrent.TimeUnit

fun runSingle(
    subscribeOn: Scheduler = Schedulers.io(),
    observeOn: Scheduler = Schedulers.io(),
    onError: (e: Throwable) -> Unit = { errorLog("runSingle: error:\n${it.stackTrace.joinToString("\n")}\n$it") },
    callback: () -> Unit,
): Disposable {
    return Single.create<Unit> {
        try {
            callback.invoke()
        } catch (e: Throwable) {
            it.onError(e)
        }
    }.subscribeOn(subscribeOn).observeOn(observeOn).subscribe({}, onError)
}

fun runPeriodic(
    intervalInMillis: Long,
    subscribeOn: Scheduler = Schedulers.io(),
    observeOn: Scheduler = Schedulers.io(),
    callback: () -> Unit
): Disposable {
    return Observable.interval(intervalInMillis, TimeUnit.MILLISECONDS).subscribeOn(subscribeOn)
        .observeOn(observeOn).subscribe({ callback.invoke() }, {})
}

fun <T : Any> runTask(
    subscribeOn: Scheduler = Schedulers.io(),
    observeOn: Scheduler = Schedulers.io(),
    task: (ObservableEmitter<T>) -> Unit,
    onResult: (T) -> Unit = {},
    onError: (Throwable) -> Unit = { errorLog("runTask: error:\n${it.stackTrace.joinToString("\n")}\n$it") },
    onComplete: () -> Unit = {}
): Disposable {
    return Observable
        .create {
            task.invoke(it)
        }
        .subscribeOn(subscribeOn)
        .observeOn(observeOn)
        .subscribe(
            onResult,
            onError,
            onComplete
        )
}
