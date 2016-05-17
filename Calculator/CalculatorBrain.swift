//
//  CalculatorBrain.swift
//  Calculator
//
//  Created by Noah Safian on 2/2/16.
//  Copyright © 2016 Noah Sfian. All rights reserved.
//

import Foundation

class CalculatorBrain
{
    private var opStack = [Op]()
    
    private var knownOps = [String: Op]()
    
    private var variableValues = Dictionary<String,Double>()
    
    static let piSymbol = "π"
    
    // Delegate called when history updated
    var delegate: CalculatorBrainDelegate?
    
    var description: String {
        get  {
            var remainingOps = opStack
            
            var description = ""
            
            // Runs once for every "group" situated between commas in the brain description
            while !remainingOps.isEmpty {
                let (resultString, leftoverOps, _) = getDescription(remainingOps)
                
                remainingOps = leftoverOps
                description = resultString + ", " + description
            }
            
            // Cuts off extra space and comma
            let range = description.startIndex..<description.endIndex.advancedBy(-2)
            
            return description.substringWithRange(range)
        }
    }
    
    // The description for just the top function on the stack
    var topDescription: String {
        get {
            let (resultString, _, _) = getDescription(opStack)
            
            return resultString
        }
    }
    
    // Priorities:
    // Constants/Operands - 5
    // Exponents - 4
    // Muliplication/Division - 3
    // Addition/Subtraction - 2
    
    // Above priorities assigned appropriately below.
    // Used to determine where parenthesis are necessary in description
    init() {
        func learnOp(op: Op){
            knownOps[op.description] = op
        }
        learnOp(Op.BinaryOperation("✕", *, 3))
        learnOp(Op.BinaryOperation("-", {$1-$0}, 2))
        learnOp(Op.BinaryOperation("+", +, 2))
        learnOp(Op.BinaryOperation("÷", {$1/$0}, 3))
        learnOp(Op.UnaryOperation("√", sqrt))
        learnOp(Op.UnaryOperation("sin", sin))
        learnOp(Op.UnaryOperation("cos", cos))
        
        // Constants are just more known Ops
        learnOp(Op.Constant(CalculatorBrain.piSymbol, M_PI))
        learnOp(Op.Constant("e", M_E))
    }
    
    

    // Given to things that never need extra parenthesis - Constants, numbers, unary operations...
    private static let highPriority = 5
    
    private func getDescription(ops: [Op]) -> (result: String, remainingOps: [Op], priority: Int){
        if !ops.isEmpty {
            var remainingOps = ops
            let op = remainingOps.removeLast()
            
            switch op {
            case .Operand(let operand):
                return ("\(operand)", remainingOps, CalculatorBrain.highPriority)
                
            case .Variable(let symbol):
                return (symbol, remainingOps, CalculatorBrain.highPriority)
                
            case .Constant(let symbol, _):
                return (symbol, remainingOps, CalculatorBrain.highPriority)
                
            case .UnaryOperation(let symbol, _):
                let operandEvaluation = getDescription(remainingOps)
                return ("\(symbol)(\(operandEvaluation.result))", operandEvaluation.remainingOps, CalculatorBrain.highPriority)
                
            case .BinaryOperation(let symbol, _, let priority):
                let innerEvaluation = getDescription(remainingOps)
                
                var first = ""
                
                // If there is a missign operand, compensate. Otherwise take result of recursion
                if remainingOps.isEmpty {
                    first = "?"
                } else {
                    first = innerEvaluation.result
                }
                
                // Below repeats steps from above with Ops left over from first recursion
                let innerEvaluation2 = getDescription(innerEvaluation.remainingOps)
                
                var second = ""
                
                if innerEvaluation.remainingOps.isEmpty {
                    second = "?"
                } else {
                    second = innerEvaluation2.result
                }
                
                // Adds parenthesis to project lower-priority operations when necessary
                if innerEvaluation.priority < priority {
                    first = "(" + first + ")"
                }
                if innerEvaluation2.priority < priority {
                    second = "(" + second + ")"
                }
                
                return ("\(second) \(symbol) \(first)", innerEvaluation2.remainingOps, priority)
            }
        }
        return (" ", ops, CalculatorBrain.highPriority)
    }
    
