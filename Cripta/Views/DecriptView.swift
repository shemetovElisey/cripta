//
//  DecriptView.swift
//  Cripta
//
//  Created by Elisey Shemetov on 17.10.2021.
//

import SwiftUI

struct DecriptView: View {
    @ObservedObject var viewModel: ViewModel
    @State var isNeedToShowAlert = false
    
    var body: some View {
        VStack {
            VStack {
                HStack {
                    TextField("Имя файла вероятностей", text: $viewModel.probabylityFileName)
                    TextField("Имя файла с зашифрованным сообщением", text: $viewModel.encryptFileName)
                    TextField("Имя файла c расшифрованным сообщением", text: $viewModel.decryptFileName)
                }
                
                Button("Выполнить") {
                    viewModel.decryptButtonTouched()
                    isNeedToShowAlert = viewModel.decryptMessage.count == 0
                }.alert(isPresented: $isNeedToShowAlert) {
                    Alert(title: Text("Ошибка"), message: Text("Неверное имя файла или его содержимое"), dismissButton: .cancel(Text("OK")))
                }
            }
            
    
            Text(viewModel.decryptMessage)
            
            Spacer()
            
            Text(viewModel.mistakeString)
            
            Spacer()
            
        }.frame(alignment: .top)
        
    }
}

