import SwiftUI

struct HomeView: View {
    var body: some View {
        NavigationStack {
            Text("首页")
                .navigationTitle("首页")
        }
    }
}

#Preview {
    HomeView()
}
