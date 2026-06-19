import SwiftUI

struct DiscoverView: View {
    @State private var viewModel = FilmViewModel()
    @State private var category: DiscoveryCategory = .film

    private let categoryBarHeight: CGFloat = 44

    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                categoryPage(for: category).padding(.top, 66)
                DiscoveryCategoryBar(selection: $category, height: 66)
            }.ignoresSafeArea(.container, edges: .top)
        }
        .toolbar(.hidden, for: .navigationBar)
    }

    @ViewBuilder
    private func categoryPage(for category: DiscoveryCategory) -> some View {
        switch category {
        case .film:
            filmContent
        default:
            placeholderContent(for: category)
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
                    ForEach(viewModel.films) { film in
                        NavigationLink {
                            MovieDetailView(film: film)
                        } label: {
                            FilmCard(
                                title: film.resolvedTitle,
                                author: film.author ?? "",
                                viewCount: film.views ?? 0,
                                likeCount: film.likeNumber ?? 0,
                                publishedAt: film.publishedAt ?? "",
                                coverURL: film.coverURL
                            )
                            .frame(height: 90)
                            .frame(maxWidth: .infinity)
                            .padding(.horizontal, 16)
                            .padding(.bottom, 12)
                        }
                        .buttonStyle(.plain)
                    }

                }
                .safeAreaPadding(.top, categoryBarHeight)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .refreshable { await viewModel.load() }
        .task { await viewModel.load() }
    }

    private func placeholderContent(for category: DiscoveryCategory) -> some View {
        ContentUnavailableView(
            category.rawValue,
            systemImage: category.icon,
            description: Text("暂无内容")
        )
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .safeAreaPadding(.top, categoryBarHeight)
    }
}

#Preview {
    DiscoverView()
}
