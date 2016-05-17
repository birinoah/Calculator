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
    
    // Used to standardize decimal point character
    static let decimal_pt = "."
    
    @IBAction func varPressed(sender: UIButton) {
        let symbol = sender.currentTitle!
        
        if userIsTyping {
            enter()
        }
        
        displayValue = brain.pushOperand(symbol)
        
        userIsTyping = false
    }
    
    @IBAction func setVarPressed(sender: UIButton) {
        let title = sender.currentTitle!
        
        // Get symbol, ignoring leading arrow
        let symbol = title.substringWithRange(title.startIndex.advancedBy(1)..<title.endIndex)
        
        if let value = displayValue {
            brain.setVariable(symbol, value: value)
        }
        displayValue = brain.evaluate()
        userIsTyping = false
    }
    
    @IBAction func clearPressed(sender: UIButton) {
        brain.clear()
        userIsTyping = false
        displayValue = 0
        historyLabel.text = " "
    }
    
    @IBAction func constantPressed(sender: UIButton) {
        let title = sender.currentTitle!
        
        if userIsTyping {
            enter()
        }
        displayValue = brain.pushOperand(title)
        
        userIsTyping = false
    }
    
    @IBAction func digitPressed(sender: UIButton) {
        let digit = sender.currentTitle!
        
        if userIsTyping{
            // if the user is typing not trying to add a second decimal point to the number being typed
            if !((digit == CalculatorViewController.decimal_pt) && (self.display.text!.rangeOfString(CalculatorViewController.decimal_pt) != nil)) {
                
                self.display.text = self.display.text! + digit
            }
            
        }else
        {
            // If the user starts typing with the decimal point
            if digit == CalculatorViewController.decimal_pt {
                display.text = "0."
            }
            // Otherwise
            else {
                displayValue = Double(digit)
            }
            userIsTyping = true
        }
        
    }
    @IBAction func enter() {
        userIsTyping = false
        
        if let value = displayValue {
            displayValue = brain.pushOperand(value)
        }
    }
    
    @IBAction func operatorPressed(sender: UIButton) {
        if userIsTyping {
            self.enter()
        }
        
        if let operation = sender.currentTitle {
            displayValue = brain.performOperation(operation)
        }
    }
    
    // Delegate method called by Calculator brain when history has changed
    func historyUpdated() {
        historyLabel.text = brain.description + " ="
    }
    
    
    var displayValue: Double? {
        // Returns display text converted to double if possible - otherwise nil
        get{
            if let displayText = display.text {
                return NSNumberFormatter().numberFromString(displayText)?.doubleValue
            } else {
                return nil
            }
        }
        // Sets display text to string representation of given value up to 9 decimal places if possible
        // Otherwise just sets text to a space character
        set{
            if let value: Double = newValue {
                display.text = String(format: "%.9g", value)
            } else {
                display.text = " "
                userIsTyping = false
            }
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "graphSegue" {
            if let navcon = segue.destinationViewController as? UINavigationController {
                if let graphVC = navcon.visibleViewController as? GraphViewController {
                    graphVC.function = brain.getFunc()
                    graphVC.navigationItem.title = brain.topDescription
                }
            }
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

