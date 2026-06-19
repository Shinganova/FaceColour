package com.facecolour.app.data

import com.facecolour.app.engine.Season
import com.facecolour.app.engine.ShadeReference
import com.google.gson.Gson
import org.junit.Assert.assertEquals
import org.junit.Test

class DataParsingTest {
    private val gson = Gson()

    @Test fun parsesSeasonGuideBook() {
        val json = """
            {"spring":{"title":"Spring","summary":"s","palette":[{"name":"Coral","hex":"#FF7F50"}],"avoid":[]},
             "summer":{"title":"Summer","summary":"s","palette":[],"avoid":[]},
             "autumn":{"title":"Autumn","summary":"s","palette":[],"avoid":[]},
             "winter":{"title":"Winter","summary":"s","palette":[],"avoid":[]}}
        """.trimIndent()
        val book = gson.fromJson(json, SeasonGuideBook::class.java)
        assertEquals("Spring", book.spring.title)
        assertEquals("Coral", book[Season.SPRING].palette.first().name)
        assertEquals("Winter", book[Season.WINTER].title)
    }

    @Test fun parsesShades() {
        val json = """{"tones":[{"tone":1,"hex":"#f6ede4"},{"tone":10,"hex":"#292420"}]}"""
        val ref = gson.fromJson(json, ShadeReference::class.java)
        assertEquals(2, ref.tones.size)
        assertEquals(1, ref.tones.first().tone)
        assertEquals("#292420", ref.tones.last().hex)
    }
}
