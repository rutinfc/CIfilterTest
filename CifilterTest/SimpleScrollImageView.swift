//
//  SimpleScrollImageView.swift
//  CifilterTest
//
//  Created by jeongkyu kim on 07/12/2018.
//  Copyright © 2018 jeongkyu kim. All rights reserved.
//

import UIKit

class SimpleScrollImageView: UIView {

    @IBInspectable var image : UIImage? {
        didSet {
            
            if let image = self.image {
                self.imageView.image = image
                self.imageView.sizeToFit()
                self.setNeedsLayout()
            }
        }
    }
    
    private let imageView = UIImageView()
    private let scrollView = UIScrollView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setting()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setting()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.scrollView.zoomScale = self.scrollView.minimumZoomScale
        
        self.scrollView.frame = self.bounds
        
        guard let scale = self.checkScale(), let image = self.image else {
            return
        }
        
        var frame = CGRect.zero
        frame.size.width = image.size.width * scale
        frame.size.height = image.size.height * scale
        self.imageView.frame = frame
        self.scrollView.contentSize = frame.size
        self.scrollView.zoomScale = 1
        
        self.checkCenter()
    }
    
    private func setting() {
        self.imageView.contentMode = .scaleAspectFit
        self.imageView.autoresizingMask = [UIView.AutoresizingMask.flexibleWidth, UIView.AutoresizingMask.flexibleHeight]
        self.scrollView.addSubview(self.imageView)
        self.scrollView.delegate = self
        self.scrollView.maximumZoomScale = 4.0
        self.scrollView.minimumZoomScale = 1.0
        self.scrollView.contentMode = .scaleAspectFit
        self.scrollView.contentInsetAdjustmentBehavior = .never
        self.addSubview(self.scrollView)
        
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap(recognizer:)))
        doubleTap.numberOfTapsRequired = 2
        self.scrollView.addGestureRecognizer(doubleTap)
    }
    
    func zoomRect(scale:CGFloat, center:CGPoint) -> CGRect {
        
        let width = self.imageView.frame.width / scale
        let height = self.imageView.frame.height / scale
    
        var rect = CGRect.zero
        rect.origin.x = center.x - (width / 2)
        rect.origin.y = center.y - (height / 2)
        rect.size.width = width
        rect.size.height = height
        return rect
    }
    
    @objc func handleDoubleTap(recognizer: UITapGestureRecognizer) {
        
        if (scrollView.zoomScale > scrollView.minimumZoomScale) {
            self.scrollView.setZoomScale(scrollView.minimumZoomScale, animated: true)
            
        } else {
            
            var scale = self.scrollView.zoomScale * 4
            if scale > self.scrollView.maximumZoomScale {
                scale = self.scrollView.maximumZoomScale
            }
            let rect = self.zoomRect(scale:scale, center: recognizer.location(in: self.imageView))
            self.scrollView.zoom(to: rect, animated: true)
        }
    }
}

extension SimpleScrollImageView : UIScrollViewDelegate {
    
    func checkScale() -> CGFloat? {
        let scrollViewFrame = self.scrollView.frame
        
        if scrollViewFrame == CGRect.zero {
            return nil
        }
        
        guard let image = self.image else {
            return nil
        }
        
        let scaleH = scrollViewFrame.height / image.size.height
        let scaleW = scrollViewFrame.width / image.size.width
        let scale = min(scaleW, scaleH)
        
        return scale
    }
    
    func checkCenter() {
        let offsetX = self.scrollView.bounds.width > self.scrollView.contentSize.width ? (self.scrollView.bounds.width - self.scrollView.contentSize.width) * 0.5 : 0
        let offsetY = self.scrollView.bounds.height > self.scrollView.contentSize.height ? (self.scrollView.bounds.height - self.scrollView.contentSize.height) * 0.5 : 0
        self.imageView.center = CGPoint(x:self.scrollView.contentSize.width * 0.5 + offsetX, y:self.scrollView.contentSize.height * 0.5 + offsetY)
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        self.checkCenter()
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.imageView
    }
}
