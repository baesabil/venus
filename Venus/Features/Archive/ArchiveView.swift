import SwiftUI
import SwiftData

/// Grid cover per bulan/tahun + pencarian berdasarkan judul.
/// Tombol back & swipe-back disediakan NavigationStack.
struct ArchiveView: View {
    @Query(sort: \Note.createdAt, order: .reverse) private var notes: [Note]

    @State private var selectedYear = Calendar.current.component(.year, from: .now)
    @State private var selectedMonth = Calendar.current.component(.month, from: .now)
    @State private var searchText = ""
    @State private var viewingNote: Note?
    @State private var noteToDelete: Note?

    private let calendar = Calendar.current
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 12), count: 3)

    // MARK: - Data

    private var query: String { searchText.trimmingCharacters(in: .whitespacesAndNewlines) }
    private var isSearching: Bool { !query.isEmpty }

    private var years: [Int] {
        let fromNotes = Set(notes.map { calendar.component(.year, from: $0.createdAt) })
        return fromNotes.union([calendar.component(.year, from: .now)]).sorted(by: >)
    }

    private var notesInSelection: [Note] {
        notes.filter {
            calendar.component(.year, from: $0.createdAt) == selectedYear &&
            calendar.component(.month, from: $0.createdAt) == selectedMonth
        }
    }

    /// Saat mencari: cari di SEMUA bulan & tahun (tidak peduli huruf besar/kecil).
    private var searchResults: [Note] {
        notes.filter { $0.title.localizedCaseInsensitiveContains(query) }
    }

    private var displayedNotes: [Note] { isSearching ? searchResults : notesInSelection }

    private func count(inMonth month: Int) -> Int {
        notes.filter {
            calendar.component(.year, from: $0.createdAt) == selectedYear &&
            calendar.component(.month, from: $0.createdAt) == month
        }.count
    }

    // MARK: - View

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Pilihan bulan/tahun disembunyikan saat mencari.
                if !isSearching {
                    MonthYearPicker(
                        years: years,
                        selectedYear: $selectedYear,
                        selectedMonth: $selectedMonth,
                        countForMonth: { count(inMonth: $0) }
                    )
                }

                if displayedNotes.isEmpty {
                    Text(emptyMessage)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity)
                        .padding(.top, 60)
                } else {
                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(displayedNotes) { note in
                            gridItem(note)
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 40)
        }
        .background(Theme.background.ignoresSafeArea())
        .navigationTitle("Archive")
        .navigationBarTitleDisplayMode(.large)
        .searchable(text: $searchText, prompt: AppCopy.searchPrompt)
        .onAppear(perform: jumpToLatestIfEmpty)
        .navigationDestination(item: $viewingNote) { NoteDetailView(note: $0) }
        .deleteConfirmation(note: $noteToDelete)
    }

    private var emptyMessage: String {
        isSearching
            ? "No notes titled \"\(query)\""
            : "No notes in \(calendar.monthSymbols[selectedMonth - 1]) \(String(selectedYear))"
    }

    /// Satu sel grid: cover + judul kecil di bawahnya.
    private func gridItem(_ note: Note) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            CoverCardView(note: note, cornerRadius: 16)
            Text(note.title.isEmpty ? "Untitled" : note.title)
                .font(.caption.weight(.semibold))
                .foregroundStyle(Theme.ink)
                .lineLimit(1)
        }
        .onTapGesture { viewingNote = note }
        .contextMenu {
            Button(role: .destructive) { noteToDelete = note } label: {
                Label("Delete", systemImage: "trash")
            }
        }
    }

    /// Kalau bulan ini kosong, langsung lompat ke bulan note terbaru.
    private func jumpToLatestIfEmpty() {
        guard notesInSelection.isEmpty, let latest = notes.first else { return }
        selectedYear = calendar.component(.year, from: latest.createdAt)
        selectedMonth = calendar.component(.month, from: latest.createdAt)
    }
}
