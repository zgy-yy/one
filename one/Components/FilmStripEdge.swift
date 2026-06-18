import SwiftUI

/// 胶卷下边缘：深色条带 + 方形齿孔
struct FilmStripEdge: View {
    var stripHeight: CGFloat = 20
    var holeSize: CGFloat = 7
    var holeSpacing: CGFloat = 10
    var filmColor: Color = Color.black.opacity(0.6)

    var body: some View {
        Canvas { context, size in
            context.fill(
                Path(CGRect(origin: .zero, size: size)),
                with: .color(filmColor)
            )

            var x = holeSpacing
            let holeY = (size.height - holeSize) / 2

            while x + holeSize <= size.width - holeSpacing {
                let hole = CGRect(x: x, y: holeY, width: holeSize, height: holeSize)
                context.blendMode = .destinationOut
                context.fill(
                    Path(roundedRect: hole, cornerRadius: 1.5),
                    with: .color(.white)
                )
                x += holeSize + holeSpacing
            }
        }
        .compositingGroup()
        .frame(height: stripHeight)
    }
}

#Preview {
    ZStack(alignment: .bottom) {
        Rectangle()
            .fill(.red)
        FilmStripEdge()
    }
    .frame(height: 120)
    .padding()
}
