//
//  ContentView.swift
//  one
//
//  Created by zgy on 6/14/26.
//

import SwiftUI

struct MainView: View {
    var body: some View {
        TabView {
            Tab("首页", systemImage: "house") {
                HomeView()
            }

            Tab("发现", systemImage: "safari") {
                DiscoverView()
            }

            Tab("我的", systemImage: "person") {
                ProfileView()
            }

            Tab(role: .search) {
                SearchView()
            }
        }
    }
}

#Preview {
    MainView()
}
