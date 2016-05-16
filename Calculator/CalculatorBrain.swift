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
    
    // Delegate that wants to be updated about changes to this brain's history
    var delegate: CalculatorBrainDelegate?
    
    init() {
        func learnOp(op: Op){
            knownOps[op.description] = op
        }
        learnOp(Op.BinaryOperation("✕", *))
        learnOp(Op.BinaryOperation("-", {$1-$0} ))
        learnOp(Op.BinaryOperation("+", +))
        learnOp(Op.BinaryOperation("÷", {$1/$0} ))
        learnOp(Op.UnaryOperation("√", sqrt))
        learnOp(Op.UnaryOperation("sin", sin))
        learnOp(Op.UnaryOperation("cos", cos))
    }
    
    private func evaluate(ops: [Op]) -> (result: Double?, remainingOps: [Op]){
        if !ops.isEmpty {
            var remainingOps = ops
            let op = remainingOps.removeLast()
            
            switch op {
            case .Operand(let operand):
                return (operand, remainingOps)
                
            case .UnaryOperation(_, let operation):
                let operandEvaluation = evaluate(remainingOps)
                if let operand = operandEvaluation.result {
                    return (operation(operand), operandEvaluation.remainingOps)
                }
                
            case .BinaryOperation(_, let operation):
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
        print("\(opStack)")
        return result
    }
    
    private enum Op: CustomStringConvertible {
        case Operand(Double)
        case UnaryOperation(String, Double -> Double)
        case BinaryOperation(String, (Double, Double) -> Double)
        
        var description: String {
            get{
                switch self {
                case .Operand(let operand):
                    return "\(operand)"
                    
                case .UnaryOperation(let symbol, _):
                    return symbol
                    
                case .BinaryOperation(let symbol, _):
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
    
    func performOperation(symbol: String)->Double? {
        if let operation = knownOps[symbol]{
            opStack.append(operation)
            tryUpdateDelegate()
            print("\(opStack)")
            return evaluate()
        }
        return nil
    }
    
    // Helper function updates delegate if there is one
    private func tryUpdateDelegate() {
        if let delegate: CalculatorBrainDelegate = delegate {
            delegate.historyUpdated()
        }
    }
    
    // returns history of stack
    func getHistory() -> String {
        return opStack.description
    }
    
    func clear(){
        opStack = [Op]()
    }
}

// Protocol that should be implemented by those wishing to by notified when brain's history is updated
protocol CalculatorBrainDelegate{
    func historyUpdated()
}