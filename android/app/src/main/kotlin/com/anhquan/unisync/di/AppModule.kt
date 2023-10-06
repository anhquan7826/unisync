package com.anhquan.unisync.di

import android.content.Context
import android.content.SharedPreferences
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
    fun provideConnectionRepository(config: ConfigRepository): PairingRepository {
        return PairingRepositoryImpl(config)
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
    fun provideGson(): Gson {
        return Gson()
    }
}