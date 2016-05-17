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
        
        drawFunc()
    }
    
    var dataSource: GraphViewDataSource?
    
    private var axisDrawer = AxesDrawer(color: UIColor.blueColor())
    
    private var needsOriginReset = true
    var origin: CGPoint = CGPoint() { didSet { setNeedsDisplay() } }
    
    @IBInspectable
    var pointsPerUnit: CGFloat = 10 { didSet { setNeedsDisplay() } }
    
    // var axisBounds = CGRect(x: -10, y: -10, width: 20, height: 20) { didSet { setNeedsDisplay() } }
    
    @IBInspectable
    var funcColor: UIColor = UIColor.blackColor() { didSet { setNeedsDisplay() } }
    
    @IBInspectable
    var axisColor: UIColor = UIColor.blackColor() {
        didSet {
            axisDrawer = AxesDrawer(color: axisColor)
            setNeedsDisplay()
        }
    }
    
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
    
    private func xPixelsToUnits(xPixelNum: Int) -> CGFloat {
        let diff = CGFloat(xPixelNum) - origin.x
        
        return diff / pointsPerUnit
    }
    
    private func yUnitsToPixels(units: CGFloat) -> CGFloat {
        return -1*units * pointsPerUnit + origin.y
    }
    
    private func drawLine(x1: CGPoint, x2: CGPoint) {
        CGContextSaveGState(UIGraphicsGetCurrentContext())
        funcColor.set()
        let path = UIBezierPath()
        path.moveToPoint(x1)
        path.addLineToPoint(x2)
        path.stroke()
        CGContextRestoreGState(UIGraphicsGetCurrentContext())

    }
    
    private func drawFunc() {
        if self.dataSource == nil {
            return
        }
        
        let dsource = dataSource!
        
        var lastPoint: CGPoint?
        for x in Int(bounds.minX)..<Int(bounds.maxX) {
            let unitValueX = xPixelsToUnits(x)
            let unitValueY = dsource.getYfor(Double(unitValueX))
            if unitValueY.isNormal || unitValueY.isZero {
                let pixelValueY = yUnitsToPixels(CGFloat(unitValueY))
                if let lastPoint = lastPoint {
                    drawLine(lastPoint, x2: CGPoint(x: x, y: Int(pixelValueY)))
                }
                lastPoint = CGPoint(x: x, y: Int(pixelValueY))
            } else {
                lastPoint = nil
            }
        }
    }
}

protocol GraphViewDataSource {
    func getYfor(x: Double) -> Double
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