//
//  Extensions.swift
//  Seqre
//
//  Created by Ivan Blinov on 11/21/19.
//  Copyright © 2019 Ivan Blinov. All rights reserved.
//

import Foundation
import UIKit
import QuartzCore

extension UIView {
    
    func anchor(top: NSLayoutYAxisAnchor?, left: NSLayoutXAxisAnchor?,
                bottom: NSLayoutYAxisAnchor?, right: NSLayoutXAxisAnchor?,
                paddingTop: CGFloat, paddingLeft: CGFloat, paddingBottom: CGFloat, paddingRight: CGFloat,
                width: CGFloat, height: CGFloat) {
        
        translatesAutoresizingMaskIntoConstraints = false
        
        if let top = top {
            self.topAnchor.constraint(equalTo: top, constant: paddingTop).isActive = true
        }
        if let left = left {
            self.leftAnchor.constraint(equalTo: left, constant: paddingLeft).isActive = true
        }
        if let bottom = bottom {
            self.bottomAnchor.constraint(equalTo: bottom, constant: -paddingBottom).isActive = true
        }
        if let right = right {
            self.rightAnchor.constraint(equalTo: right, constant: -paddingRight).isActive = true
        }
        
        if (width != 0) {
            widthAnchor.constraint(equalToConstant: width).isActive = true
        }
        if (height != 0) {
            heightAnchor.constraint(equalToConstant: height).isActive = true
        }
    }
}

extension UIImage {
    
    static func fromBase64(base64: String) -> UIImage {
        return UIImage(data: NSData(base64Encoded: base64, options: .ignoreUnknownCharacters)! as Data)!
    }
}

extension UITextField {
    func shake(duration: CFTimeInterval = 0.3, pathLength: CGFloat = 15) {
        let position: CGPoint = self.center

        let path: UIBezierPath = UIBezierPath()
        path.move(to: CGPoint(x: position.x, y: position.y))
        path.addLine(to: CGPoint(x: position.x-pathLength, y: position.y))
        path.addLine(to: CGPoint(x: position.x+pathLength, y: position.y))
        path.addLine(to: CGPoint(x: position.x-pathLength, y: position.y))
        path.addLine(to: CGPoint(x: position.x+pathLength, y: position.y))
        path.addLine(to: CGPoint(x: position.x, y: position.y))

        let positionAnimation = CAKeyframeAnimation(keyPath: "position")

        positionAnimation.path = path.cgPath
        positionAnimation.duration = duration
        positionAnimation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)

        CATransaction.begin()
        self.layer.add(positionAnimation, forKey: nil)
        CATransaction.commit()
    }
}
