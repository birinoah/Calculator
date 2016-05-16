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
        historyLabel.text = ""
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
            // If it is not the case that the digit pressed is the decimal and one is already in our string
            if !((digit == CalculatorViewController.decimal_pt) && (self.display.text!.rangeOfString(CalculatorViewController.decimal_pt) != nil)) {
                
                self.display.text = self.display.text! + digit
            }
            
        }else
        {
            displayValue = Double(digit)
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
    
    func historyUpdated() {
        historyLabel.text = brain.description + " ="
    }
    
    
    var displayValue: Double? {
        get{
            if let num: Double = NSNumberFormatter().numberFromString(display.text!)!.doubleValue {
                return num
            }
            else {
                return nil
            }
        }
        set{
            if let value: Double = newValue {
                display.text = "\(value)"
            } else {
                display.text = " "
                userIsTyping = false
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

