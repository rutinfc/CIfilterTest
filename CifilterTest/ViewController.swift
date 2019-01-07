//
//  ViewController.swift
//  CifilterTest
//
//  Created by jeongkyu kim on 07/12/2018.
//  Copyright © 2018 jeongkyu kim. All rights reserved.
//

import UIKit
import AVFoundation
import Accelerate

class ViewController: UIViewController {
    
    @IBOutlet weak var source: SimpleScrollImageView!
    @IBOutlet weak var destination: SimpleScrollImageView!
    
    private let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.imagePicker.delegate = self
        self.imagePicker.allowsEditing = false
        self.imagePicker.sourceType = .photoLibrary
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    @IBAction func loadImage(_ sender: Any) {
        
        self.present(self.imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func doMetal(_ sender: Any) {
        
        guard let image = self.source.image else {
            return
        }
        
        self.destination.image = CIKernelFilter.instance.applyForMetal(image: image)
    }
    
    @IBAction func doCIKernel(_ sender: Any) {
        
        let apply = UIAlertAction(title: "Apply", style: .default) { (action) in
            
            guard let image = self.source.image else {
                return
            }
            
            self.destination.image = CIKernelFilter.instance.apply(image: image)
        }
        
        let glsl = UIAlertAction(title: "GLSL", style: .default) { (action) in
            self.performSegue(withIdentifier: "OpenGLSL", sender: nil)
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            
        }
        
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        alert.addAction(apply)
        alert.addAction(glsl)
        alert.addAction(cancel)
        alert.preferredAction = apply
        
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func doCIRender(_ sender: Any) {
        
    }
    
    @IBAction func doVImage(_ sender: Any) {
        
        guard let srcImage = self.source.image?.cgImage
            , let colorspace = srcImage.colorSpace
            else {
                return
        }
        
        var srcBuffer = vImage_Buffer()
        var format = vImage_CGImageFormat(
            bitsPerComponent: UInt32(srcImage.bitsPerComponent),
            bitsPerPixel: UInt32(srcImage.bitsPerPixel),
            colorSpace: nil,
            bitmapInfo: srcImage.bitmapInfo,
            version: 0,
            decode: nil,
            renderingIntent: CGColorRenderingIntent.defaultIntent)
        
        vImageBuffer_InitWithCGImage(&srcBuffer, &format, nil, srcImage, UInt32(kvImageNoFlags))
        
        let pixelBuffer = malloc(Int(srcImage.bytesPerRow) * Int(srcImage.height))
        
        defer {
            free(pixelBuffer)
        }
        
        let height = vImagePixelCount(srcImage.height)
        let width = vImagePixelCount(srcImage.width)
        
        var destBuffer = vImage_Buffer(data: pixelBuffer, height: height, width: width, rowBytes: srcImage.bytesPerRow)
        
        let bytePerRow = srcImage.width * (srcImage.bitsPerPixel / srcImage.bitsPerComponent)
        
        
        //let error = vImageConvert_RGB16UtoRGB888_dithered(&srcBuffer, &destBuffer, Int32(kvImageConvert_DitherOrdered), UInt32(kvImageDoNotTile))
        
//        if error != kvImageNoError {
//            print("ERROR : \(error)")
//            return
//        }
        
        let context = CGContext(data: destBuffer.data, width:srcImage.width, height:srcImage.height, bitsPerComponent: srcImage.bitsPerComponent, bytesPerRow: bytePerRow, space: colorspace, bitmapInfo: srcImage.alphaInfo.rawValue)
        
        if let outCgImage = context?.makeImage() {
            self.destination.image = UIImage(cgImage: outCgImage)
        }
    }
}

extension ViewController : UINavigationControllerDelegate {
    
}

extension ViewController : UIImagePickerControllerDelegate {
    
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            
            self.source.image = pickedImage
        }
        
        self.dismiss(animated: true, completion: nil)
    }
}
