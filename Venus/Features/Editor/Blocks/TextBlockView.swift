import SwiftUI

/// Blok teks dengan bold/italic. Memakai TextEditor versi iOS 26 yang menerima
/// `AttributedString` + `selection` (jadi kita tahu teks mana yang di-blok).
struct TextBlockView: View {
    @Binding var block: NoteBlock
    @Bindable var vm: NoteEditorViewModel

    @State private var text = AttributedString()
    @State private var selection = AttributedTextSelection()
    @FocusState private var isFocused: Bool
    @Environment(\.fontResolutionContext) private var fontContext

    var body: some View {
        TextEditor(text: $text, selection: $selection)
            .font(.body)
            .focused($isFocused)
            .scrollDisabled(true)
            .scrollContentBackground(.hidden)
            .frame(height: estimatedHeight)
            .overlay(alignment: .topLeading) {
                if text.characters.isEmpty {
                    Text("Tap here to continue")
                        .foregroundStyle(.secondary)
                        .padding(.top, 8).padding(.leading, 5)
                        .allowsHitTesting(false)
                }
            }
            .onAppear { text = RichTextCodec.attributed(from: block.runs) }
            // Setiap teks berubah -> simpan ke blok (dalam bentuk StyledRun).
            .onChange(of: text) { _, newValue in
                block.runs = RichTextCodec.runs(from: newValue, context: fontContext)
            }
            // Beritahu view model blok mana yang sedang fokus (untuk tombol B / I).
            .onChange(of: isFocused) { _, focused in
                if focused { vm.focusedBlockID = block.id }
                else if vm.focusedBlockID == block.id { vm.focusedBlockID = nil }
            }
            // Perintah bold/italic dari toolbar, hanya dijalankan oleh blok yang fokus.
            .onChange(of: vm.formatCommand) { _, command in
                guard let command, vm.focusedBlockID == block.id else { return }
                apply(command.kind)
                vm.formatCommand = nil
            }
    }

    private func apply(_ kind: FormatCommand.Kind) {
        text.transformAttributes(in: &selection) { attributes in
            let font = attributes.font ?? .body
            let resolved = font.resolve(in: fontContext)
            switch kind {
            case .bold:   attributes.font = font.bold(!resolved.isBold)
            case .italic: attributes.font = font.italic(!resolved.isItalic)
            }
        }
    }

    /// TextEditor tidak otomatis membesar, jadi tingginya diperkirakan dari jumlah baris.
    private var estimatedHeight: CGFloat {
        let string = String(text.characters)
        let lines = string.split(separator: "\n", omittingEmptySubsequences: false)
            .reduce(0) { $0 + max(1, Int(ceil(Double($1.count) / 34.0))) }
        return max(60, CGFloat(lines) * 24 + 28)
    }
}
