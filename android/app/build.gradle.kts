import java.io.File

plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
    id("dev.flutter.flutter-gradle-plugin")
}

/*
 * Read key.properties manually as UTF-8.
 *
 * This avoids java.util.Properties changing/interpreting
 * special characters inside passwords.
 */
val keystorePropertiesFile = rootProject.file("key.properties")

val keystoreProperties: Map<String, String> =
    if (keystorePropertiesFile.exists()) {
        keystorePropertiesFile
            .readLines(Charsets.UTF_8)
            .filter {
                it.isNotBlank() &&
                !it.trimStart().startsWith("#")
            }
            .associate { line ->
                val index = line.indexOf('=')

                require(index > 0) {
                    "Invalid line in key.properties"
                }

                val key = line
                    .substring(0, index)
                    .trim()

                // Do NOT trim the password/value.
                // Everything after the first "=" is preserved literally.
                val value = line.substring(index + 1)

                key to value
            }
    } else {
        emptyMap()
    }

/*
 * Safe debugging.
 *
 * This DOES NOT print the actual passwords.
 * It only prints their lengths and signing metadata.
 *
 * Remove this block after signing works.
 */
println(
    "SIGNING CHECK: " +
        "storeLength=${keystoreProperties["storePassword"]?.length}, " +
        "keyLength=${keystoreProperties["keyPassword"]?.length}, " +
        "alias=${keystoreProperties["keyAlias"]}, " +
        "file=${keystoreProperties["storeFile"]}"
)

android {
    namespace = "com.olimata.planty"
    compileSdk = 37
    ndkVersion = "28.2.13676358"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "com.olimata.planty"

        minSdk = flutter.minSdkVersion
        targetSdk = 37

        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {

            val releaseStoreFile =
                keystoreProperties["storeFile"]
                    ?: error(
                        "storeFile is missing from android/key.properties"
                    )

            val releaseStorePassword =
                keystoreProperties["storePassword"]
                    ?: error(
                        "storePassword is missing from android/key.properties"
                    )

            val releaseKeyAlias =
                keystoreProperties["keyAlias"]
                    ?: error(
                        "keyAlias is missing from android/key.properties"
                    )

            val releaseKeyPassword =
                keystoreProperties["keyPassword"]
                    ?: error(
                        "keyPassword is missing from android/key.properties"
                    )

            storeFile = file(releaseStoreFile)

            storePassword = releaseStorePassword

            keyAlias = releaseKeyAlias

            keyPassword = releaseKeyPassword

            /*
             * Our new release keystore was explicitly created
             * using -storetype JKS.
             */
            storeType = "JKS"
        }
    }

    buildTypes {
        release {
            signingConfig =
                signingConfigs.getByName("release")
        }
    }
}

flutter {
    source = "../.."
}