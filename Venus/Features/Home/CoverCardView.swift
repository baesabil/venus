import SwiftUI

/// Kartu cover persegi. Dipakai di tumpukan Home DAN grid Archive.
/// Gambar diambil dari ImageCache (sudah kecil & sudah di-decode).
struct CoverCardView: View {
    let note: Note
    var cornerRadius: CGFloat = Theme.Radius.card

    var body: some View {
        Group {
            if let image = ImageCache.shared.coverImage(for: note) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
            } else {
                ZStack {
                    Theme.surface
                    Image(systemName: "photo")
                        .font(.title)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .aspectRatio(1, contentMode: .fit)
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
        .shadow(color: .black.opacity(0.12), radius: 12, y: 6)
    }
}
