import CoreML
import Vision
import CoreVideo
import UIKit

class CoreMLProcessor {
    
    private var visionModel: VNCoreMLModel?
    
    private var confidenceThreshold: Float = 0.3
    private var personIdentifier: String = "person"
    
    init?() {
        do {
            visionModel = try VNCoreMLModel(for: YOLOv3TinyFP16(configuration: MLModelConfiguration()).model)
        } catch {
            print("Failed to load model: \(error)")
            return nil
        }
    }
    
    func predict(pixelBuffer: CVPixelBuffer, completion: @escaping (VNRecognizedObjectObservation?) -> Void) {
        guard let visionModel = visionModel else { return }
        
        let request = VNCoreMLRequest(model: visionModel) { (request, error) in
            guard error == nil else {
                print("Error: \(error!.localizedDescription)")
                completion(nil)
                return
            }
            
            if let observations = request.results as? [VNRecognizedObjectObservation] {
                completion(observations.first)
            } else {
                completion(nil)
            }
        }
        
        do {
            try VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:]).perform([request])
        } catch {
            print("Failed to perform request: \(error)")
            completion(nil)
        }
    }
}
