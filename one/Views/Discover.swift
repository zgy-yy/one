import SwiftUI

struct DiscoverView: View {
    @State private var viewModel = FilmViewModel()
    @State private var category: HomeCategory = .film

    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12),
    ]

    var body: some View {
        NavigationStack {
            categoryContent
                .navigationTitle("On-demand")
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
            if viewModel.isLoading && viewModel.films.isEmpty {
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
                        ForEach(viewModel.films) { film in
                            NavigationLink {
                                MovieDetailView(film: film)
                            } label: {
                                VideoCard(
                                    title: film.resolvedTitle,
                                    coverURL: film.thumbURL
                                )
                            }
                            .buttonStyle(.plain)
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
        .onAppear {
            print("hello", viewModel.films)
        }
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
    DiscoverView()
}
