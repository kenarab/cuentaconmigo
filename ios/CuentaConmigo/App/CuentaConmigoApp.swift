import SwiftUI

@main
struct CuentaConmigoApp: App {
    @State private var store = CaptureStore()

    var body: some Scene {
        WindowGroup {
            HomeView()
                .environment(store)
        }
    }
}
