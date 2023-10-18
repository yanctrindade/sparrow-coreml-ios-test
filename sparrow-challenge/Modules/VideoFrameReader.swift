import Foundation
import AVKit
import UIKit


class VideoFrameReader {
    var asset: AVAsset
    let reader: AVAssetReader
    var output: AVAssetReaderTrackOutput
    var videoSize: CGSize
    var videoTransform: CGAffineTransform

    init?(url: URL) {
        asset = AVAsset(url: url)
        guard let assetReader = try? AVAssetReader(asset: asset) else {
            return nil
        }
        reader = assetReader

        guard let videoTrack = asset.tracks(withMediaType: .video).first else {
            return nil
        }
        self.videoSize = videoTrack.naturalSize
        self.videoTransform = videoTrack.preferredTransform

        let outputSettings: [String: Any] = [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_420YpCbCr8BiPlanarFullRange]

        output = AVAssetReaderTrackOutput(track: videoTrack, outputSettings: outputSettings)
        output.alwaysCopiesSampleData = false
        reader.add(output)
    }

    func readNextFrame() -> CMSampleBuffer? {
        if reader.status == .unknown {
            reader.startReading()
        }

        if reader.status == .reading {
            if let sampleBuffer = output.copyNextSampleBuffer() {
                return sampleBuffer
            }
        }

        if reader.status == .completed {
            reader.cancelReading()
        }

        return nil
    }

    private func imageFromSampleBuffer(sampleBuffer: CMSampleBuffer) -> UIImage? {
        guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return nil }
        
        let ciImage = CIImage(cvPixelBuffer: imageBuffer)
        let context = CIContext(options: nil)
        guard let cgImage = context.createCGImage(ciImage, from: ciImage.extent) else { return nil }
        
        return UIImage(cgImage: cgImage)
    }
}