    // Returns the top function on the stack as a one-variabel functions R->R where all the variables
    // are the same
    private func getFunc(ops: [Op]) -> (result: ((Double)->Double)?, remainingOps: [Op]){
        if !ops.isEmpty {
            var remainingOps = ops
            let op = remainingOps.removeLast()
            
            switch op {
            case .Operand(let operand):
                return ({ _ in return operand }, remainingOps) // return constant function at operand
                
            case .Variable(_):
                return ({ (x: Double) in return x }, remainingOps) // return f(x) = x, identity function
                
            case .Constant(_, let value):
                return ({ _ in return value}, remainingOps) // reutrn constant function at constant value
                
            case .UnaryOperation(_, let operation):
                let operandEvaluation = getFunc(remainingOps)
                if let innerOp = operandEvaluation.result {
                    // returns a function defined by the unary operation on the inner function of the given parameter
                    return ({ (x: Double) in operation(innerOp(x)) }, operandEvaluation.remainingOps)
                }
                
            case .BinaryOperation(_, let operation, _):
                let operandEvaluation = getFunc(remainingOps)
                if let  innerOp = operandEvaluation.result{
                    let operandEvaluation2 = getFunc(operandEvaluation.remainingOps)
                    if let innerOp2 = operandEvaluation2.result {
                        // Returns a function defined by the binary operation of the two inner operations,
                        // both performed onthe given parameter
                        return ({ (x: Double) in operation(innerOp(x), innerOp2(x)) }, operandEvaluation2.remainingOps)
                    }
                }
            }
        }
        return (nil, ops)
    }
    
    // Returns the top function on the stack as a one-variabel functions R->R where all the variables
    // are the same
    func getFunc() -> ((Double)->Double)? {
        let (result, _) = getFunc(opStack)
        return result
    }
    
    private func evaluate(ops: [Op]) -> (result: Double?, remainingOps: [Op]){
        if !ops.isEmpty {
            var remainingOps = ops
            let op = remainingOps.removeLast()
            
            switch op {
            case .Operand(let operand):
                return (operand, remainingOps)
                
            case .Variable(let symbol):
                return (variableValues[symbol], remainingOps)
            
            case .Constant(_, let value):
                return (value, remainingOps)
                
            case .UnaryOperation(_, let operation):
                let operandEvaluation = evaluate(remainingOps)
                if let operand = operandEvaluation.result {
                    return (operation(operand), operandEvaluation.remainingOps)
                }
                
            case .BinaryOperation(_, let operation, _):
                let operandEvaluation = evaluate(remainingOps)
                if let  operand = operandEvaluation.result{
                    let operandEvaluation2 = evaluate(operandEvaluation.remainingOps)
                    if let operand2 = operandEvaluation2.result {
                        return (operation(operand, operand2), operandEvaluation2.remainingOps)
                    }
                }
            }
        }
        return (nil, ops)
    }
    
    func evaluate() -> Double? {
        let (result, _) = evaluate(opStack)
        return result
    }
    
    private enum Op: CustomStringConvertible {
        case Operand(Double)
        case Variable(String)
        case Constant(String, Double)
        case UnaryOperation(String, Double -> Double)
        case BinaryOperation(String, (Double, Double) -> Double, Int)
        
        var description: String {
            get{
                switch self {
                case .Operand(let operand):
                    return "\(operand)"
                    
                case .UnaryOperation(let symbol, _):
                    return symbol
                    
                case .BinaryOperation(let symbol, _, _):
                    return symbol
                    
                case .Variable(let symbol):
                    return symbol
                    
                case .Constant(let symbol, _):
                    return symbol
                }
            }
        }
    }
    
    func pushOperand(operand: Double)->Double?{
        opStack.append(Op.Operand(operand))
        tryUpdateDelegate()
        return evaluate()
    }
    
    // Originally implemnted a seperate pushConstant method, but then backtracked in order
    // to maintain the public API.
    // Will consider symbol a constant if its symbol corresponds to one, or otherwise push a variable
    // with the given symbol
    func pushOperand(symbol: String)->Double? {
        if let op = knownOps[symbol]{
            opStack.append(op)
            tryUpdateDelegate()
            return evaluate()
        } else {
            opStack.append(Op.Variable(symbol))
            tryUpdateDelegate()
            return evaluate()
        }
    }
    
    func performOperation(symbol: String)->Double? {
        if let operation = knownOps[symbol]{
            opStack.append(operation)
            tryUpdateDelegate()
            return evaluate()
        }
        return nil
    }
    
    func setVariable(symbol: String, value: Double) {
        variableValues[symbol] = value
    }
    
    // Helper method updates delegate if one exists
    private func tryUpdateDelegate() {
        if let delegate: CalculatorBrainDelegate = delegate {
            delegate.historyUpdated()
        }
    }
    
    func getHistory() -> String {
        return opStack.description
    }
    
    func clear(){
        opStack = [Op]()
        variableValues = Dictionary<String, Double>()
    }
}

// Protocol for delegate that wants to be notified when brain's history is updated
protocol CalculatorBrainDelegate{
    func historyUpdated()
}