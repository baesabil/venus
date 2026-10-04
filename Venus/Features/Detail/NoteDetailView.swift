import SwiftUI

/// Tampilan NOTE (mode baca): cover penuh di atas, lembar putih melengkung
/// berisi tanggal, judul, lagu (kalau ada), lalu isi note.
/// Tombol back (kiri) dari NavigationStack, jadi swipe-back juga jalan.
/// Tombol pensil (kanan) membuka editor.
struct NoteDetailView: View {
    let note: Note
    @State private var showEditor = false

    private var hasSong: Bool { !(note.songURL ?? "").isEmpty }

    var body: some View {
        ScrollView {
            // spacing negatif = lembar putih menimpa bagian bawah cover
            VStack(spacing: -32) {
                cover
                sheet
            }
        }
        .ignoresSafeArea(edges: .top)
        .background(Theme.paper.ignoresSafeArea())
        .toolbarBackground(.hidden, for: .navigationBar)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button { showEditor = true } label: {
                    Image(systemName: "pencil").foregroundStyle(Theme.ink)
                }
            }
        }
        .fullScreenCover(isPresented: $showEditor) { NoteEditorView(note: note) }
    }

    private var cover: some View {
        Color.clear
            .aspectRatio(1, contentMode: .fit)
            .overlay {
                if let image = ImageCache.shared.detailCover(for: note) {
                    Image(uiImage: image).resizable().scaledToFill()
                } else {
                    Theme.surface.overlay {
                        Image(systemName: "photo").font(.largeTitle).foregroundStyle(.secondary)
                    }
                }
            }
            .clipped()
    }

    private var sheet: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(note.createdAt.formatted(.dateTime.day().month(.wide).year()))
                .font(.footnote)
                .foregroundStyle(.secondary)

            if !note.title.isEmpty {
                Text(note.title)
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(Theme.ink)
            }

            // Lagu: tepat di bawah judul, hanya muncul kalau note ini punya lagu.
            if hasSong {
                SongBar(note: note)
            }

            DetailBlocksView(note: note)
        }
        .padding(.horizontal, 24)
        .padding(.top, 28)
        .padding(.bottom, 40)
        .frame(maxWidth: .infinity, minHeight: 480, alignment: .topLeading)
        .background(
            UnevenRoundedRectangle(topLeadingRadius: 32, topTrailingRadius: 32, style: .continuous)
                .fill(Theme.paper)
        )
    }
}
