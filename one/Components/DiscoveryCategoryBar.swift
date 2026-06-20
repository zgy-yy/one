import SwiftUI

enum DiscoveryCategory: String, CaseIterable, Identifiable, Hashable {
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

    var height: CGFloat = 96

    var body: some View {
        GlassEffectContainer {
            Spacer()
            Picker("分类", selection: $selection) {
                ForEach(DiscoveryCategory.allCases) { category in
                    Text(category.rawValue)
                        .tag(category)
                }
            }
            .pickerStyle(.segmented)
            .padding()
        }
        .frame(height: height)
        .glassEffect(.clear, in: .rect(cornerRadius: 18))
        .ignoresSafeArea(.container, edges: .top)
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
