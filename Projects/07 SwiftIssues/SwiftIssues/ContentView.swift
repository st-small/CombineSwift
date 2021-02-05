//
//  ContentView.swift
//  SwiftIssues
//
//  Created by Stanly Shiyanovskiy on 28.12.2020.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationView {
            IssuesList()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
