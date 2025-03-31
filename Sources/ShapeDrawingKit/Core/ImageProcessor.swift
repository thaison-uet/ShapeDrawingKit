//
//  ImageProcessor.swift
//  ShapeDrawingKit
//

import UIKit

@preconcurrency import MetalPetal
import Combine

@MainActor
public class ImageProcessor {
    private var context: MTIContext?
    
    public init() {
        do {
            context = try MTIContext(device: MTLCreateSystemDefaultDevice()!)
        } catch {
            print("Failed to create MetalPetal context: \(error)")
        }
    }
    
    /// Resizes image if it exceeds maximum allowed dimensions or data size
    /// This optimization helps prevent memory issues during processing
    /// - Parameter image: The image to potentially resize
    /// - Returns: Resized image if needed, original image otherwise
    private nonisolated func resizeImageIfNeeded(_ image: UIImage) -> UIImage {
        guard let imageData = image.jpegData(compressionQuality: 1.0) else {
            return image
        }
        
        if imageData.count <= Constants.Image.maxDataSize {
            return image
        }
        
        let maxSize: CGFloat = Constants.Image.maxDimension
        let scale = image.size.width / image.size.height
        
        var newSize: CGSize
        if scale > 1 {
            newSize = CGSize(width: maxSize, height: maxSize / scale)
        } else {
            newSize = CGSize(width: maxSize * scale, height: maxSize)
        }
        
        // Perform actual resizing
        let renderer = UIGraphicsImageRenderer(size: newSize)
        let resizedImage = renderer.image { context in
            image.draw(in: CGRect(origin: .zero, size: newSize))
        }
        
        return resizedImage
    }
    
    /// Applies a sequence of image filters using MetalPetal for hardware-accelerated processing
    /// - Parameters:
    ///   - image: The input image to process
    ///   - vibranceValue: Value for vibrance filter
    ///   - claheValue: Value for CLAHE filter
    /// - Returns: Processed image or nil if processing fails
    public func applyFilters(to image: UIImage, vibranceValue: Float, claheValue: Float) async -> UIImage? {
        guard let context = context else {
            print("MetalPetal context not available")
            return nil
        }
        
        return await withCheckedContinuation { (continuation: CheckedContinuation<UIImage?, Never>) in
            DispatchQueue.global(qos: .userInitiated).async {
                // Optimize image size before processing
                let resizedImage = self.resizeImageIfNeeded(image)
                guard let ciImage = CIImage(image: resizedImage) else {
                    DispatchQueue.main.async {
                        continuation.resume(returning: nil)
                    }
                    return
                }
                
                // Convert to MetalPetal image format
                let inputImage = MTIImage(ciImage: ciImage, isOpaque: true)
                
                // Apply vibrance filter
                let vibranceFilter = MTIVibranceFilter()
                vibranceFilter.amount = vibranceValue
                vibranceFilter.inputImage = inputImage
                
                guard let vibranceOutput = vibranceFilter.outputImage else {
                    DispatchQueue.main.async {
                        continuation.resume(returning: nil)
                    }
                    return
                }
                
                // Apply CLAHE filter for contrast enhancement
                let claheFilter = MTICLAHEFilter()
                claheFilter.clipLimit = claheValue
                claheFilter.tileGridSize = MTICLAHESize(width: 8, height: 8)
                claheFilter.inputImage = vibranceOutput
                
                guard let finalOutput = claheFilter.outputImage else {
                    DispatchQueue.main.async {
                        continuation.resume(returning: nil)
                    }
                    return
                }
                
                do {
                    // Convert back to CGImage for final output
                    let cgImage = try context.makeCGImage(from: finalOutput)
                    let processedImage = UIImage(cgImage: cgImage)
                    DispatchQueue.main.async {
                        continuation.resume(returning: processedImage)
                    }
                } catch {
                    print("Failed to create final image: \(error)")
                    DispatchQueue.main.async {
                        continuation.resume(returning: nil)
                    }
                }
            }
        }
    }
}
