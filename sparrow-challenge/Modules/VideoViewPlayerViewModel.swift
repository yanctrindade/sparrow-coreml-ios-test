import SwiftUI
import CoreML
import Vision
import CoreImage
import AVFoundation

class VideoPlayerViewModel: ObservableObject {
    @Published var videoURL: URL?
    @Published var rectangleFrame: CGRect = .zero
    @Published var image: CGImage?
    @Published var bboxColor: Color = .red
    var viewSize = CGSize()
    var videoSize = CGSize()
    var frameCount = 0
    var coreMLProcessor: CoreMLProcessor?
    
    private let processingQueue = DispatchQueue(label: "VideoProcessing", qos: .userInteractive)
    
    init() {
        self.coreMLProcessor = CoreMLProcessor()
    }
    
    func processVideo(from url: URL) {
        guard let processor = self.coreMLProcessor else {
            //TODO: better error handling/logging
            fatalError("Couldn't load the CoreMLProcessor")
        }

        guard let frameReader = VideoFrameReader(url: url) else {
            //TODO: better error handling/logging
            fatalError("Couldn't load the video url")
        }
        self.videoSize = frameReader.videoSize

        processingQueue.async {
            while let frame = frameReader.readNextFrame() {
                guard let pixelBuffer = frame.pixelBuffer else {
                    //TODO: Add logging
                    continue
                }
                
                if let cgImage = self.createCGImage(from: pixelBuffer, orientation: self.orientation(from: frameReader.videoTransform)),
                   let pixelbuffer = self.createPixelBuffer(from: cgImage)
                {
                    processor.predict(pixelBuffer: pixelbuffer) { observation in
                        DispatchQueue.main.async {
                            self.image = cgImage
                            if let observation = observation {
                                let convertedRect = self.convertBoundingBox(observation.boundingBox, from: cgImage, uiSize: self.viewSize)
                                self.bboxColor = self.isBoundingBoxHorizontallyCentered(boundingBox: convertedRect, in: self.viewSize) ? .green : .red
                                self.rectangleFrame = convertedRect
                            }
                        }
                    }
                }
            }
        }
    }
    
    private func createCGImage(from pixelBuffer: CVPixelBuffer, orientation: CGImagePropertyOrientation) -> CGImage? {
        var ciImage = CIImage(cvPixelBuffer: pixelBuffer)
        ciImage = ciImage.oriented(orientation)
        let context = CIContext(options: nil)
        return context.createCGImage(ciImage, from: ciImage.extent)
    }
    
    private func orientation(from transform: CGAffineTransform) -> CGImagePropertyOrientation {
        switch (transform.tx, transform.ty) {
        case (0, 0):
            return .up
        case (0, _):
            return .down
        case (_, 0):
            return .right
        default:
            return .left
        }
    }
    
    private func convertBoundingBox(_ boundingBox: CGRect, from cgImage: CGImage, uiSize: CGSize) -> CGRect {
        // Convert from normalized coordinates to image coordinates
        let imageSize = CGSize(width: cgImage.width, height: cgImage.height)
        
        let imageBoundingBox = CGRect(
            x: boundingBox.origin.x * imageSize.width,
            y: (1 - boundingBox.origin.y - boundingBox.height) * imageSize.height,
            width: boundingBox.width * imageSize.width,
            height: boundingBox.height * imageSize.height
        )
        
        // Determine scaling factors based on how the image fits into the UI size
        let xScale = uiSize.width / imageSize.width
        let yScale = uiSize.height / imageSize.height
        let minScale = min(xScale, yScale)
        
        let offsetX = (uiSize.width - imageSize.width * minScale) / 2.0
        let offsetY = (uiSize.height - imageSize.height * minScale) / 2.0
        
        // Convert to UI coordinates
        let uiBoundingBox = CGRect(
            x: imageBoundingBox.origin.x * minScale + offsetX,
            y: imageBoundingBox.origin.y * minScale + offsetY,
            width: imageBoundingBox.width * minScale,
            height: imageBoundingBox.height * minScale
        )
        
        return uiBoundingBox
    }
    
    private func createPixelBuffer(from cgImage: CGImage) -> CVPixelBuffer? {
        // 1. Create an empty CVPixelBuffer
        let width = cgImage.width
        let height = cgImage.height
        var pixelBuffer: CVPixelBuffer? = nil
        
        let status = CVPixelBufferCreate(kCFAllocatorDefault, width, height, kCVPixelFormatType_32BGRA, nil, &pixelBuffer)
        guard status == kCVReturnSuccess, let buffer = pixelBuffer else {
            return nil
        }
        
        // 2. Lock the memory of the CVPixelBuffer
        CVPixelBufferLockBaseAddress(buffer, [])
        
        // 3. Draw the CGImage onto the CVPixelBuffer's memory
        let pixelData = CVPixelBufferGetBaseAddress(buffer)
        
        let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
        let context = CGContext(data: pixelData, width: width, height: height, bitsPerComponent: 8, bytesPerRow: CVPixelBufferGetBytesPerRow(buffer), space: rgbColorSpace, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)
        
        context?.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
        
        // 4. Unlock the CVPixelBuffer
        CVPixelBufferUnlockBaseAddress(buffer, [])
        
        return buffer
    }
    
    private func isBoundingBoxHorizontallyCentered(boundingBox: CGRect, in viewBounds: CGSize, tolerance: CGFloat = 30.0) -> Bool {
        // 1. Find the horizontal center of the bounding box
        let boxCenterX = boundingBox.midX

        // 2. Find the horizontal center of the view
        let viewCenterX = viewBounds.width / 2

        // 3. Compare the two centers with a given tolerance
        return abs(boxCenterX - viewCenterX) <= tolerance
    }

}
