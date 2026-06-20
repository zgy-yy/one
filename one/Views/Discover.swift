import SwiftUI

struct DiscoverView: View {
    @State private var viewModel = FilmViewModel()
    @State private var category: DiscoveryCategory = .film
    @State private var scrollCategory: DiscoveryCategory?

    private let categoryBarHeight: CGFloat = 106

    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                categoryPages
                DiscoveryCategoryBar(
                    selection: $category, height: categoryBarHeight,
                )
                .zIndex(1)
            }
            .ignoresSafeArea(.container, edges: .top)

        }
    }

    private var categoryPages: some View {
        ScrollView(.horizontal) {
            HStack(spacing: 0) {
                ForEach(DiscoveryCategory.allCases) { category in
                    categoryPage(for: category)
                        .containerRelativeFrame(.horizontal)
                        .id(category)
                }
            }
            .scrollTargetLayout()
        }
        .scrollIndicators(.hidden)
        .scrollTargetBehavior(.paging)
        .scrollPosition(id: $scrollCategory)
        .task {
            scrollCategory = category
        }
        .onChange(of: category) { _, newValue in
            guard scrollCategory != newValue else { return }
            withAnimation(.snappy) {
                scrollCategory = newValue
            }
        }
        .onChange(of: scrollCategory) { _, newValue in
            guard let newValue, category != newValue else { return }
            category = newValue
        }
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
                    LazyVStack(spacing: 12) {
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
                            }
                            .buttonStyle(.plain)
                        }
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
