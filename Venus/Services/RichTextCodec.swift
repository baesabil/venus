import SwiftUI

/// Penerjemah antara 2 bentuk teks:
/// - `AttributedString` : yang dipakai TextEditor (iOS 26) untuk bold/italic
/// - `[StyledRun]`      : bentuk sederhana yang aman disimpan ke database
enum RichTextCodec {
    static func attributed(from runs: [StyledRun]) -> AttributedString {
        var result = AttributedString()
        for run in runs {
            var piece = AttributedString(run.text)
            var font = Font.body
            if run.bold { font = font.bold() }
            if run.italic { font = font.italic() }
            piece.font = font
            result.append(piece)
        }
        return result
    }

    static func runs(from text: AttributedString, context: Font.Context) -> [StyledRun] {
        text.runs.map { run in
            let resolved = (run.font ?? .body).resolve(in: context)
            return StyledRun(
                text: String(text[run.range].characters),
                bold: resolved.isBold,
                italic: resolved.isItalic
            )
        }
    }
}
