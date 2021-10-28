//
//  gradientButton.swift
//  kartCornor
//
//  Created by Srinivas on 11/12/20.
//  Copyright © 2020 Srinivas. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable
class GradientButton: UIButton {
@IBInspectable var firstColor: UIColor = UIColor.clear {
didSet {
updateView()
}
}
@IBInspectable var secondColor: UIColor = UIColor.clear {
didSet {
updateView()
}
}
@IBInspectable var isHorizontal: Bool = true {
didSet {
updateView()
}
}
override class var layerClass: AnyClass {
get {
return CAGradientLayer.self
}
}
func updateView() {
let layer = self.layer as! CAGradientLayer
layer.colors = [firstColor, secondColor].map {$0.cgColor}
if (isHorizontal) {
layer.startPoint = CGPoint(x: 0, y: 0.5)
layer.endPoint = CGPoint (x: 1, y: 0.5)
} else {
layer.startPoint = CGPoint(x: 0.5, y: 0)
layer.endPoint = CGPoint (x: 0.5, y: 1)
}
}
}
