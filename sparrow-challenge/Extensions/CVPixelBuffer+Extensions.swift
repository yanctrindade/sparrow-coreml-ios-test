import CoreVideo

extension CVPixelBuffer {
    public var width: Int { CVPixelBufferGetWidth(self) }
    public var height: Int { CVPixelBufferGetHeight(self) }
    public var size: Int.Size { (width: width, height: height) }
}


