plugins { kotlin("jvm") version "2.2.10"; application }
repositories { mavenCentral() }
kotlin { jvmToolchain(21) }
// Main class macie ustalić w planie technicznym i implementacji.


tasks.register("compile") {
    group = "build"
    description = "Compiles the current Kotlin solution"
    dependsOn(tasks.compileKotlin)
}
