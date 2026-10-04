import SwiftUI

/// Isi note versi BACA SAJA (teks, checklist, bullet, foto).
/// Checklist tetap bisa di-tap untuk dicentang tanpa masuk mode edit.
struct DetailBlocksView: View {
    let note: Note

    /// Blok teks kosong (tempat mengetik di bawah) tidak perlu ditampilkan.
    private var blocks: [NoteBlock] {
        note.blocks.filter { !($0.kind == .text && $0.isEmpty) }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ForEach(blocks) { block in
                switch block.kind {
                case .text:
                    Text(RichTextCodec.attributed(from: block.runs))
                        .foregroundStyle(Theme.ink)
                case .checklist:
                    HStack(alignment: .top, spacing: 10) {
                        Button { toggle(block.id) } label: {
                            Image(systemName: block.isChecked ? "checkmark.circle.fill" : "circle")
                                .font(.title3)
                                .foregroundStyle(Theme.ink)
                        }
                        .buttonStyle(.plain)
                        Text(block.plain)
                            .strikethrough(block.isChecked)
                            .foregroundStyle(block.isChecked ? Color.secondary : Theme.ink)
                    }
                case .bullet:
                    HStack(alignment: .top, spacing: 10) {
                        Text("•").frame(width: 22)
                        Text(block.plain)
                    }
                    .foregroundStyle(Theme.ink)
                case .photo:
                    if let file = block.imageFile, let image = ImageCache.shared.blockImage(named: file) {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func toggle(_ id: UUID) {
        var all = note.blocks
        guard let index = all.firstIndex(where: { $0.id == id }) else { return }
        all[index].isChecked.toggle()
        note.blocks = all
        HapticsManager.shared.tap()
    }
}
