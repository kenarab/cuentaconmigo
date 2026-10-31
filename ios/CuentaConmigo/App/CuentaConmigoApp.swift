import SwiftUI

@main
struct CuentaConmigoApp: App {
    @State private var store = CaptureStore()

    var body: some Scene {
        WindowGroup {
            HomeView()
                .environment(store)
                .task { await ServerSettings.connectIfNeeded(appVersion: CaptureStore.appInfo.version) }
        }
    }
}
