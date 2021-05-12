//
//  CALayer+dropShadow.swift
//  doggy-explorer
//
//  Created by David Kaufman on 12/05/2021.
//

import UIKit

extension CALayer {
    func applyDropShadow(
        color: UIColor = .black,
        alpha: Float = 0.3,
        x: CGFloat = 0,
        y: CGFloat = 2,
        blur: CGFloat = 4,
        spread: CGFloat = 0)
    {
        shadowColor = color.cgColor
        shadowOpacity = alpha
        shadowOffset = CGSize(width: x, height: y)
        shadowRadius = blur / 2.0
        if spread == 0 {
            shadowPath = nil
        } else {
            let dx = -spread
            let rect = bounds.insetBy(dx: dx, dy: dx)
            shadowPath = UIBezierPath(rect: rect).cgPath
        }
    }
}
