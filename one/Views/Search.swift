import SwiftUI

struct SearchView: View {
    @State private var searchText = ""

    var body: some View {
        NavigationStack {
            ContentUnavailableView(
                "搜索",
                systemImage: "magnifyingglass",
                description: Text("输入关键词开始搜索")
            )
            .navigationTitle("搜索")
            .searchable(text: $searchText, prompt: "搜索")
        }
    }
}

#Preview {
    SearchView()
}
