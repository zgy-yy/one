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
            VStack(alignment: .leading, spacing: 0) {
                HomeCategoryBar(selection: $category)
                    .padding(.vertical, 8)

                categoryPage(for: category)
            }
            .toolbar(.hidden, for: .navigationBar)
        }
    }

    @ViewBuilder
    private func categoryPage(for category: HomeCategory) -> some View {
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
                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(viewModel.films) { film in
                            NavigationLink {
                                MovieDetailView(film: film)
                            } label: {
                                FilmCard(
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
    }

    private func placeholderContent(for category: HomeCategory) -> some View {
        ContentUnavailableView(
            category.rawValue,
            systemImage: category.icon,
            description: Text("暂无内容")
        )
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    DiscoverView()
}
