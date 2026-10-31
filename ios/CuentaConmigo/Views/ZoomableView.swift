import SwiftUI
import UIKit

/// Native pinch-to-zoom and pan around SwiftUI content (UIScrollView), with double tap
/// to zoom in or back out. Buttons inside the content keep receiving taps.
struct ZoomableView<Content: View>: UIViewRepresentable {
    let contentSize: CGSize
    var maxZoom: CGFloat = 6
    @ViewBuilder let content: () -> Content

    func makeCoordinator() -> Coordinator { Coordinator(host: UIHostingController(rootView: content())) }

    func makeUIView(context: Context) -> UIScrollView {
        let scroll = UIScrollView()
        scroll.delegate = context.coordinator
        scroll.minimumZoomScale = 1
        scroll.maximumZoomScale = maxZoom
        scroll.bouncesZoom = true
        scroll.showsHorizontalScrollIndicator = false
        let host = context.coordinator.host
        host.view.backgroundColor = .clear
        host.view.frame = CGRect(origin: .zero, size: contentSize)
        scroll.addSubview(host.view)
        scroll.contentSize = contentSize
        let doubleTap = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.doubleTapped(_:)))
        doubleTap.numberOfTapsRequired = 2
        scroll.addGestureRecognizer(doubleTap)
        return scroll
    }

    func updateUIView(_ scroll: UIScrollView, context: Context) {
        let host = context.coordinator.host
        host.rootView = content()
        let size = CGSize(width: contentSize.width * scroll.zoomScale, height: contentSize.height * scroll.zoomScale)
        if host.view.bounds.size != contentSize {
            host.view.bounds = CGRect(origin: .zero, size: contentSize)
            host.view.frame = CGRect(origin: .zero, size: size)
            scroll.contentSize = size
        }
    }

    final class Coordinator: NSObject, UIScrollViewDelegate {
        let host: UIHostingController<Content>
        init(host: UIHostingController<Content>) { self.host = host }

        func viewForZooming(in scrollView: UIScrollView) -> UIView? { host.view }

        @objc func doubleTapped(_ gesture: UITapGestureRecognizer) {
            guard let scroll = gesture.view as? UIScrollView else { return }
            if scroll.zoomScale > 1.01 {
                scroll.setZoomScale(1, animated: true)
            } else {
                let point = gesture.location(in: host.view)
                let size = CGSize(width: scroll.bounds.width / 3, height: scroll.bounds.height / 3)
                scroll.zoom(to: CGRect(x: point.x - size.width / 2, y: point.y - size.height / 2,
                                       width: size.width, height: size.height), animated: true)
            }
        }
    }
}
