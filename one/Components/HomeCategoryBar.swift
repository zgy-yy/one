import SwiftUI

enum HomeCategory: String, CaseIterable, Identifiable {
    case article = "图文"
    case text = "阅读"
    case film = "影视"
    case radio = "电台"
    case photo = "写真"
    case comic = "漫画"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .article: "doc.richtext"
        case .film: "film.stack"
        case .text: "text.book.closed.fill"
        case .radio: "dot.radiowaves.left.and.right"
        case .photo: "photo.fill"
        case .comic: "books.vertical.fill"
        }
    }
}

struct HomeCategoryBar: View {
    @Binding var selection: HomeCategory

    @Namespace private var indicator

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 2) {
                    ForEach(HomeCategory.allCases) { category in
                        Button {
                            withAnimation(.spring(response: 0.32, dampingFraction: 0.82)) {
                                selection = category
                            }
                        } label: {
                            Text(category.rawValue)
                                .font(
                                    .subheadline.weight(
                                        selection == category ? .semibold : .regular)
                                )
                                .foregroundStyle(.primary)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background {
                                    if selection == category {
                                        Capsule()
                                            .fill(.background)
                                            .matchedGeometryEffect(id: "indicator", in: indicator)
                                            .shadow(color: .black.opacity(0.06), radius: 2, y: 1)
                                    }
                                }
                        }
                        .buttonStyle(.plain)
                        .id(category)
                    }
                }
                .padding(4)
            }
            .background {
                Capsule()
                    .fill(Color(.systemGray5))
            }
            .onChange(of: selection) { _, newValue in
                withAnimation(.easeInOut(duration: 0.25)) {
                    proxy.scrollTo(newValue, anchor: .center)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 16)
    }
}

#Preview {
    @Previewable @State var selection = HomeCategory.film
    HomeCategoryBar(selection: $selection)
        .padding(.vertical)
}
