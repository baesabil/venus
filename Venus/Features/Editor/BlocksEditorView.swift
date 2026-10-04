import SwiftUI

/// Isi note = daftar blok. Tiap jenis blok punya view sendiri (folder Blocks/),
/// jadi file ini tetap pendek: hanya memilih view mana untuk blok mana.
struct BlocksEditorView: View {
    @Bindable var vm: NoteEditorViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            ForEach($vm.blocks) { $block in
                switch block.kind {
                case .text:
                    TextBlockView(block: $block, vm: vm)
                case .checklist, .bullet:
                    ListItemBlockView(block: $block, vm: vm)
                case .photo:
                    PhotoBlockView(block: block) { vm.removeBlock(block.id) }
                }
            }
        }
    }
}
