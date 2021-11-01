//
//  ContentView.swift
//  Cripta
//
//  Created by Elisey Shemetov on 04.10.2021.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var viewModel = ViewModel()
    
    var body: some View {
        NavigationView {
            List {
                NavigationLink("Encript", destination: EncriptView(viewModel: viewModel))
                NavigationLink("Decript", destination: DecriptView(viewModel: viewModel))
            }
        }
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
