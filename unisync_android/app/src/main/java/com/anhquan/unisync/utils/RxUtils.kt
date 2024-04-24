package com.anhquan.unisync.utils

import io.reactivex.rxjava3.core.Completable
import io.reactivex.rxjava3.core.Observable
import io.reactivex.rxjava3.core.ObservableEmitter
import io.reactivex.rxjava3.core.Scheduler
import io.reactivex.rxjava3.core.Single
import io.reactivex.rxjava3.disposables.Disposable
import io.reactivex.rxjava3.schedulers.Schedulers
import java.util.concurrent.TimeUnit

fun runSingle(
    subscribeOn: Scheduler = Schedulers.io(),
    onError: ((Throwable) -> Unit)? = null,
    callback: () -> Unit,
) {
    lateinit var disposable: Disposable
    disposable = Completable.create {
        try {
            callback.invoke()
            it.onComplete()
        } catch (e: Exception) {
            it.onError(e)
        }
    }.subscribeOn(subscribeOn).subscribe({
        disposable.dispose()
    }, {
        try {
            onError?.invoke(it)
            it.printStackTrace()
        } catch (e: Exception) {
            e.printStackTrace()
        } finally {
            disposable.dispose()
        }
    })
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
    onResult: (T) -> Unit,
    onError: ((Throwable) -> Unit)? = null,
    cancelOnError: Boolean = false,
) {
    lateinit var disposable: Disposable
    disposable =
        Observable.create(task).subscribeOn(subscribeOn).observeOn(observeOn).subscribe(onResult, {
            onError?.invoke(it)
            it.printStackTrace()
            if (cancelOnError) {
                disposable.dispose()
            }
        }, {
            disposable.dispose()
        })
}

fun <T : Any> Observable<T>.listen(
    subscribeOn: Scheduler = Schedulers.io(),
    observeOn: Scheduler = Schedulers.io(),
    onError: (Throwable) -> Unit = { errorLog(it.message); it.printStackTrace() },
    onNext: (T) -> Unit
): Disposable {
    return this.subscribeOn(subscribeOn).observeOn(observeOn).subscribe(onNext, onError)
}

fun <T : Any> Observable<T>.execute(
    subscribeOn: Scheduler = Schedulers.io(),
    observeOn: Scheduler = Schedulers.io(),
    onError: ((Throwable) -> Unit)? = null,
    onNext: (T) -> Boolean
) {
    lateinit var disposable: Disposable
    disposable = this.subscribeOn(subscribeOn).observeOn(observeOn).subscribe({
        if (onNext(it)) {
            disposable.dispose()
        }
    }, {
        onError?.invoke(it)
        errorLog(it.message)
        it.printStackTrace()
        disposable.dispose()
    })
}

fun <T : Any> Single<T>.listen(
    subscribeOn: Scheduler = Schedulers.io(),
    observeOn: Scheduler = Schedulers.io(),
    onError: (Throwable) -> Unit = { errorLog(it); it.printStackTrace() },
    onResult: (T) -> Unit
): Disposable {
    return this.subscribeOn(subscribeOn).observeOn(observeOn).subscribe(onResult, onError)
}

fun <T : Any> Single<T>.execute(
    subscribeOn: Scheduler = Schedulers.io(),
    observeOn: Scheduler = Schedulers.io(),
    onError: ((Throwable) -> Unit)? = null,
    onSuccess: (T) -> Unit
) {
    lateinit var disposable: Disposable
    disposable = this.subscribeOn(subscribeOn).observeOn(observeOn).subscribe({
        onSuccess(it)
        disposable.dispose()
    }, {
        onError?.invoke(it)
        errorLog(it.message)
        it.printStackTrace()
        disposable.dispose()
    })
}

fun Completable.listen(
    subscribeOn: Scheduler = Schedulers.io(),
    observeOn: Scheduler = Schedulers.io(),
    onError: (Throwable) -> Unit = { errorLog(it); it.printStackTrace() },
    onResult: () -> Unit
): Disposable {
    return this.subscribeOn(subscribeOn).observeOn(observeOn).subscribe(
        onResult, onError
    )
}

fun Completable.execute(
    subscribeOn: Scheduler = Schedulers.io(),
    observeOn: Scheduler = Schedulers.io(),
    onError: ((Throwable) -> Unit)? = null,
    onComplete: (() -> Unit)? = null,
) {
    lateinit var disposable: Disposable
    disposable = this.subscribeOn(subscribeOn).observeOn(observeOn).subscribe({
        onComplete?.invoke()
        disposable.dispose()
    }, {
        onError?.invoke(it)
        errorLog(it.message)
        it.printStackTrace()
        disposable.dispose()
    })
}

fun delay(timeMillis: Long = 500, callback: () -> Unit): Disposable {
    return Observable.timer(timeMillis, TimeUnit.MILLISECONDS).subscribe {
        callback.invoke()
    }
}