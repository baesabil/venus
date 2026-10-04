import SwiftUI

/// Satu baris checklist atau bullet.
/// - Return di baris berisi -> baris baru; return di baris kosong -> keluar dari list.
/// - Tombol x di kanan menghapus baris ini.
struct ListItemBlockView: View {
    @Binding var block: NoteBlock
    @Bindable var vm: NoteEditorViewModel
    var onDelete: () -> Void
    @FocusState private var isFocused: Bool

    var body: some View {
        HStack(alignment: .center, spacing: 10) {
            if block.kind == .checklist {
                Button {
                    HapticsManager.shared.tap()
                    block.isChecked.toggle()
                } label: {
                    Image(systemName: block.isChecked ? "checkmark.circle.fill" : "circle")
                        .font(.title3)
                        .foregroundStyle(Theme.ink)
                }
                .buttonStyle(.plain)
            } else {
                Text("•").font(.title3.bold()).frame(width: 22)
            }

            TextField("List item", text: $block.plain)
                .focused($isFocused)
                .submitLabel(.next)
                .onSubmit { vm.submitListItem(block.id) }
                .strikethrough(block.kind == .checklist && block.isChecked)
                .foregroundStyle(block.isChecked ? Color.secondary : Theme.ink)

            Button {
                HapticsManager.shared.tap()
                withAnimation(.snappy) { onDelete() }
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.title3)
                    .foregroundStyle(Color.secondary.opacity(0.55))
            }
            .buttonStyle(.plain)
        }
        .onAppear { if vm.focusRequestID == block.id { isFocused = true } }
        .onChange(of: vm.focusRequestID) { _, id in
            if id == block.id { isFocused = true }
        }
    }
}
