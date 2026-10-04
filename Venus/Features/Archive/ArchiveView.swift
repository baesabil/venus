import SwiftUI
import SwiftData

/// Grid cover per bulan/tahun. Tombol back & swipe-back disediakan NavigationStack.
struct ArchiveView: View {
    @Query(sort: \Note.createdAt, order: .reverse) private var notes: [Note]

    @State private var selectedYear = Calendar.current.component(.year, from: .now)
    @State private var selectedMonth = Calendar.current.component(.month, from: .now)
    @State private var editingNote: Note?
    @State private var noteToDelete: Note?

    private let calendar = Calendar.current
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 12), count: 3)

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

    private func count(inMonth month: Int) -> Int {
        notes.filter {
            calendar.component(.year, from: $0.createdAt) == selectedYear &&
            calendar.component(.month, from: $0.createdAt) == month
        }.count
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                MonthYearPicker(
                    years: years,
                    selectedYear: $selectedYear,
                    selectedMonth: $selectedMonth,
                    countForMonth: { count(inMonth: $0) }
                )

                if notesInSelection.isEmpty {
                    Text("No notes in \(calendar.monthSymbols[selectedMonth - 1]) \(String(selectedYear))")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity)
                        .padding(.top, 60)
                } else {
                    LazyVGrid(columns: columns, spacing: 12) {
                        ForEach(notesInSelection) { note in
                            CoverCardView(note: note, cornerRadius: 16)
                                .onTapGesture { editingNote = note }
                                .contextMenu {
                                    Button(role: .destructive) { noteToDelete = note } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
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
        .onAppear(perform: jumpToLatestIfEmpty)
        .fullScreenCover(item: $editingNote) { NoteEditorView(note: $0) }
        .deleteConfirmation(note: $noteToDelete)
    }

    /// Kalau bulan ini kosong, langsung lompat ke bulan note terbaru.
    private func jumpToLatestIfEmpty() {
        guard notesInSelection.isEmpty, let latest = notes.first else { return }
        selectedYear = calendar.component(.year, from: latest.createdAt)
        selectedMonth = calendar.component(.month, from: latest.createdAt)
    }
}
