//
//  Square.swift
//  ShapeDrawingKit
//

import UIKit

@MainActor
public class Square: ShapeProtocol {
    
    private let shapeLayer: CAShapeLayer
    public var frame: CGRect
    public var fillColor: UIColor
    public var strokeColor: UIColor
    public var strokeWidth: CGFloat
    public var cornerRadius: CGFloat
    public var image: UIImage?
    public var imageView: UIImageView?
    
    public var layer: CALayer { return shapeLayer }
    
    public init(frame: CGRect,
                fillColor: UIColor = .white,
                strokeColor: UIColor = .black,
                strokeWidth: CGFloat = 2.0,
                cornerRadius: CGFloat = 0.0) {
        self.frame = frame
        self.fillColor = fillColor
        self.strokeColor = strokeColor
        self.strokeWidth = strokeWidth
        self.cornerRadius = cornerRadius
        
        self.shapeLayer = CAShapeLayer()
        self.shapeLayer.frame = frame
        
        let path = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: frame.width, height: frame.height), 
                               cornerRadius: cornerRadius).cgPath
        self.shapeLayer.path = path
        
        self.shapeLayer.fillColor = fillColor.cgColor
        self.shapeLayer.strokeColor = strokeColor.cgColor
        self.shapeLayer.lineWidth = strokeWidth
    }
    
    public func draw(in view: UIView) {
        view.layer.addSublayer(shapeLayer)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        view.addGestureRecognizer(tapGesture)
    }
    
    public func loadImage(_ image: UIImage) {
        self.image = image
        
        let imageView = UIImageView(frame: frame)
        imageView.image = image
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        self.imageView = imageView
        
        if let path = shapeLayer.path {
            let mask = CAShapeLayer()
            mask.path = path
            imageView.layer.mask = mask
        }
        
        if let superview = shapeLayer.superlayer?.delegate as? UIView {
            superview.addSubview(imageView)
        }
    }
    
    public func processImage(vibranceValue: Float, claheValue: Float) async {
        guard let currentImage = image else { return }
        
        let imageProcessor = ImageProcessor()
        
        if let processedImage = await imageProcessor.applyFilters(
            to: currentImage,
            vibranceValue: vibranceValue,
            claheValue: claheValue
        ) {
            print("SSSSS: applyFilters done")
            self.image = processedImage
            imageView?.image = processedImage
        }
    }
    
    @objc private func handleTap(_ gesture: UITapGestureRecognizer) {
        let location = gesture.location(in: gesture.view)
        
        if frame.contains(location) {
            shapeLayer.strokeColor = UIColor.blue.cgColor
            shapeLayer.lineWidth = 3.0
        } else {
            shapeLayer.strokeColor = strokeColor.cgColor
            shapeLayer.lineWidth = strokeWidth
        }
    }
}
