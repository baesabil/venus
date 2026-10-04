import SwiftUI
import UIKit

/// Penerjemah bentuk teks:
/// - `[StyledRun]`        : bentuk sederhana yang disimpan di database
/// - `NSAttributedString` : dipakai UITextView saat mengedit
/// - `AttributedString`   : dipakai SwiftUI `Text` saat membaca (halaman detail)
enum RichTextCodec {
    static let baseFont = UIFont.preferredFont(forTextStyle: .body)
    static let inkColor = UIColor(Theme.ink)

    // MARK: Database <-> UITextView

    static func nsAttributed(from runs: [StyledRun]) -> NSAttributedString {
        let result = NSMutableAttributedString()
        for run in runs {
            var font = baseFont
            if run.bold { font = font.with(trait: .traitBold, on: true) }
            if run.italic { font = font.with(trait: .traitItalic, on: true) }
            result.append(NSAttributedString(string: run.text,
                                             attributes: [.font: font, .foregroundColor: inkColor]))
        }
        return result
    }

    static func runs(from text: NSAttributedString) -> [StyledRun] {
        var runs: [StyledRun] = []
        text.enumerateAttribute(.font, in: NSRange(location: 0, length: text.length)) { value, range, _ in
            let traits = ((value as? UIFont) ?? baseFont).fontDescriptor.symbolicTraits
            runs.append(StyledRun(text: text.attributedSubstring(from: range).string,
                                  bold: traits.contains(.traitBold),
                                  italic: traits.contains(.traitItalic)))
        }
        return runs
    }

    // MARK: Database -> SwiftUI Text (halaman detail)

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

    // MARK: Bold / italic

    /// Nyalakan/matikan bold atau italic pada teks yang di-blok.
    /// Kalau tidak ada yang di-blok (hanya kursor), berlaku untuk teks yang akan diketik berikutnya.
    static func toggle(_ trait: UIFontDescriptor.SymbolicTraits, in textView: UITextView) {
        let range = textView.selectedRange
        if range.length == 0 {
            var attributes = textView.typingAttributes
            let font = (attributes[.font] as? UIFont) ?? baseFont
            let isOn = font.fontDescriptor.symbolicTraits.contains(trait)
            attributes[.font] = font.with(trait: trait, on: !isOn)
            textView.typingAttributes = attributes
            return
        }
        let storage = textView.textStorage
        // Kalau SEMUA teks terpilih sudah punya style ini -> matikan; selain itu -> nyalakan.
        var allHaveTrait = true
        storage.enumerateAttribute(.font, in: range) { value, _, _ in
            let font = (value as? UIFont) ?? baseFont
            if !font.fontDescriptor.symbolicTraits.contains(trait) { allHaveTrait = false }
        }
        storage.beginEditing()
        storage.enumerateAttribute(.font, in: range) { value, subrange, _ in
            let font = (value as? UIFont) ?? baseFont
            storage.addAttribute(.font, value: font.with(trait: trait, on: !allHaveTrait), range: subrange)
        }
        storage.endEditing()
        textView.delegate?.textViewDidChange?(textView)   // beritahu SwiftUI supaya tersimpan
    }
}

extension UIFont {
    /// Salinan font ini dengan trait (bold/italic) dinyalakan atau dimatikan.
    func with(trait: UIFontDescriptor.SymbolicTraits, on: Bool) -> UIFont {
        var traits = fontDescriptor.symbolicTraits
        if on { traits.insert(trait) } else { traits.remove(trait) }
        guard let descriptor = fontDescriptor.withSymbolicTraits(traits) else { return self }
        return UIFont(descriptor: descriptor, size: pointSize)
    }
}
