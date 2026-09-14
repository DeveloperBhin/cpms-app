// import org.gradle.api.tasks.compile.JavaCompile
// import org.jetbrains.kotlin.gradle.tasks.KotlinCompile
// import org.jetbrains.kotlin.gradle.dsl.JvmTarget

// allprojects {
//     repositories {
//         google()
//         mavenCentral()
//     }
// }

// val newBuildDir: Directory =
//     rootProject.layout.buildDirectory
//         .dir("../../build")
//         .get()

// rootProject.layout.buildDirectory.value(newBuildDir)

// subprojects {
//     val newSubprojectBuildDir: Directory =
//         newBuildDir.dir(project.name)

//     project.layout.buildDirectory.value(newSubprojectBuildDir)
// }

// subprojects {
//     project.evaluationDependsOn(":app")

//     tasks.withType<JavaCompile>().configureEach {
//         options.release.set(null)
//         sourceCompatibility = "17"
//         targetCompatibility = "17"
//     }

//     tasks.withType<KotlinCompile>().configureEach {
//         compilerOptions {
//             jvmTarget.set(JvmTarget.JVM_17)
//         }
//     }
// }

// project(":tflite_flutter") {
//     tasks.withType<JavaCompile>().configureEach {
//         options.release.set(null)
//         sourceCompatibility = "17"
//         targetCompatibility = "17"
//     }

//     tasks.withType<KotlinCompile>().configureEach {
//         compilerOptions {
//             jvmTarget.set(JvmTarget.JVM_17)
//         }
//     }
// }

// tasks.register<Delete>("clean") {
//     delete(rootProject.layout.buildDirectory)
// }

import org.jetbrains.kotlin.gradle.tasks.KotlinCompile
import org.jetbrains.kotlin.gradle.dsl.JvmTarget

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()

rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory =
        newBuildDir.dir(project.name)

    project.layout.buildDirectory.value(newSubprojectBuildDir)

    project.evaluationDependsOn(":app")
}

/*
 * file_picker:
 * Java = 11, therefore Kotlin must also use JVM 11.
 */
project(":file_picker") {
    tasks.withType<KotlinCompile>().configureEach {
        compilerOptions {
            jvmTarget.set(JvmTarget.JVM_11)
        }
    }
}

/*
 * tflite_flutter:
 * Java = 17, therefore Kotlin must also use JVM 17.
 */
project(":tflite_flutter") {
    tasks.withType<KotlinCompile>().configureEach {
        compilerOptions {
            jvmTarget.set(JvmTarget.JVM_17)
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}