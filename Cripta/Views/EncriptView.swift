//
//  EncriptView.swift
//  Cripta
//
//  Created by Elisey Shemetov on 17.10.2021.
//

import SwiftUI

struct EncriptView: View {
    @ObservedObject var viewModel: ViewModel
    @State var isNeedToShowAlert = false
    
    var body: some View {
        VStack {
            VStack {
                HStack {
                    TextField("Имя файла вероятностей", text: $viewModel.probabylityFileName)
                    TextField("Имя файла c сообщением", text: $viewModel.messageFileName)
                    TextField("Имя файла для результата", text: $viewModel.outputFileName)
                }
                
                Button("Выполнить") {
                    viewModel.buttonTouched()
                    isNeedToShowAlert = viewModel.avarCodeName == 0
                }.alert(isPresented: $isNeedToShowAlert) {
                    Alert(title: Text("Ошибка"), message: Text("Неверное имя файла или его содержимое"), dismissButton: .cancel(Text("OK")))
                }
            }
            
            HStack {
                Text("Символ").frame(width: 50, alignment: .leading)
                Text("Вероятность").frame(width: 100, alignment: .center)
                Text("Код").frame(width: 50, alignment: .trailing)
            }.padding()
            
            ForEach(viewModel.alphabet, id: \.id) { symbol in
                HStack {
                    Text(symbol.symbol).frame(width: 50, alignment: .leading)
                    Text("\(symbol.probability)").frame(width: 100, alignment: .center)
                    Text(symbol.code ?? "").frame(width: 50, alignment: .trailing)
                }
            }
            
            Text("Средняя длинна кодового слова: \(viewModel.avarCodeName)").foregroundColor(.orange).padding([.top])
            Text("Избыточность: \(viewModel.redundancy)").foregroundColor(.blue)
            Text(viewModel.isInequality == nil ? "" :
                    (viewModel.isInequality == true ? "Неравество Крафта выполняется" :
                        "Неравество Крафта не выполняется")).foregroundColor( viewModel.isInequality == true ? .green : .red).padding([.bottom])
            
            Spacer()
        }
        
    }
}
