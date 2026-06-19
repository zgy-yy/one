import SwiftUI

enum DiscoveryCategory: String, CaseIterable, Identifiable {
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

struct DiscoveryCategoryBar: View {
    @Binding var selection: DiscoveryCategory

    @Namespace private var indicator
    var height: CGFloat = 16
    var barHeight: CGFloat = 36

    var body: some View {
        GlassEffectContainer {
            Color.white.opacity(0)
                .frame(height: max(height - barHeight, 0))
            HStack(spacing: 2) {
                ForEach(DiscoveryCategory.allCases) { category in
                    categoryButton(category)
                }
            }
            .frame(height: barHeight)
            .glassEffect(.clear, in: .capsule)
        }
        .padding()
        .glassEffect(.regular, in: .rect(cornerRadius: 18))

    }

    private func categoryButton(_ category: DiscoveryCategory) -> some View {
        let isSelected = selection == category

        return Button {
            withAnimation(.spring(response: 0.32, dampingFraction: 0.82)) {
                selection = category
            }
        } label: {
            Text(category.rawValue)
                .font(.caption.weight(isSelected ? .semibold : .regular))
                .foregroundStyle(
                    isSelected ? Color(uiColor: .label) : Color(uiColor: .secondaryLabel)
                )
                .lineLimit(1)
                .minimumScaleFactor(0.75)
                .frame(maxWidth: .infinity)
                .frame(height: barHeight - 12)
                .background {
                    if isSelected {
                        selectedBackground
                    }
                }

        }
        .buttonStyle(.plain)
    }

    private var selectedBackground: some View {
        Capsule()
            .fill(Color(uiColor: .systemBackground).opacity(0.58))
            .glassEffectID("indicator", in: indicator)
            .matchedGeometryEffect(id: "indicator", in: indicator)
    }
}

#Preview {
    @Previewable @State var selection = DiscoveryCategory.film
    ZStack(alignment: .top) {
        ScrollView {
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                ForEach(0..<12, id: \.self) { index in
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(hue: Double(index) / 12, saturation: 0.45, brightness: 0.85))
                        .aspectRatio(16 / 9, contentMode: .fit)
                }
            }
            .padding(.horizontal, 16)
            .safeAreaPadding(.top, 48)
        }

        DiscoveryCategoryBar(selection: $selection)
            .padding(.top, 4)
    }.ignoresSafeArea(.all, edges: .top)
}
