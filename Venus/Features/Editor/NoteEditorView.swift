import SwiftUI

/// Halaman note (dipakai untuk note BARU dan untuk mengedit note lama).
/// Tombol back otomatis menyimpan, seperti app Notes.
struct NoteEditorView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    private let existing: Note?
    @State private var vm: NoteEditorViewModel
    @State private var showCoverEditor = false

    init(note: Note?) {
        existing = note
        _vm = State(initialValue: NoteEditorViewModel(note: note))
    }

    var body: some View {
        @Bindable var vm = vm   // supaya bisa pakai $vm.title

        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                CoverHeaderView(vm: vm) { showCoverEditor = true }

                TextField("Title", text: $vm.title, axis: .vertical)
                    .font(.system(size: 34, weight: .bold))
                    .foregroundStyle(Theme.ink)

                SongLinkField(vm: vm)

                BlocksEditorView(vm: vm)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 120)
        }
        .scrollDismissesKeyboard(.interactively)
        .background(Theme.paper.ignoresSafeArea())
        .safeAreaInset(edge: .top) {
            HStack {
                CircleIconButton(systemName: "chevron.left") { closeAndSave() }
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 6)
        }
        .safeAreaInset(edge: .bottom) {
            BlockToolbar(vm: vm).padding(.bottom, 8)
        }
        .fullScreenCover(isPresented: $showCoverEditor) { CoverEditorView(vm: vm) }
    }

    private func closeAndSave() {
        if !vm.isBlank {
            vm.save(existing: existing, context: context)
            HapticsManager.shared.success()
        }
        dismiss()
    }
}
