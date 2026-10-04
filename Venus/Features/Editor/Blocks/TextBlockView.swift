import SwiftUI

/// Blok teks dengan bold/italic. Semua kerja beratnya ada di RichTextView.
struct TextBlockView: View {
    @Binding var block: NoteBlock
    let vm: NoteEditorViewModel

    var body: some View {
        RichTextView(runs: $block.runs, blockID: block.id, vm: vm)
    }
}
