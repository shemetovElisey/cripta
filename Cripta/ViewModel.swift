//
//  ViewModel.swift
//  Cripta
//
//  Created by Elisey Shemetov on 04.10.2021.
//

import Foundation

class ViewModel: ObservableObject {
    @Published public var probabylityFileName = "P_P1.txt"
    @Published public var messageFileName = "P1_A.txt"
    @Published public var outputFileName = "output.txt"
    
    @Published public var encryptFileName = "output.txt"
    @Published public var decryptFileName = "decrypt.txt"
    
    @Published private(set) var alphabet = [Alphabet]()
    @Published private(set) var codedMessage = ""
    
    @Published private(set) var avarCodeName = 0.0
    @Published private(set) var redundancy = 0.0
    @Published private(set) var isInequality: Bool? = nil
    
    @Published public var decryptMessage = ""
    
    func buttonTouched() {
        let fileManager = ESFileManager(withProbability: probabylityFileName,
                                   andMessage: messageFileName,
                                   encrypt: encryptFileName)
        let prob = fileManager.getFile(with: .probability)
        let message = fileManager.getFile(with: .message)
        
        self.alphabet = getCode(Converter.convertProbability(prob))
        
        codedMessage = Converter.encryptMessage(message, alph: self.alphabet)
        
        getAvarageCodeLenght()
        getRedundancy()
        getCraftInequality()
        
        fileManager.writeFile(message: codedMessage, name: outputFileName)
    }
    
    func decryptButtonTouched() {
        let fileManager = ESFileManager(withProbability: probabylityFileName,
                                   andMessage: messageFileName,
                                   encrypt: encryptFileName)
        let encryptedMessage = fileManager.getFile(with: .encrypt)
        let prob = fileManager.getFile(with: .probability)
        
        let alphabet = getCode(Converter.convertProbability(prob))
        let decryptedMessage = Converter.decryptMessage(encryptedMessage, alph: alphabet)
        
        fileManager.writeFile(message: decryptedMessage, name: decryptFileName)
        decryptMessage = decryptedMessage
    }
    
    private func getCode(_ alph: [Alphabet]) -> [Alphabet] {
        var sum: Double = 0
        var output = [Alphabet]()
        
        for index in 0..<alph.count {
            let symbol = alph[index]
            let log = Int(-log2(symbol.probability).rounded(.down))
            sum += index - 1 < 0 ? 0 : alph[index - 1].probability
            
            let code = Converter.decimalToBinary(num: sum, prec: log)
            
            
            let result = Alphabet(symbol: alph[index].symbol,
                                  probability: alph[index].probability,
                                  code: code)
            output.append(result)
        }
        
        return output
    }
    
    private func getAvarageCodeLenght() {
        guard alphabet.count > 0 else {
            avarCodeName = 0
            return
        }
        
        var result = 0.0
        
        for symbol in alphabet {
            result += symbol.probability * Double(symbol.code?.count ?? 0)
        }
        
        avarCodeName = result
    }
    
    private func getEntropy() -> Double {
        var result = 0.0
        
        for symbol in alphabet {
            result += symbol.probability * log2(symbol.probability)
        }
        
        return -result
    }
    
    private func getRedundancy() {
        redundancy = avarCodeName - getEntropy()
    }
    
    private func getCraftInequality() {
        var result = 0.0
        
        for symbol in alphabet {
            guard let code = symbol.code else { continue }
            result += pow(2, Double(-code.count))
        }
        
        isInequality = result <= 1 
    }
}

class ESFileManager {
    private var probabilityName: String
    private var messageName: String
    private var encryptName: String
    
    enum ReturnType {
        case probability
        case message
        case encrypt
    }

    init(withProbability probability: String, andMessage message: String, encrypt: String) {
        probabilityName = probability
        messageName = message
        encryptName = encrypt
    }
    
    private func getFileText(_ fileName: String) -> String {
        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let messageURL = dir.appendingPathComponent(fileName)

            do {
                let text = try String(contentsOf: messageURL, encoding: .utf8)
                return text
            } catch {
                return ""
            }
        }
        return ""
    }
    
    func writeFile(message: String, name: String) {
        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let outputURL = dir.appendingPathComponent(name)

            do {
                try message.write(to: outputURL, atomically: true, encoding: .utf8)
            } catch { return }
        }
    }
    
    func getFile(with type: ReturnType) -> String {
        switch type {
        case .probability:
            return getFileText(probabilityName)
        case .message:
            return getFileText(messageName)
        case .encrypt:
            return getFileText(encryptName)
        }
    }
}

struct Alphabet {
    let id = UUID()
    var symbol: String
    var probability: Double
    var code: String?
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
                    result.append(code)
                    break
                }
            }
        }
        
        return result.joined(separator: " ")
    }
    
    static func decryptMessage(_ str: String, alph: [Alphabet]) -> String {
        let strArray = str.split(separator: " ")
        var result = [String]()
        
        for element in strArray {
            for symbol in alph {
                guard let code = symbol.code else { continue }
                if code == element {
                    result.append(symbol.symbol)
                    break
                }
            }
        }
        
        return result.joined(separator: " ")
    }
}
