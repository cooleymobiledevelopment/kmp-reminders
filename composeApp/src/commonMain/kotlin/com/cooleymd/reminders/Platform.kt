package com.cooleymd.reminders

interface Platform {
    val name: String
}

expect fun getPlatform(): Platform