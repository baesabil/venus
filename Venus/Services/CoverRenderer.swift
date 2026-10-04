import SwiftUI
import PencilKit

/// Menggabungkan foto + coretan + teks cover menjadi 1 gambar JPEG persegi.
/// Dipanggil sekali saat note disimpan; setelah itu kartu cukup menampilkan
/// gambar jadi (jauh lebih ringan daripada menggambar ulang semua layer).
@MainActor
enum CoverRenderer {
    static func render(base: UIImage?,
                       photoScale: CGFloat,
                       photoOffset: CGSize,
                       layers: [CoverTextLayer],
                       drawing: PKDrawing) -> Data? {
        let view = CoverCanvasView(
            baseImage: base,
            photoScale: photoScale,
            photoOffset: photoOffset,
            layers: .constant(layers),
            selectedID: .constant(nil),
            drawing: drawing
        )
        let renderer = ImageRenderer(content: view)
        renderer.scale = 3                       // 360pt x 3 = 1080px
        return renderer.uiImage?.jpegData(compressionQuality: 0.85)
    }
}
