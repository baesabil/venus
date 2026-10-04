import SwiftUI
import PencilKit

/// "Kanvas" cover: foto + coretan + teks, ditumpuk jadi satu.
///
/// Ukurannya SELALU 360 x 360 (koordinat logis). Supaya muat di layar, view ini
/// dibungkus ScaledCoverContainer yang memperbesar/memperkecilnya.
/// Karena koordinatnya tetap, gambar tangan & posisi teks selalu pas.
/// View yang sama dipakai untuk preview, editor, DAN render akhir (CoverRenderer).
struct CoverCanvasView: View {
    static let side: CGFloat = 360

    let baseImage: UIImage?
    var photoScale: CGFloat = 1
    var photoOffset: CGSize = .zero            // pecahan dari `side`
    @Binding var layers: [CoverTextLayer]
    @Binding var selectedID: UUID?
    var drawing = PKDrawing()
    var showDrawing = true                     // false saat mode Draw (diganti kanvas hidup)
    var isInteractive = false                  // true saat mode Text (teks bisa digeser)

    var body: some View {
        let side = Self.side
        ZStack {
            Color(white: 0.9)   // warna dasar kalau belum ada foto

            if let baseImage {
                Image(uiImage: baseImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: side, height: side)
                    .clipped()
                    .scaleEffect(photoScale)
                    .offset(x: photoOffset.width * side, y: photoOffset.height * side)
            }

            if showDrawing {
                Image(uiImage: drawing.image(from: CGRect(x: 0, y: 0, width: side, height: side), scale: 3))
                    .resizable()
                    .frame(width: side, height: side)
                    .allowsHitTesting(false)
            }

            ForEach($layers) { $layer in
                CoverTextLayerView(
                    layer: $layer,
                    side: side,
                    isSelected: selectedID == layer.id,
                    isInteractive: isInteractive,
                    onSelect: { selectedID = layer.id }
                )
            }
        }
        .frame(width: side, height: side)
        .clipped()
        .coordinateSpace(name: "cover")
        .contentShape(Rectangle())
        .onTapGesture { if isInteractive { selectedID = nil } }   // tap area kosong = batal pilih
    }
}

/// Membungkus kanvas 360x360 supaya pas dengan lebar yang tersedia.
struct ScaledCoverContainer<Content: View>: View {
    @ViewBuilder var content: () -> Content

    var body: some View {
        GeometryReader { geo in
            content()
                .frame(width: CoverCanvasView.side, height: CoverCanvasView.side)
                .scaleEffect(geo.size.width / CoverCanvasView.side, anchor: .topLeading)
                .frame(width: geo.size.width, height: geo.size.width, alignment: .topLeading)
        }
        .aspectRatio(1, contentMode: .fit)
    }
}
