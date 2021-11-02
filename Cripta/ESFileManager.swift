//
//  ESFileManager.swift
//  Cripta
//
//  Created by Elisey Shemetov on 01.11.2021.
//

import Foundation

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
