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
        
        // If this is our first time showing the view, and we need to reset the origin to the center of the view
        if needsOriginReset {
            origin = center
            needsOriginReset = false
        }
        
        // Use helper class to draw axes
        axisDrawer.drawAxesInRect(self.bounds, origin: origin, pointsPerUnit: pointsPerUnit)
        
        // Draw our function on the axes
        drawFunc()
    }
    
    var dataSource: GraphViewDataSource?
    
    private var axisDrawer = AxesDrawer(color: UIColor.blueColor())
    
    // Private helper variable manages need to reset origin to center of view
    private var needsOriginReset = true
    var origin: CGPoint = CGPoint() { didSet { setNeedsDisplay() } }
    
    // basically scale
    @IBInspectable
    var pointsPerUnit: CGFloat = 100 { didSet { setNeedsDisplay() } }
    
    // Color to draw function in
    @IBInspectable
    var funcColor: UIColor = UIColor.blackColor() { didSet { setNeedsDisplay() } }
    
    // Color to draw axes in
    @IBInspectable
    var axesColor: UIColor = UIColor.blackColor() {
        didSet {
            axisDrawer = AxesDrawer(color: axesColor)
            setNeedsDisplay()
        }
    }
    
    
    // Handles pans on the view
    func handlePan(recognizer: UIPanGestureRecognizer) {
        switch recognizer.state {
        // If a pan, even partial has occured
        case .Changed, .Ended:
            // distance travelled
            let translation = recognizer.translationInView(self)
            
            // move origin
            origin = origin.offsetBy(translation.x, dy: translation.y)
            
            // reset translation
            recognizer.setTranslation(CGPointZero, inView: self)
            
            // origin has been set by user, and no longer needs reset
            needsOriginReset = false
            
        default:
            break
        }
    }
    
    func handlePinch(recognizer: UIPinchGestureRecognizer) {
        switch recognizer.state {
        // if a pinch, even partial, has occured
        case .Ended, .Changed:
            // amount scalled
            pointsPerUnit *= recognizer.scale
            
            // reset scale
            recognizer.scale = 1
            
        default:
            break
        }
    }
    
    func handleDoubleTap(recognizer: UITapGestureRecognizer) {
        switch recognizer.state {
        // if double tap occured
        case .Ended:
            // set origin to double tap location
            origin = recognizer.locationInView(self)
            
            // origin has been set by user, and no longer needs reset
            needsOriginReset = false
        default:
            break
        }
    }
    
    // converts x-value pixel number in view to unit number on axes
    private func xPixelsToUnits(xPixelNum: Int) -> CGFloat {
        let diff = CGFloat(xPixelNum) - origin.x
        
        return diff / pointsPerUnit
    }
    
    // converts y-value in units to pixel number in view
    private func yUnitsToPixels(units: CGFloat) -> CGFloat {
        return -1*units * pointsPerUnit + origin.y
    }
    
    // draws a line between the two givenpoints
    private func drawLine(x1: CGPoint, x2: CGPoint) {
        CGContextSaveGState(UIGraphicsGetCurrentContext())
        funcColor.set()
        let path = UIBezierPath()
        path.moveToPoint(x1)
        path.addLineToPoint(x2)
        path.stroke()
        CGContextRestoreGState(UIGraphicsGetCurrentContext())

    }
    
    // Draws the function provided by the datas source if it exists
    private func drawFunc() {
        // if no data source is set, see ya!
        if self.dataSource == nil {
            return
        }
        // else
        let dsource = dataSource!
        
        // holds last point we masked
        var lastPoint: CGPoint?
        // for each x-pixel-value in our view
        for x in Int(bounds.minX)..<(Int(bounds.maxX) + 1) {
            let unitValueX = xPixelsToUnits(x)// x-value of this point in units
            let unitValueY = dsource.getYfor(Double(unitValueX)) // y-value of this point in units
            if unitValueY.isNormal || unitValueY.isZero { // if y-value is legit
                let pixelValueY = yUnitsToPixels(CGFloat(unitValueY)) // y-value of this point in pixels in view
                if let lastPoint = lastPoint { // if there is a last point to draw from
                    drawLine(lastPoint, x2: CGPoint(x: x, y: Int(pixelValueY))) // draw the line from the last point to this one
                }
                lastPoint = CGPoint(x: x, y: Int(pixelValueY))
            } else { // if y value is not legit
                lastPoint = nil
            }
        }
    }
}

// Data source protocol for GraphView
protocol GraphViewDataSource {
    func getYfor(x: Double) -> Double
}

// Helper functions on CGPoints
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