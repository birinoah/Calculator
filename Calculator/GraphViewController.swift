//
//  ViewController.swift
//  Calculator
//
//  Created by Noah Safian on 5/16/16.
//  Copyright © 2016 Noah Sfian. All rights reserved.
//

import UIKit

class GraphViewController: UIViewController, GraphViewDataSource {
    
    // Model for this MVC
    // is a function: R->R
    var function: ((Double)->Double)?
    
    // Main view contained in VC
    // Encapsulates most of drawing, needing only a data source delegate
    @IBOutlet var graphView: GraphView! {
        didSet {
            
            // Turns on gesture recognizer for graphView with appropriate action methods
            // Note: Selector style was changed for Swift 2.2, and the selector style I've used
            //      will cause a warning when running newer versions of XCode. However, this style is
            //      necessary to work on older version of XCode, like on the school computers, so I needed
            //      to leave them like this for testing
            graphView.addGestureRecognizer(UIPanGestureRecognizer(target: graphView, action: "handlePan:"))
            graphView.addGestureRecognizer(UIPinchGestureRecognizer(target: graphView, action: "handlePinch:"))
            
            let doubleTapRecognizer = UITapGestureRecognizer(target: graphView, action: "handleDoubleTap:")
            doubleTapRecognizer.numberOfTapsRequired = 2
            graphView.addGestureRecognizer(doubleTapRecognizer)
            
            // Set self, the GraphViewController, as the data source of the graph view
            graphView.dataSource = self
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // when view loads, tell graph to update its view just in case
        graphView.setNeedsDisplay()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Implementation of graph view data source method
    // If no function present, returns NaN for all values of x
    func getYfor(x: Double) -> Double {
        if let f = function {
            return f(x)
        } else {
            return Double.NaN
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
