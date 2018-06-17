//
//  CalculatorBrain.swift
//  Calculator
//
//  Created by verebes on 08/12/2016.
//  Copyright © 2016 verebes. All rights reserved.
//
// If it would be a class CalculatorBrain then i dont need the mutating before every function but because it is a
// struct i need it because the methods are changing the values of the variables struct is passed around by copying
// it so it needs to know if it writes to it.

import Foundation

struct CalculatorBrain {
    
    private var accumulator: Double?// = 0.0
    
    private var descriptionAccumulator = "0"
    
    var descriptionOfOperations: String {
        get {
            if pendingBinaryOperation == nil {
                return descriptionAccumulator
            } else {
                return pendingBinaryOperation!.descriptionFunction(pendingBinaryOperation!.descriptionOperand, pendingBinaryOperation!.descriptionOperand != descriptionAccumulator ? descriptionAccumulator : "")
            }
        }
    }
    
    private var currentPriorityOfTheOperation = 0
    
    mutating func setOperand(operand: Double) {
        accumulator = operand
        descriptionAccumulator = String(format: "%g", operand)
    }
    
    private var operations: Dictionary<String,Operation> = [
        "π" : Operation.Constant(Double.pi),
        "e" : Operation.Constant(M_E),
        "√" : Operation.UnaryOperation(sqrt, { "√(" + $0 + ")"}),
        "cos" : Operation.UnaryOperation(cos, { "cos(" + $0 + ")"}),
        "sin" : Operation.UnaryOperation(sin, { "sin(" + $0 + ")"}),
        "tan" : Operation.UnaryOperation(tan, { "tan(" + $0 + ")"}),
        "cosh" : Operation.UnaryOperation(cosh, { "cosh(" + $0 + ")"}),
        "sinh" : Operation.UnaryOperation(sinh, { "sinh(" + $0 + ")"}),
        "tanh" : Operation.UnaryOperation(tanh, { "tanh(" + $0 + ")"}),
        "±" : Operation.UnaryOperation({-$0}, { "-(" + $0 + ")"}),
        //        "×" : Operation.BinaryOperation({(op1: Double, op2: Double) -> Double in return op1 * op2}), //the operation above is the same as below as the closure implements its environment it knows that the BinaryOperation takes 2 Doubles and returns a Double therefor we can use the default arguments names $0, $1, $2 etc
        //in fact you can omit the $0 * $1 and just write * and swift will know that he should take the two incoming parameters (because * / + - are functions that are expecting a parameter each side) and to multiply them because it is expecting the input so that line can essentially be written as:
        //"×" : Operation.BinaryOperation(*, { $0 + " × " + $1 }, 1),
        "×" : Operation.BinaryOperation({$0 * $1}, { $0 + " × " + $1 }, 1),
        "÷" : Operation.BinaryOperation({$0 / $1}, { $0 + " ÷ " + $1 }, 1),
        "+" : Operation.BinaryOperation({$0 + $1}, { $0 + " + " + $1 }, 0),
        "-" : Operation.BinaryOperation({$0 - $1}, { $0 + " - " + $1 }, 0),
        "=" : Operation.Equals
        
    ]
    
    private enum Operation {
        case Constant(Double) //we are associating the constants like M_PI and M_E with it.
        case UnaryOperation((Double)->Double, (String)->String) //function that takes a double and returns a double changed to a function that returns a tuple basically takes a double and returns it into the first part of the tuple and takes a string and returns a string into the second part of the tuple.
        case BinaryOperation((Double, Double) -> Double, (String, String)->String, Int)  //function takes 2 doubles and returns double, secondly takes a string and returns a string and an int the int is responsible for the priorityOfTheOperation (precendence) * / have a higher one than + -  this function also returns a tuple.
        case Equals
    }
    
    mutating func performOperation(symbol: String) {
        if let operation = operations[symbol] {
            switch operation {
            case .Constant(let constantValue):
                accumulator = constantValue
                descriptionAccumulator = symbol
            case .UnaryOperation(let function, let descriptionFunction):
                if accumulator != nil {
                    accumulator = function(accumulator!)
                    descriptionAccumulator = descriptionFunction(descriptionAccumulator)
                }
            case .BinaryOperation(let function, let descriptionFunction, let priorityOfTheOperation):
                performPendingBinaryOperation()
                if currentPriorityOfTheOperation < priorityOfTheOperation {
                    descriptionAccumulator = "(" + descriptionAccumulator + ")"
                }
                currentPriorityOfTheOperation = priorityOfTheOperation
                if accumulator != nil {
                    pendingBinaryOperation = PendingBinaryOperationInfo(binaryFunction: function, firstOperand: accumulator!, descriptionFunction: descriptionFunction, descriptionOperand: descriptionAccumulator)
                    //accumulator = nil
                }
            case .Equals:
                performPendingBinaryOperation()
            }
        }
    }
    
    private mutating func performPendingBinaryOperation() {
        if pendingBinaryOperation != nil && accumulator != nil {
            
            accumulator = pendingBinaryOperation!.perform(with: accumulator!)
            descriptionAccumulator = pendingBinaryOperation!.descriptionFunction(pendingBinaryOperation!.descriptionOperand, descriptionAccumulator)
            pendingBinaryOperation = nil
        }
    }
    
    private var pendingBinaryOperation: PendingBinaryOperationInfo?  //optional because sometimes we have pending operations sometimes not.
    
    private struct PendingBinaryOperationInfo {
        var binaryFunction: (Double,Double) -> Double
        var firstOperand: Double
        var descriptionFunction: (String, String) -> String
        var descriptionOperand: String
        
        func perform(with secondOperand: Double) -> Double {
            return binaryFunction(firstOperand, secondOperand)
        }
    }
    
    mutating func clear() {
        accumulator = 0.0
        pendingBinaryOperation = nil
        descriptionAccumulator = "0"
    }
    
    var resultIsPending: Bool {
        /* if pendingBinaryOperation != nil {
         return true
         } else {
         return false
         }*/
        get {
            return pendingBinaryOperation != nil
        }
    }
    
    var result: Double? {
        get {
            return accumulator
        }
    }
}
