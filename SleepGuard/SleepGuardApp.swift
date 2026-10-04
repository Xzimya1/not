import SwiftUI

@main
struct SleepGuardApp: App {
    @StateObject private var model = SleepGuardModel()

    var body: some Scene {
        WindowGroup("SleepGuard") {
            ContentView()
                .environmentObject(model)
                .frame(minWidth: 980, minHeight: 680)
        }
        .windowResizability(.contentSize)
    }
}
