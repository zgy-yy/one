import SwiftUI

struct VideoCard: View {
    let title: String
    var coverURL: URL? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            cover
            Text(title)
                .font(.subheadline)
                .foregroundStyle(.primary)
                .lineLimit(2)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    @ViewBuilder
    private var cover: some View {
        Group {
            if let coverURL {
                AsyncImage(url: coverURL) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                    case .failure:
                        placeholder
                    default:
                        placeholder
                            .overlay { ProgressView() }
                    }
                }
            } else {
                placeholder
            }
        }
        .frame(maxWidth: .infinity)
        .aspectRatio(16 / 9, contentMode: .fit)
        .clipped()
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay {
            Image(systemName: "play.circle.fill")
                .font(.title)
                .foregroundStyle(.white.opacity(0.9))
                .shadow(radius: 4)
        }
    }

    private var placeholder: some View {
        Rectangle()
            .fill(.quaternary)
    }
}

#Preview {
    VideoCard(
        title: "这是一个视频标题，可能会比较长所以限制两行显示",
        coverURL: URL(string: "https://picsum.photos/400/225")
    )
    .frame(width: 180)
    .padding()
}
