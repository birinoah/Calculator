//
//  ViewController.swift
//  Calculator
//
//  Created by Noah Safian on 5/16/16.
//  Copyright © 2016 Noah Sfian. All rights reserved.
//

import UIKit

class GraphViewController: UIViewController {
    
    // REMEMBER TO DEAL WITH HISTORY LABEL DISAPPEARING
    
    
    var function: ((Double)->Double)? {
        didSet {
            updateGraph()
        }
    }
    
    func updateGraph() {
        if let function = function {
            graphView.drawFunc(function)
        }   
    }
    
    
    @IBOutlet var graphView: GraphView! {
        didSet {
            graphView.addGestureRecognizer(UIPanGestureRecognizer(target: graphView, action: "handlePan:"))
            graphView.addGestureRecognizer(UIPinchGestureRecognizer(target: graphView, action: "handlePinch:"))
            
            let doubleTapRecognizer = UITapGestureRecognizer(target: graphView, action: "handleDoubleTap:")
            doubleTapRecognizer.numberOfTapsRequired = 2
            graphView.addGestureRecognizer(doubleTapRecognizer)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
