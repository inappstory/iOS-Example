//
//  UIView+CS.swift
//  InAppStoryExample
//

import UIKit

extension UIView {
    
    /// Resizing `UIView` via transformation
    /// - Parameters:
    ///   - scale: the size to which you want to change
    ///   - anchorPoint: the anchor point from which the changes will take place
    func setTransform(withScale scale: CGFloat, anchorPoint: CGPoint) {
        layer.anchorPoint = anchorPoint
        let scale = scale != 0 ? scale : CGFloat.leastNonzeroMagnitude
        let xPadding = 1/scale * (anchorPoint.x - 0.5)*bounds.width
        let yPadding = 1/scale * (anchorPoint.y - 0.5)*bounds.height
        transform = CGAffineTransform(scaleX: scale, y: scale).translatedBy(x: xPadding, y: yPadding)
    }
}
