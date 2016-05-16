//
//  ViewController.swift
//  Calculator
//
//  Created by Noah Safian on 1/28/16.
//  Copyright © 2016 Noah Sfian. All rights reserved.
//

import UIKit

class CalculatorViewController: UIViewController, CalculatorBrainDelegate {
    
    @IBOutlet weak var display: UILabel!
    
    var userIsTyping = false
    
    @IBOutlet weak var historyLabel: UILabel!
    
    var brain = CalculatorBrain()
    
    // Standardized decimal point char to be used
    static let decimal_pt = "."
    
    @IBAction func clearPressed(sender: UIButton) {
        brain.clear()
        userIsTyping = false
        displayValue = 0
        historyLabel.text = ""
    }
    
    @IBAction func constantPressed(sender: UIButton) {
        let title = sender.currentTitle!
        
        // Closure deals with symbol and returns value to be pushed to brain
        // If constant unknown, returns nil
        let value = { () -> Double? in
            switch title {
            case "π":
                return M_PI
            default:
                print("\(title) is not a known constant")
                return nil
            }
        }()
        
        if let value = value {
            enter()
            displayValue = value
            enter()
        }
    }
    
    @IBAction func digitPressed(sender: UIButton) {
        let digit = sender.currentTitle!
        
        if userIsTyping{
            // If the user isn't trying to add a second decimal point to the number they've been typing
            if !((digit == CalculatorViewController.decimal_pt) && (self.display.text!.rangeOfString(CalculatorViewController.decimal_pt) != nil)) {
                
                self.display.text = self.display.text! + digit
            }
            
        }else
        {
            display.text = digit
            userIsTyping = true
        }
        
    }
    @IBAction func enter() {
        userIsTyping = false
        
        if let result = brain.pushOperand(displayValue) {
            displayValue = result
        } else {
            displayValue = 0
        }
    }
    
    @IBAction func operatorPressed(sender: UIButton) {
        if userIsTyping {
            self.enter()
        }
        
        if let operation = sender.currentTitle {
            if let result = brain.performOperation(operation) {
                displayValue = result
            } else {
                displayValue = 0
            }
        }
    }
    
    func historyUpdated() {
        historyLabel.text = brain.getHistory()
    }
    
    
    var displayValue: Double {
        get{
            return NSNumberFormatter().numberFromString(display.text!)!.doubleValue
        }
        set{
            display.text = "\(newValue)"
        }
    }
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        brain.delegate = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

