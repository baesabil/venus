import SwiftUI
import SwiftData

/// Halaman awal: tumpukan cover, tombol + di bawah, ikon search di kanan atas.
struct HomeView: View {
    @Query(sort: \Note.createdAt, order: .reverse) private var notes: [Note]

    @State private var showNewNote = false
    @State private var editingNote: Note?
    @State private var noteToDelete: Note?

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.background.ignoresSafeArea()
                if notes.isEmpty {
                    emptyState
                } else {
                    CardStackView(
                        notes: notes,
                        onOpen: { editingNote = $0 },
                        onDelete: { noteToDelete = $0 }
                    )
                }
            }
            .safeAreaInset(edge: .bottom) {
                AddNoteButton { showNewNote = true }
                    .padding(.bottom, 8)
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink {
                        ArchiveView()
                    } label: {
                        Image(systemName: "magnifyingglass")
                            .foregroundStyle(Theme.ink)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
        }
        .fullScreenCover(isPresented: $showNewNote) { NoteEditorView(note: nil) }
        .fullScreenCover(item: $editingNote) { NoteEditorView(note: $0) }
        .deleteConfirmation(note: $noteToDelete)
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            RoundedRectangle(cornerRadius: Theme.Radius.card, style: .continuous)
                .strokeBorder(style: StrokeStyle(lineWidth: 2, dash: [8]))
                .foregroundStyle(.secondary.opacity(0.5))
                .frame(width: 260, height: 260)
                .overlay {
                    Image(systemName: "photo.on.rectangle.angled")
                        .font(.system(size: 44))
                        .foregroundStyle(.secondary)
                }
            Text("Tap + to write your first note")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }
}
