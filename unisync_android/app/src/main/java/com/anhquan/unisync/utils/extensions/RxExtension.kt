package com.anhquan.unisync.utils.extensions

import io.reactivex.rxjava3.disposables.CompositeDisposable
import io.reactivex.rxjava3.disposables.Disposable

fun Disposable.addTo(disposable: CompositeDisposable) {
    disposable.add(this)
}