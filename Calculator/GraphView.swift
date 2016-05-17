//
//  GraphView.swift
//  Calculator
//
//  Created by Noah Safian on 5/16/16.
//  Copyright © 2016 Noah Sfian. All rights reserved.
//

import UIKit

@IBDesignable
class GraphView: UIView {

    
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        if needsOriginReset {
            origin = center
            needsOriginReset = false
        }
        axisDrawer.drawAxesInRect(self.bounds, origin: origin, pointsPerUnit: pointsPerUnit)
    }
    
    private var axisDrawer = AxesDrawer(color: UIColor.blueColor())
    
    var needsOriginReset = true
    var origin: CGPoint = CGPoint() { didSet { setNeedsDisplay() } }
    
    @IBInspectable
    var pointsPerUnit: CGFloat = 10 { didSet { setNeedsDisplay() } }
    
    var axisBounds = CGRect(x: -10, y: -10, width: 20, height: 20) { didSet { setNeedsDisplay() } }
    
    func handlePan(recognizer: UIPanGestureRecognizer) {
        switch recognizer.state {
        case .Changed, .Ended:
            let translation = recognizer.translationInView(self)
            
            origin = origin.offsetBy(translation.x, dy: translation.y)
            
            recognizer.setTranslation(CGPointZero, inView: self)
            
            needsOriginReset = false
            
        default:
            break
        }
    }
    
    func handlePinch(recognizer: UIPinchGestureRecognizer) {
        switch recognizer.state {
        case .Ended, .Changed:
            pointsPerUnit *= recognizer.scale
            
            recognizer.scale = 1
            
        default:
            break
        }
    }
    
    func handleDoubleTap(recognizer: UITapGestureRecognizer) {
        switch recognizer.state {
        case .Ended:
            origin = recognizer.locationInView(self)
            needsOriginReset = false
        default:
            break
        }
    }
    
    func xPixelsToUnits(xPixelNum: Int) -> Int {
        let diff = CGFloat(xPixelNum) - origin.x
        
        return diff / pointsPerUnit
    }
    
    func drawFunc(function: (Double)->Double) {
        for x in bounds.minX...<bounds.minY {
            
        }
    }
}

extension CGPoint
{
    init(x: Int, y: Int) {
        self.init(x: CGFloat(x), y: CGFloat(y))
    }
    
    func offsetBy(dx: Int, dy: Int) -> CGPoint {
        return CGPoint(x: self.x + CGFloat(dx), y: self.y + CGFloat(dy))
    }
    
    func offsetBy(dx: CGFloat, dy: CGFloat) -> CGPoint {
        return CGPoint(x: self.x + dx, y: self.y + dy)
    }
}