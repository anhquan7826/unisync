package com.anhquan.unisync.di

import android.app.NotificationManager
import android.content.Context
import android.content.SharedPreferences
import android.net.ConnectivityManager
import android.net.wifi.WifiManager
import com.anhquan.unisync.repository.ConfigRepository
import com.anhquan.unisync.repository.PairingRepository
import com.anhquan.unisync.repository.impl.ConfigRepositoryImpl
import com.anhquan.unisync.repository.impl.PairingRepositoryImpl
import com.google.gson.Gson
import dagger.Module
import dagger.Provides
import dagger.hilt.InstallIn
import dagger.hilt.android.qualifiers.ApplicationContext
import dagger.hilt.components.SingletonComponent
import javax.inject.Singleton

@Module
@InstallIn(SingletonComponent::class)
class AppModule {
    @Singleton
    @Provides
    fun provideConnectionRepository(
        config: ConfigRepository,
        connectivityManager: ConnectivityManager,
        wifiManager: WifiManager
    ): PairingRepository {
        return PairingRepositoryImpl(config, connectivityManager, wifiManager)
    }

    @Singleton
    @Provides
    fun provideConfigRepository(
        @ApplicationContext context: Context,
        sp: SharedPreferences,
        gson: Gson
    ): ConfigRepository {
        return ConfigRepositoryImpl(context, sp, gson)
    }

    @Singleton
    @Provides
    fun provideSharedPreferences(@ApplicationContext context: Context): SharedPreferences {
        return context.getSharedPreferences(context.packageName, Context.MODE_PRIVATE)
    }

    @Singleton
    @Provides
    fun provideConnectivityManager(@ApplicationContext context: Context): ConnectivityManager {
        return context.getSystemService(ConnectivityManager::class.java)
    }

    fun provideNotificationManager(@ApplicationContext context: Context): NotificationManager {
        return context.getSystemService(NotificationManager::class.java)
    }

    @Singleton
    @Provides
    fun provideWifiManager(@ApplicationContext context: Context): WifiManager {
        return context.getSystemService(WifiManager::class.java)
    }

    @Singleton
    @Provides
    fun provideGson(): Gson {
        return Gson()
    }
}