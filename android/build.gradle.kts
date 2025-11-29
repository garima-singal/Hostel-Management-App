plugins {
    id("com.google.gms.google-services") version "4.3.15" apply false
    kotlin("android") version "2.1.0" apply false
}


buildscript {
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        // This forces Kotlin to the version you want
        classpath("org.jetbrains.kotlin:kotlin-gradle-plugin:2.1.0")
    }
}


allprojects {
    repositories {
        google()
        mavenCentral()
//        maven {
//            url = uri("https://maven.regulaforensics.com/RegulaDocumentReader/Beta")
//        }
    }
}

val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}

