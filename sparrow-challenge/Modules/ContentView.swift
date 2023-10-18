import SwiftUI
import CoreML
import Vision
import AVFoundation

struct ContentView: View {
    @StateObject private var videoViewModel = VideoPlayerViewModel()
    @State private var isPickerPresented: Bool = false

    var body: some View  {
        VStack {
            if let url = videoViewModel.videoURL {
                VideoViewPlayer(url: url)
                    .environmentObject(videoViewModel)
            } else {
                Button("Pick Video") {
                    isPickerPresented = true
                }
            }
        }.sheet(isPresented: $isPickerPresented) {
            VideoPicker(videoURL: $videoViewModel.videoURL)
        }
    }

}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
