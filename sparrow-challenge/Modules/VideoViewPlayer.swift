import SwiftUI
import UIKit

struct VideoViewPlayer: View {
    @EnvironmentObject var viewModel: VideoPlayerViewModel
    var url: URL
    var body: some View {
        ZStack {
            if let image = viewModel.image {
                Image(image, scale: 1.0, label: Text(""))
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            }
            Rectangle()
                .fill(.clear)
                .frame(width: viewModel.rectangleFrame.size.width, height: viewModel.rectangleFrame.size.height)
                .border(viewModel.bboxColor, width: 2)
                .position(x: viewModel.rectangleFrame.midX, y: viewModel.rectangleFrame.midY)
                .animation(.easeInOut(duration: 0.3), value: viewModel.rectangleFrame)
        }
        .background(GeometryReader { geometry in
            Color.clear.onAppear {
                viewModel.viewSize = geometry.size
            }
        })
        .onAppear {
            DispatchQueue.global(qos: .userInitiated).async {
                viewModel.processVideo(from: viewModel.videoURL ?? url)
            }
        }
    }
}

struct ImageView: UIViewRepresentable {
    var image: UIImage?

    func makeUIView(context: Context) -> UIImageView {
        let imageView = UIImageView()
        imageView.contentMode = .center
        return imageView
    }

    func updateUIView(_ uiView: UIImageView, context: Context) {
        uiView.image = image
    }
}
