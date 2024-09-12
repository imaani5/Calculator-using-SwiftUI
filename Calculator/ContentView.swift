//
//  ContentView.swift
//  Calculator
//
//  Created by Salman Sagheer on 11/09/2024.
//

import SwiftUI

enum CalcButton: String {
    case one = "1"
    case two = "2"
    case three = "3"
    case four = "4"
    case five = "5"
    case six = "6"
    case seven = "7"
    case eight = "8"
    case nine = "9"
    case zero = "0"
    case add = "+"
    case subtract = "−"
    case divide = "÷"
    case multiply = "×"
    case equal = "="
    case clear = "AC"
    case decimal = "."
    case percent = "%"
    case negative = "-/+"
    
    var buttonColor: Color {
        switch self {
        case .add, .subtract, .multiply, .divide, .equal:
            return .orange
        case .clear, .negative, .percent:
            return Color(.lightGray)
        default:
            return Color(UIColor(red: 55/255.0, green: 55/255.0, blue: 55/255.0, alpha: 1))
        }
    }
}

enum Operation {
    case add, subtract, multiply, divide, none
}

struct ContentView: View {
    @State private var value = "0"
    @State private var runningNumber = NSDecimalNumber(value: 0)
    @State private var currentOperation: Operation = .none
    @State private var isDecimalMode = false
    @State private var didPressOperation = false
    @State private var selectedOperator: CalcButton? = nil
    @State private var acButtonText = "AC"
    
    let buttons: [[CalcButton]] = [
        [.clear, .negative, .percent, .divide],
        [.seven, .eight, .nine, .multiply],
        [.four, .five, .six, .subtract],
        [.one, .two, .three, .add],
        [.zero, .decimal, .equal],
    ]
    
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            VStack {
                Spacer()
                
                HStack {
                    Spacer()
                    Text(value)
                        .bold()
                        .font(.system(size: getFontSize()))
                        .foregroundColor(.white)
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)
                }
                .padding()
                
                createButtonGrid()
            }
        }
    }
    
    func createButtonGrid() -> some View {
        VStack {
            ForEach(buttons, id: \.self) { row in
                HStack(spacing: 12) {
                    ForEach(row, id: \.self) { item in
                        createButton(for: item)
                    }
                }
                .padding(.bottom, 3)
            }
        }
    }
    
    func createButton(for item: CalcButton) -> some View {
        Button(action: {
            self.didTap(button: item)
        }, label: {
            Text(item == .clear ? acButtonText : item.rawValue)
                .font(.system(size: 32, weight: .medium))
                .frame(width: self.buttonWidth(item: item), height: self.buttonHeight())
                .background(self.selectedOperator == item ? Color.white : item.buttonColor)
                .foregroundColor(self.selectedOperator == item ? .orange : .white)
                .cornerRadius(self.buttonWidth(item: item)/2)
        })
    }
    
    func didTap(button: CalcButton) {
        switch button {
        case .add, .subtract, .multiply, .divide:
            self.selectedOperator = button
            handleOperation(button)
        case .equal:
            handleEqualOperation()
        case .clear:
            self.value = "0"
            self.isDecimalMode = false
            self.currentOperation = .none
            self.acButtonText = "AC"
        case .negative:
            toggleNegative()
        case .percent:
            applyPercentage()
        case .decimal:
            addDecimal()
        default:
            appendNumber(button.rawValue)
            self.selectedOperator = nil
        }
    }
    
    func handleOperation(_ button: CalcButton) {
        if self.didPressOperation {
            self.handleEqualOperation()
        }
        self.selectedOperator = button
        if button == .add { self.currentOperation = .add }
        else if button == .subtract { self.currentOperation = .subtract }
        else if button == .multiply { self.currentOperation = .multiply }
        else if button == .divide { self.currentOperation = .divide }
        
        self.runningNumber = NSDecimalNumber(string: self.value)
        self.didPressOperation = true
        self.acButtonText = "C"
    }
    
    func handleEqualOperation() {
        let currentValue = NSDecimalNumber(string: self.value)
        let result: NSDecimalNumber
        
        switch self.currentOperation {
        case .add:
            result = runningNumber.adding(currentValue)
        case .subtract:
            result = runningNumber.subtracting(currentValue)
        case .multiply:
            result = runningNumber.multiplying(by: currentValue)
        case .divide:
            if currentValue != NSDecimalNumber.zero {
                result = runningNumber.dividing(by: currentValue)
            } else {
                self.value = "Error"
                return
            }
        case .none:
            result = currentValue
        }
        
        if result == NSDecimalNumber.notANumber {
            self.value = "Error"
        } else {
            self.value = formatResult(result: result)
            self.runningNumber = result 
        }
    }
    
    func toggleNegative() {
        if self.value != "0" {
            if self.value.hasPrefix("-") {
                self.value.removeFirst()
            } else {
                self.value = "-" + self.value
            }
        }
    }
    
    func applyPercentage() {
        let currentValue = NSDecimalNumber(string: self.value)
        self.value = formatResult(result: currentValue.dividing(by: NSDecimalNumber(value: 100)))
    }
    
    func addDecimal() {
        if !self.value.contains(".") {
            self.value += "."
            self.isDecimalMode = true
        }
    }
    
    func appendNumber(_ number: String) {
        if self.value == "0" || self.didPressOperation {
            value = number
            self.didPressOperation = false
        } else {
            self.value = "\(self.value)\(number)"
        }
        self.acButtonText = "C"
    }
    
    func formatResult(result: NSDecimalNumber) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.positiveFormat = "0.####"
        formatter.negativeFormat = "-0.####"
        
        let resultValue = result.doubleValue
        if abs(resultValue) >= 1e10 || abs(resultValue) < 1e-10 {
            return formatter.string(from: result) ?? "Error"
        } else {
            return result.stringValue
        }
    }
    
    func getFontSize() -> CGFloat {
        let numberOfCharacters = value.count
        if numberOfCharacters > 12 {
            return 50
        }
        return 100
    }
    
    func buttonWidth(item: CalcButton) -> CGFloat {
        if item == .zero {
            return ((UIScreen.main.bounds.width - (4 * 12)) / 4) * 2
        }
        return (UIScreen.main.bounds.width - (5 * 12)) / 4
    }
    
    func buttonHeight() -> CGFloat {
        return (UIScreen.main.bounds.width - (5 * 12)) / 4
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}














