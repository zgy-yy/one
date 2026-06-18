import SwiftUI

struct Tag: View {
    let title: String

    var body: some View {
        Text(title)
            .font(.caption)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(.quaternary)
            .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

#Preview {
    Tag(title: "标签")
}
