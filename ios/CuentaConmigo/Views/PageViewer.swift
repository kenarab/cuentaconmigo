import SwiftUI

/// Full-screen, zoomable view of a stored page.
struct PageViewer: View {
    let url: URL
    @Environment(\.dismiss) private var dismiss
    @State private var scale: CGFloat = 1

    var body: some View {
        NavigationStack {
            ScrollView([.horizontal, .vertical]) {
                if let image = UIImage(contentsOfFile: url.path) {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(width: UIScreen.main.bounds.width * scale)
                        .gesture(MagnifyGesture().onChanged { scale = max(1, min(6, $0.magnification)) })
                        .accessibilityLabel("Imagen del documento")
                }
            }
            .toolbar {
                ToolbarItem(placement: .confirmationAction) { Button("Listo") { dismiss() } }
            }
        }
    }
}
