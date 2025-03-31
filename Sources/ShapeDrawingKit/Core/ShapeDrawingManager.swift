//
//  ShapeDrawingManager.swift
//  ShapeDrawingKit
//

import UIKit

@MainActor
public class ShapeDrawingManager {
    private let canvasConfiguration: CanvasConfiguration
    
    public init(canvasConfiguration: CanvasConfiguration) {
        self.canvasConfiguration = canvasConfiguration
    }
    
    /// Draws shapes in a grid layout based on the provided canvas configuration
    /// - Parameters:
    ///   - view: The view to draw shapes in
    /// - Returns: Array of created shapes
    public func drawShapes(in view: UIView) -> [ShapeProtocol] {
        let canvasSize = canvasConfiguration.canvasSize
        let rows = canvasConfiguration.rows
        let columns = canvasConfiguration.columns
        let spacing = canvasConfiguration.spacing
        let padding = canvasConfiguration.padding
        
        // Calculate available space for shapes after padding
        let availableWidth = canvasSize.width - padding.left - padding.right
        let availableHeight = canvasSize.height - padding.top - padding.bottom
        
        // Calculate individual shape dimensions based on grid layout
        let shapeWidth = (availableWidth - (CGFloat(columns - 1) * spacing)) / CGFloat(columns)
        let shapeHeight = (availableHeight - (CGFloat(rows - 1) * spacing)) / CGFloat(rows)
        
        var shapes: [ShapeProtocol] = []
        
        // Create shapes in a grid pattern
        for row in 0..<rows {
            for column in 0..<columns {
                // Calculate position for each shape with proper spacing
                let x = padding.left + CGFloat(column) * (shapeWidth + spacing)
                let y = padding.top + CGFloat(row) * (shapeHeight + spacing)
                
                let shapeFrame = CGRect(x: x, y: y, width: shapeWidth, height: shapeHeight)
                
                let shape: ShapeProtocol
                
                switch canvasConfiguration.shapeType {
                case .square:
                    shape = Square(frame: shapeFrame)
                }
                
                shape.draw(in: view)
                shapes.append(shape)
            }
        }
        
        return shapes
    }
} 