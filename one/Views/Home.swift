import SwiftUI

struct HomeView: View {
    @State private var viewModel = FilmViewModel()
    @State private var category: HomeCategory = .film

    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12),
    ]

    var body: some View {
        NavigationStack {
            categoryContent
                .navigationTitle("首页")
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        HomeCategoryBar(selection: $category)
                            .frame(maxWidth: 280)
                    }
                }
        }
    }

    @ViewBuilder
    private var categoryContent: some View {
        switch category {
        case .film:
            filmContent
        case .article:
            placeholderContent(title: "图文", icon: "photo.on.rectangle")
        case .text:
            placeholderContent(title: "文本", icon: "doc.text")
        }
    }

    @ViewBuilder
    private var filmContent: some View {
        Group {
            if viewModel.isLoading && viewModel.videos.isEmpty {
                ProgressView()
            } else if let errorMessage = viewModel.errorMessage {
                ContentUnavailableView(
                    "加载失败",
                    systemImage: "wifi.exclamationmark",
                    description: Text(errorMessage)
                )
            } else {
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(viewModel.videos) { video in
                            VideoCard(
                                title: video.title,
                                coverURL: video.coverURL
                            )
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .refreshable { await viewModel.load() }
        .task { await viewModel.load() }
    }

    private func placeholderContent(title: String, icon: String) -> some View {
        ContentUnavailableView(
            title,
            systemImage: icon,
            description: Text("暂无内容")
        )
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    HomeView()
}
