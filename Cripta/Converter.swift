//
//  Converter.swift
//  Cripta
//
//  Created by Elisey Shemetov on 01.11.2021.
//

import Cocoa

struct Alphabet {
    let id = UUID()
    var symbol: String
    var probability: Double
    var code: String?
}

struct DecryptedSymbol: Equatable {
    var element: String
    let hasMistake: Bool
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.hasMistake == rhs.hasMistake && lhs.element == rhs.element
    }
}

class Converter {
    static let symbols = ["2", "20", "200", "0", "00", "_"]
    
    static func decimalToBinary(num: Double, prec: Int) -> String {
        var binary = ""
        var fractional = num
        var k_prec = prec
        
        while k_prec != 0 {
            fractional *= 2
            let fractBit = Int(fractional)
            
            if fractBit == 1 {
                fractional -= Double(fractBit)
                binary.append("1")
            } else {
                binary.append("0")
            }
            
            k_prec -= 1
        }
        
        return binary
    }
    
    static func convertProbability(_ str: String) -> [Alphabet] {
        let symbols = ["2", "20", "200", "0", "00", "_"]
        let strArray = str.split(separator: " ")
        
        var alphabet = [Alphabet]()
        
        for index in 0..<symbols.count {
            guard index < strArray.count else { return [] }
            alphabet.append(Alphabet(symbol: symbols[index],
                                     probability: Double(strArray[index]) ?? 0))
        }
        
        return alphabet.sorted(by: { $0.probability > $1.probability })
    }
    
    static func encryptMessage(_ str: String, alph: [Alphabet]) -> String {
        let strArray = str.split(separator: " ")
        var result = [String]()
        
        for element in strArray {
            for symbol in alph {
                if symbol.symbol == element,
                   let code = symbol.code {
                    let newCode = code.count(of: "1") % 2 == 0 ? code + "0" : code + "1"
                    result.append(newCode)
                    break
                }
            }
        }
        
        return result.joined(separator: " ")
    }
    
    static func decryptMessage(_ str: String, alph: [Alphabet]) -> [DecryptedSymbol] {
        let strArray = str.split(separator: " ")
        var result = [DecryptedSymbol]()
        
        for element in strArray {
            let strElement = String(element)
            let hasMistake = strElement.count(of: "1") % 2 != 0
            var trueElement = DecryptedSymbol(element: hasMistake ? strElement : String(strElement.dropLast()),
                                              hasMistake: hasMistake)
            if !trueElement.hasMistake {
                for symbol in alph {
                    guard let code = symbol.code else { continue }
                    
                    if code == trueElement.element {
                        trueElement.element = symbol.symbol
                        result.append(trueElement)
                        break
                    }
                }
            } else {
                result.append(trueElement)
            }
        }
        
        return result
    }
}

extension String {
    func count(of needle: Character) -> Int {
        return reduce(0) {
            $1 == needle ? $0 + 1 : $0
        }
    }
}

extension Array where Element == DecryptedSymbol {
    func toString() -> String {
        return self.map({ $0.element }).joined(separator: " ")
    }
}
