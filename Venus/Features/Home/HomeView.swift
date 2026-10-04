import SwiftUI
import SwiftData

/// Halaman awal: sapaan, tumpukan cover, tombol + di bawah, ikon search di kanan atas.
struct HomeView: View {
    @Query(sort: \Note.createdAt, order: .reverse) private var notes: [Note]

    /// Nama disimpan di HP (UserDefaults) lewat @AppStorage.
    @AppStorage("userName") private var userName = AppCopy.defaultName

    @State private var showNewNote = false
    @State private var viewingNote: Note?
    @State private var noteToDelete: Note?
    @State private var showNameAlert = false
    @State private var nameDraft = ""

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.background.ignoresSafeArea()
                VStack(spacing: 0) {
                    greeting
                    if notes.isEmpty {
                        emptyState.frame(maxHeight: .infinity)
                    } else {
                        CardStackView(
                            notes: notes,
                            onOpen: { viewingNote = $0 },
                            onDelete: { noteToDelete = $0 }
                        )
                    }
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
            // Tap cover -> halaman detail (mode baca), bukan editor.
            .navigationDestination(item: $viewingNote) { NoteDetailView(note: $0) }
        }
        .fullScreenCover(isPresented: $showNewNote) { NoteEditorView(note: nil) }
        .deleteConfirmation(note: $noteToDelete)
        .alert(AppCopy.nameAlertTitle, isPresented: $showNameAlert) {
            TextField("Your name", text: $nameDraft)
            Button("Save") {
                let trimmed = nameDraft.trimmingCharacters(in: .whitespacesAndNewlines)
                if !trimmed.isEmpty { userName = trimmed }
            }
            Button("Cancel", role: .cancel) {}
        }
    }

    /// Sapaan. Teksnya diatur di Design/AppCopy.swift. Tap untuk ganti nama.
    private var greeting: some View {
        Button {
            nameDraft = userName
            showNameAlert = true
        } label: {
            VStack(alignment: .leading, spacing: 4) {
                Text(AppCopy.greeting(name: userName))
                    .font(.system(size: 30, weight: .bold))
                    .foregroundStyle(Theme.ink)
                Text(AppCopy.greetingSubtitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 24)
            .padding(.top, 8)
        }
        .buttonStyle(.plain)
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
            Text(AppCopy.emptyHome)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }
}
