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
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
    
    // 统一设置 JVM 目标版本（使用 17 以匹配某些插件的 Java 版本）
    tasks.withType<JavaCompile>().configureEach {
        sourceCompatibility = JavaVersion.VERSION_17.toString()
        targetCompatibility = JavaVersion.VERSION_17.toString()
    }
    
    tasks.withType<org.jetbrains.kotlin.gradle.tasks.KotlinCompile>().configureEach {
        kotlinOptions {
            jvmTarget = JavaVersion.VERSION_17.toString()
        }
    }
    
    // 为所有 Android 库项目自动设置 namespace 和编译选项
    plugins.withId("com.android.library") {
        project.afterEvaluate {
            val android = project.extensions.getByName("android")
            
            // 设置编译选项（通过反射）
            try {
                val compileOptions = android::class.java.getMethod("getCompileOptions").invoke(android)
                compileOptions::class.java.getMethod("setSourceCompatibility", String::class.java)
                    .invoke(compileOptions, JavaVersion.VERSION_11.toString())
                compileOptions::class.java.getMethod("setTargetCompatibility", String::class.java)
                    .invoke(compileOptions, JavaVersion.VERSION_11.toString())
            } catch (e: Exception) {
                // 如果反射失败，忽略错误
            }
        }
        
        val android = project.extensions.getByName("android")
        
        // 尝试获取当前 namespace
        var currentNamespace: String? = null
        try {
            val getNamespaceMethod = android::class.java.declaredMethods
                .firstOrNull { it.name == "getNamespace" || (it.name == "namespace" && it.parameterCount == 0) }
            if (getNamespaceMethod != null) {
                currentNamespace = getNamespaceMethod.invoke(android) as? String
            }
        } catch (e: Exception) {
            // 忽略错误，继续尝试设置
        }
        
        // 如果 namespace 未设置，尝试从 AndroidManifest.xml 读取或使用默认值
        if (currentNamespace.isNullOrEmpty()) {
            val manifestFile = project.file("src/main/AndroidManifest.xml")
            var namespaceToSet: String? = null
            
            if (manifestFile.exists()) {
                val manifestContent = manifestFile.readText()
                val packageMatch = Regex("package=\"([^\"]+)\"").find(manifestContent)
                if (packageMatch != null) {
                    namespaceToSet = packageMatch.groupValues[1]
                }
            } else {
                // 对于 flutter_statusbarcolor_ns 插件，使用默认 namespace
                if (project.name == "flutter_statusbarcolor_ns") {
                    namespaceToSet = "com.tekartik.flutterstatusbarcolor"
                }
            }
            
            if (namespaceToSet != null) {
                try {
                    // 尝试使用 setNamespace 方法
                    val setNamespaceMethod = android::class.java.declaredMethods
                        .firstOrNull { it.name == "setNamespace" || (it.name == "namespace" && it.parameterCount == 1) }
                    if (setNamespaceMethod != null) {
                        setNamespaceMethod.invoke(android, namespaceToSet)
                        println("✅ 为项目 ${project.name} 自动设置 namespace: $namespaceToSet")
                    } else {
                        // 尝试直接设置字段
                        val namespaceField = android::class.java.getDeclaredField("namespace")
                        namespaceField.isAccessible = true
                        namespaceField.set(android, namespaceToSet)
                        println("✅ 为项目 ${project.name} 自动设置 namespace: $namespaceToSet")
                    }
                } catch (e: Exception) {
                    println("⚠️ 无法为项目 ${project.name} 设置 namespace: ${e.message}")
                }
            }
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
