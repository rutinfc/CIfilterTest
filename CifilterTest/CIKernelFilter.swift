//
//  CIKernelFilter.swift
//  CifilterTest
//
//  Created by jeongkyu kim on 11/12/2018.
//  Copyright © 2018 jeongkyu kim. All rights reserved.
//

import UIKit
import MobileCoreServices

extension CGImagePropertyOrientation {
    init(_ uiOrientation: UIImage.Orientation) {
        switch uiOrientation {
        case .up: self = .up
        case .upMirrored: self = .upMirrored
        case .down: self = .down
        case .downMirrored: self = .downMirrored
        case .left: self = .left
        case .leftMirrored: self = .leftMirrored
        case .right: self = .right
        case .rightMirrored: self = .rightMirrored
        }
    }
}

class CIKernelFilter {
    
    static let instance = CIKernelFilter()
    
    let ditherBayer = Bundle.main.path(forResource: "DitherBayer", ofType: "cikernel")
    var gslsText : String?
    
    private func measure(label: String? = nil, _ block: @escaping () -> Void) -> CFAbsoluteTime {
        let start = CFAbsoluteTimeGetCurrent()
        block()
        let end = CFAbsoluteTimeGetCurrent()
        if let label = label {
            print(label, "▿")
            print("\tExecution time: \(end - start)s\n")
        } else {
            print("Execution time: \(end - start)s\n")
        }
        return end - start
    }
    
    init() {
        guard let path = ditherBayer,
            let code = try? String(contentsOfFile: path) else {
                return
        }
        
        self.gslsText = code
    }
    
    func apply(kernel:CIKernel, image:UIImage) -> UIImage? {
        
        guard let cgImage = image.cgImage else {
            return nil
        }
        
        let inputIntensity = CGFloat(0.2)
        
        let ciImage = CIImage(cgImage: cgImage, options: [CIImageOption.applyOrientationProperty  : true])
        let inputImage = ciImage.oriented(CGImagePropertyOrientation(image.imageOrientation))
        let extent = inputImage.extent
        
        let arguments = [inputImage, inputIntensity] as [Any]
        let callback : CIKernelROICallback = { (value, rect) in
            return rect
        }
        
        guard let output = kernel.apply(extent: extent, roiCallback: callback, arguments: arguments) else {
            return nil
        }
        
        let context = CIContext(options: nil)
        
        guard let result = context.createCGImage(output, from: output.extent) else {
            return nil
        }
        
        let path = NSTemporaryDirectory().appending("test.gif")
        let fileURL = URL(fileURLWithPath: path)
        
        guard let dest = CGImageDestinationCreateWithURL(fileURL as CFURL, kUTTypeGIF, 1, nil) else {
            return nil
        }
        
        CGImageDestinationAddImage(dest, result, nil)
        CGImageDestinationFinalize(dest)
        
        return UIImage(contentsOfFile: path)
    }
    
    func applyForMetal(image:UIImage) -> UIImage? {
        
        guard let url = Bundle.main.url(forResource: "default", withExtension: "metallib") else {
            return nil
        }
        
        guard let data = try? Data(contentsOf: url) else {
            return nil
        }
        
        
        guard let kernel = try? CIKernel(functionName: "dither", fromMetalLibraryData: data) else {
            return nil
        }
        
        var result : UIImage? = nil
        
        _ = self.measure(label:"Metal") {
            result = self.apply(kernel: kernel, image: image)
        }
        
        return result
    }
    
    func apply(image:UIImage) -> UIImage? {
        
        guard let code = self.gslsText else {
            return nil
        }
        
        guard let kernel = CIKernel(source: code) else {
            return nil
        }
        
        var result : UIImage? = nil
        
        _ = self.measure(label:"GLSL") {
            result = self.apply(kernel: kernel, image: image)
        }
        
        return result
    }
}
