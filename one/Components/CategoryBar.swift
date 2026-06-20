import SwiftUI

protocol CategoryTab: RawRepresentable, CaseIterable, Identifiable, Hashable where RawValue == String {
    var icon: String { get }
}

enum DiscoveryCategory: String, CaseIterable, Identifiable, Hashable, CategoryTab {
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

enum OnDemandCategory: String, CaseIterable, Identifiable, Hashable, CategoryTab {
    case us = "欧美"
    case japan = "日韩"
    case china = "国产"
    case all = "全部"
    case lottery = "抽奖"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .us: "globe"
        case .japan: "japan.fill"
        case .china: "china.fill"
        case .all: "globe.fill"
        case .lottery: "gift.fill"
        }
    }
}

struct CategoryBar<Category: CategoryTab>: View {
    @Binding var selection: Category

    var height: CGFloat = 96

    var body: some View {
        GlassEffectContainer {
            Spacer()
            Picker("分类", selection: $selection) {
                ForEach(Array(Category.allCases)) { category in
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

#Preview("发现") {
    @Previewable @State var selection = DiscoveryCategory.film
    ZStack(alignment: .top) {
        Color.gray.opacity(0.2)
        CategoryBar(selection: $selection)
            .padding(.top, 4)
    }
    .ignoresSafeArea(.all, edges: .top)
}

#Preview("点播") {
    @Previewable @State var selection = OnDemandCategory.all
    ZStack(alignment: .top) {
        Color.gray.opacity(0.2)
        CategoryBar(selection: $selection)
            .padding(.top, 4)
    }
    .ignoresSafeArea(.all, edges: .top)
}
