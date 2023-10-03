package com.anhquan.unisync.di

import android.content.Context
import android.content.SharedPreferences
import com.anhquan.unisync.constants.SPKey
import com.anhquan.unisync.models.ClientInfo
import com.anhquan.unisync.repository.ConnectionRepository
import com.anhquan.unisync.repository.ConnectionRepositoryImpl
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
        sharedPreferences: SharedPreferences,
        gson: Gson
    ): ConnectionRepository {
        return ConnectionRepositoryImpl(
            gson.fromJson(
                sharedPreferences.getString(
                    SPKey.clientInfo,
                    ""
                ), ClientInfo::class.java
            )
        )
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