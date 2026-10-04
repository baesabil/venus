import SwiftUI
import PhotosUI

/// Toolbar melayang di bawah (gaya referensi): tombol + membuka pilihan blok.
/// Tombol B / I muncul hanya saat kamu sedang mengetik di blok teks.
/// Dipasang lewat safeAreaInset, jadi otomatis naik di atas keyboard.
struct BlockToolbar: View {
    @Bindable var vm: NoteEditorViewModel
    @State private var expanded = false
    @State private var pickedItem: PhotosPickerItem?

    var body: some View {
        HStack(spacing: 8) {
            Button {
                HapticsManager.shared.tap()
                withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) { expanded.toggle() }
            } label: {
                Image(systemName: "plus")
                    .font(.title3.bold())
                    .rotationEffect(.degrees(expanded ? 45 : 0))
                    .foregroundStyle(.white)
                    .frame(width: 52, height: 52)
                    .background(Theme.ink, in: Circle())
            }
            .buttonStyle(.plain)

            if expanded {
                PhotosPicker(selection: $pickedItem, matching: .images) { icon("photo") }
                    .transition(.scale.combined(with: .opacity))
                Button { vm.addList(kind: .checklist) } label: { icon("checklist") }
                    .buttonStyle(.plain)
                    .transition(.scale.combined(with: .opacity))
                Button { vm.addList(kind: .bullet) } label: { icon("list.bullet") }
                    .buttonStyle(.plain)
                    .transition(.scale.combined(with: .opacity))
            }

            if vm.focusedBlockID != nil {
                Button { vm.formatCommand = FormatCommand(kind: .bold) } label: { icon("bold") }
                    .buttonStyle(.plain)
                Button { vm.formatCommand = FormatCommand(kind: .italic) } label: { icon("italic") }
                    .buttonStyle(.plain)
            }
        }
        .padding(6)
        .background(Theme.paperSurface.opacity(0.85), in: Capsule())
        .animation(.spring(response: 0.35, dampingFraction: 0.75), value: vm.focusedBlockID)
        .onChange(of: pickedItem) { _, item in
            guard let item else { return }
            Task {
                if let data = try? await item.loadTransferable(type: Data.self) {
                    vm.addPhoto(data: data)
                }
                pickedItem = nil
            }
        }
    }

    private func icon(_ name: String) -> some View {
        Image(systemName: name)
            .font(.title3)
            .foregroundStyle(Theme.ink)
            .frame(width: 52, height: 52)
            .background(Theme.paperSurface, in: Circle())
    }
}
