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
    @Published public var mistakeString: String = ""
    
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
        
        fileManager.writeFile(message: decryptedMessage.toString(), name: decryptFileName)
        decryptMessage = decryptedMessage.toString()
        
        let mistakePositions: [Int] = decryptedMessage
                                        .filter({ $0.hasMistake })
                                        .compactMap {
                                            let symbol = $0
                                            return decryptedMessage.firstIndex { $0 == symbol }
                                        }
        
        mistakeString = mistakePositions.count > 0 ? "Порядковые номера слов с ошибкой: " + mistakePositions.map({ String($0 + 1) }).joined(separator: ", ") : "Ошибок нет"
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
