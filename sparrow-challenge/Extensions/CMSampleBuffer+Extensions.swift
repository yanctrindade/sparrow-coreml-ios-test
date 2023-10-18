import CoreMedia

extension CMSampleBuffer {
    public var pixelBuffer: CVPixelBuffer? { CMSampleBufferGetImageBuffer(self) }
}
