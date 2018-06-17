//
//  ViewController.swift
//  Calculator
//
//  Created by verebes on 08/12/2016.
//  Copyright © 2016 verebes. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet private weak var display: UILabel!
    @IBOutlet private weak var descriptionsDisplay: UILabel!
    
    private var userIsInTheMiddleOfTyping = false
    
    @IBAction private func touchDigit(_ sender: UIButton) {
        if let digit = sender.currentTitle {
            if userIsInTheMiddleOfTyping {
                let textCurrentlyInDisplay = display.text!
                if digit == "." && hasDot() {
                    display.text = textCurrentlyInDisplay
                } else {
                    display.text = textCurrentlyInDisplay + digit
                }
            } else if !userIsInTheMiddleOfTyping && digit == "." {
                display.text = "0\(digit)"
            }
            else  {
                display.text = digit
            }
            userIsInTheMiddleOfTyping = true
        }
    }
    
    //     displayValue is a computer property which happens by get and set. It takes what is on the display and converts it to a double then it sets the new display value by using newValue and converts that into a string so that it can be displayed in our display UILabel. However there is a check also if the display shows .0 at the end then it deletes that unnecessary suffix.
    private var displayValue: Double {
        get {
            return Double(display.text!)!
        } set {
            descriptionsDisplay.text = brain.descriptionOfOperations + (brain.resultIsPending ? "..." : "=")
            let newDisplayText = String(newValue)
            if newDisplayText.hasSuffix(".0") {
                let newDisplayTruncatedEndIndex = newDisplayText.index(newDisplayText.endIndex, offsetBy: -2)
                display.text = newDisplayText.substring(to: newDisplayTruncatedEndIndex)
            } else {
                display.text = newDisplayText
            }
        }
    }
    
    private var brain = CalculatorBrain()
    
    private func hasDot() -> Bool {
        if display.text!.range(of: ".") != nil {
            return true
        } else {
            return false
        }
    }
    
    @IBAction private func performOperation(_ sender: UIButton) {
        if userIsInTheMiddleOfTyping {
            brain.setOperand(operand: displayValue)
            userIsInTheMiddleOfTyping = false
        }
        if let mathematicalSymbol = sender.currentTitle {
            brain.performOperation(symbol: mathematicalSymbol)
        }
        if let result = brain.result {
        displayValue = result
        }
    }
    
    @IBAction private func clearCalculatorPressed(_ sender: UIButton) {
        brain.clear()
        if let result = brain.result {
        displayValue = result
        }
        userIsInTheMiddleOfTyping = false
    }
}

