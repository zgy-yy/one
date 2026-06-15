import SwiftUI

enum HomeCategory: String, CaseIterable, Identifiable {
    case article = "图文"
    case film = "影视"
    case text = "文本"

    var id: String { rawValue }
}

struct HomeCategoryBar: View {
    @Binding var selection: HomeCategory

    var body: some View {
        HStack(spacing: 16) {
            ForEach(HomeCategory.allCases) { category in
                Button {
                    selection = category
                } label: {
                    Text(category.rawValue)
                        .font(.subheadline.weight(selection == category ? .semibold : .regular))
                        .foregroundStyle(selection == category ? .primary : .secondary)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background {
                            if selection == category {
                                Capsule()
                                    .fill(.quaternary)
                            }
                        }
                }
                .buttonStyle(.plain)
            }
        }
    }
}

#Preview {
    @Previewable @State var selection = HomeCategory.film
    HomeCategoryBar(selection: $selection)
        .padding()
}
