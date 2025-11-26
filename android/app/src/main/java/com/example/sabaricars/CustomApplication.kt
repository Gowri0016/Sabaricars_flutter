package com.sabaricars.app

import android.app.Application
import com.google.android.recaptcha.Recaptcha
import com.google.android.recaptcha.RecaptchaClient
import com.google.android.recaptcha.RecaptchaException
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext

class CustomApplication : Application() {
    // Companion object to hold the singleton RecaptchaClient instance
    companion object {
        private const val SITE_KEY = "6Le2hKArAAAAABnqOV2aKFINUo_dvleVQ0JR4nxc" // <-- Make sure this is your actual site key
        lateinit var recaptchaClient: RecaptchaClient
    }

    // Override the onCreate method to initialize the reCAPTCHA client
    override fun onCreate() {
        super.onCreate()
        
        // Use a coroutine scope with Dispatchers.IO for network-related work
        CoroutineScope(Dispatchers.IO).launch {
            try {
                // Initialize the Recaptcha client using the recommended getClient method
                Recaptcha.getClient(this@CustomApplication, SITE_KEY)
                    .onSuccess { client ->
                        recaptchaClient = client
                    }
                    .onFailure { exception ->
                        // Handle the exception, for example by logging the error on the main thread
                        withContext(Dispatchers.Main) {
                            println("Recaptcha initialization failed: ${exception.message}")
                        }
                    }
            } catch (e: RecaptchaException) {
                // Handle any other exceptions that might occur
                withContext(Dispatchers.Main) {
                    println("Recaptcha initialization failed: ${e.message}")
                }
            }
        }
    }
}
