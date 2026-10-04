import SwiftUI

/// Blok foto di dalam note, dengan tombol x untuk menghapus.
struct PhotoBlockView: View {
    let block: NoteBlock
    var onDelete: () -> Void

    var body: some View {
        if let file = block.imageFile, let image = ImageCache.shared.blockImage(named: file) {
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                .overlay(alignment: .topTrailing) {
                    Button(action: onDelete) {
                        Image(systemName: "xmark")
                            .font(.caption.bold())
                            .foregroundStyle(.white)
                            .padding(8)
                            .background(.black.opacity(0.6), in: Circle())
                    }
                    .padding(8)
                }
        }
    }
}
