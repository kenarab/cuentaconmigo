import java.util.Properties

plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
    id("org.jetbrains.kotlin.plugin.compose")
}

// Team defaults (git-ignored): ../../.private/server.json -> server URL and app enrollment code.
val serverConfig = rootProject.file("../.private/server.json").takeIf { it.exists() }?.readText()
fun jsonField(name: String): String =
    serverConfig?.let { Regex("\"$name\"\\s*:\\s*\"([^\"]*)\"").find(it)?.groupValues?.get(1) } ?: ""

android {
    namespace = "ar.cuentaconmigo.app"
    compileSdk = 35

    defaultConfig {
        applicationId = "ar.cuentaconmigo.app"
        minSdk = 26
        targetSdk = 35
        versionCode = 1
        versionName = "0.1.0"
        buildConfigField("String", "DEFAULT_SERVER_URL",
            "\"${jsonField("url").ifEmpty { "https://newbery.duckdns.org/cuentaconmigo" }}\"")
        buildConfigField("String", "APP_ENROLL_CODE", "\"${jsonField("enrollmentCode")}\"")
    }

    buildTypes {
        release {
            isMinifyEnabled = false
        }
    }
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }
    kotlinOptions {
        jvmTarget = "17"
    }
    testOptions {
        unitTests.isReturnDefaultValues = true
    }
    buildFeatures {
        compose = true
        buildConfig = true
    }
}

dependencies {
    implementation(platform("androidx.compose:compose-bom:2024.06.00"))
    implementation("androidx.compose.material3:material3")
    implementation("androidx.compose.material:material-icons-extended")
    implementation("androidx.compose.ui:ui")
    implementation("androidx.activity:activity-compose:1.9.1")
    implementation("androidx.lifecycle:lifecycle-runtime-ktx:2.8.4")
    // UniFFI's Kotlin bindings load the Rust core through JNA.
    implementation("net.java.dev.jna:jna:5.14.0@aar")

    // JVM tests load the host build of the core through the same generated bindings.
    testImplementation("junit:junit:4.13.2")
    testImplementation("net.java.dev.jna:jna:5.14.0")
}

tasks.withType<Test>().configureEach {
    val target = System.getenv("CARGO_TARGET_DIR") ?: "${System.getProperty("user.home")}/home.codex/tmp/cc-core-target"
    systemProperty("jna.library.path", "$target/release")
    environment("CC_TEST_SERVER", System.getenv("CC_TEST_SERVER") ?: "")
    environment("CC_TEST_JPEG", System.getenv("CC_TEST_JPEG") ?: "")
}
