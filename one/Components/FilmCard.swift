import SwiftUI

struct FilmCard: View {
    let title: String  // 视频标题
    let author: String  // 视频作者
    let viewCount: Int  // 视频播放量
    let likeCount: Int  // 视频点赞量
    let publishedAt: String  // 视频发布时间
    var coverURL: URL? = nil

    var body: some View {
        HStack(spacing: 2) {
            cover
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .foregroundStyle(.primary)
                    .lineSpacing(2)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)

                Text("出品 / " + author)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                    .multilineTextAlignment(.leading)
                Text(publishedDate)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                HStack(spacing: 8) {
                    Image(systemName: "eye")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(viewCount.formatted())
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                        .multilineTextAlignment(.leading)
                    Image(systemName: "heart")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                        .multilineTextAlignment(.leading)
                    Text(likeCount.formatted())
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                        .multilineTextAlignment(.leading)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var publishedDate: String {
        publishedAt.split(separator: " ").first.map(String.init) ?? publishedAt
    }

    @ViewBuilder
    private var cover: some View {
        GeometryReader { proxy in
            let height = proxy.size.height
            let width = height * 16 / 9

            Group {
                if let coverURL {
                    ImageView(url: coverURL, maxPixelSize: 480)
                } else {
                    placeholder
                }
            }
            .frame(width: width, height: height)
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
    }

    private var placeholder: some View {
        Rectangle()
            .fill(.quaternary)
    }
}

#Preview {
    FilmCard(
        title: "这是一个视频标题，可能会比较长所以限制两行显示",
        author: "comatozze",
        viewCount: 1000,
        likeCount: 100,
        publishedAt: "2026-06-18 00:00:00",
        coverURL: URL(string: "https://imgpw807.s7n7ue8.com/storage/thumb/52971/6a3406e8278a1.gif")
    )
    .frame(maxWidth: .infinity, maxHeight: 90)
    .padding()
}
