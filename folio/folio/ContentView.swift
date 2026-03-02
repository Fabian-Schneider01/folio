//
//  ContentView.swift
//  Folio
//
//  Created by Fabian Schneider on 02.03.26.
//

import SwiftUI

struct ContentView: View {
    @StateObject var viewModel = LibraryViewModel()
    
    var body: some View {
        LibraryView(viewModel: viewModel)
    }
}

#Preview {
    ContentView()
}
