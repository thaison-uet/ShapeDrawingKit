//
//  Untitled.swift
//  ShapeDrawingKit
//

import UIKit

@MainActor
public protocol ShapeProtocol: AnyObject {
    var frame: CGRect { get set }
    var fillColor: UIColor { get set }
    var strokeColor: UIColor { get set }
    var strokeWidth: CGFloat { get set }
    var cornerRadius: CGFloat { get set }
    var image: UIImage? { get set }
    var layer: CALayer { get }
    var imageView: UIImageView? { get set }
    
    func draw(in view: UIView)
    func loadImage(_ image: UIImage)
    func processImage(vibranceValue: Float, claheValue: Float) async
}

public struct CanvasConfiguration {
    public let canvasSize: CGSize
    public let rows: Int
    public let columns: Int
    public let spacing: CGFloat
    public let padding: UIEdgeInsets
    public let shapeType: ShapeType
    
    public init(canvasSize: CGSize, rows: Int, columns: Int, spacing: CGFloat, padding: UIEdgeInsets, shapeType: ShapeType) {
        self.canvasSize = canvasSize
        self.rows = rows
        self.columns = columns
        self.spacing = spacing
        self.padding = padding
        self.shapeType = shapeType
    }
}
