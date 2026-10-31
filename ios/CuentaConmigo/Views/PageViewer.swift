import SwiftUI

/// Full-screen view of a stored page with native pinch to zoom, pan and double tap.
struct PageViewer: View {
    let url: URL
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            GeometryReader { geo in
                if let image = UIImage(contentsOfFile: url.path) {
                    let width = geo.size.width
                    let height = image.size.height * width / max(1, image.size.width)
                    ZoomableView(contentSize: CGSize(width: width, height: height)) {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(width: width, height: height)
                            .accessibilityLabel("Imagen del documento")
                    }
                } else {
                    ContentUnavailableView("No se encontró la imagen", systemImage: "photo")
                }
            }
            .navigationTitle("Pellizcá para ampliar")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) { Button("Listo") { dismiss() } }
            }
        }
    }
}
