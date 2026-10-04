import SwiftUI
import UIKit

/// Kolom teks dengan bold/italic, dibuat dari UITextView (UIKit).
/// Kenapa UIKit? Karena kita bisa mengontrol penuh pilihan teks & style-nya,
/// dan tingginya otomatis menyesuaikan isi (lihat `sizeThatFits`).
struct RichTextView: UIViewRepresentable {
    @Binding var runs: [StyledRun]
    let blockID: UUID
    let vm: NoteEditorViewModel
    var placeholder = "Tap here to continue"

    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.backgroundColor = .clear
        textView.isScrollEnabled = false                     // tinggi mengikuti isi
        textView.textContainerInset = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
        textView.textContainer.lineFragmentPadding = 0
        textView.font = RichTextCodec.baseFont
        textView.textColor = RichTextCodec.inkColor
        textView.typingAttributes = [.font: RichTextCodec.baseFont, .foregroundColor: RichTextCodec.inkColor]
        textView.attributedText = RichTextCodec.nsAttributed(from: runs)
        textView.delegate = context.coordinator
        textView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

        // Placeholder: label abu-abu di dalam text view, hilang saat ada teks.
        let label = UILabel()
        label.text = placeholder
        label.font = RichTextCodec.baseFont
        label.textColor = .placeholderText
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isUserInteractionEnabled = false
        label.isHidden = textView.attributedText.length > 0
        textView.addSubview(label)
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: textView.topAnchor, constant: 8),
            label.leadingAnchor.constraint(equalTo: textView.leadingAnchor)
        ])
        context.coordinator.placeholderLabel = label
        return textView
    }

    func updateUIView(_ textView: UITextView, context: Context) {
        context.coordinator.parent = self
        // Jangan menimpa isi saat user sedang mengetik; hanya sinkron kalau berubah dari luar.
        if !textView.isFirstResponder, RichTextCodec.runs(from: textView.attributedText) != runs {
            textView.attributedText = RichTextCodec.nsAttributed(from: runs)
        }
        context.coordinator.placeholderLabel?.isHidden = textView.attributedText.length > 0
    }

    /// Memberi tahu SwiftUI tinggi yang dibutuhkan teks pada lebar tertentu.
    func sizeThatFits(_ proposal: ProposedViewSize, uiView: UITextView, context: Context) -> CGSize? {
        let width = proposal.width ?? 320
        let fitted = uiView.sizeThatFits(CGSize(width: width, height: .greatestFiniteMagnitude))
        return CGSize(width: width, height: max(fitted.height, 44))
    }

    func makeCoordinator() -> Coordinator { Coordinator(self) }

    final class Coordinator: NSObject, UITextViewDelegate {
        var parent: RichTextView
        weak var placeholderLabel: UILabel?
        init(_ parent: RichTextView) { self.parent = parent }

        func textViewDidBeginEditing(_ textView: UITextView) {
            parent.vm.activeTextView = textView          // toolbar B / I bekerja pada text view ini
            parent.vm.focusedBlockID = parent.blockID
        }

        func textViewDidEndEditing(_ textView: UITextView) {
            if parent.vm.focusedBlockID == parent.blockID { parent.vm.focusedBlockID = nil }
        }

        func textViewDidChange(_ textView: UITextView) {
            parent.runs = RichTextCodec.runs(from: textView.attributedText)
            placeholderLabel?.isHidden = textView.attributedText.length > 0
            scrollCaretIntoView(textView)
        }

        /// Pastikan baris yang sedang diketik tidak tertutup keyboard.
        private func scrollCaretIntoView(_ textView: UITextView) {
            guard let end = textView.selectedTextRange?.end else { return }
            let caret = textView.caretRect(for: end)
            var view: UIView? = textView.superview
            while let current = view {
                if let scrollView = current as? UIScrollView {
                    let rect = textView.convert(caret, to: scrollView).insetBy(dx: 0, dy: -24)
                    scrollView.scrollRectToVisible(rect, animated: false)
                    return
                }
                view = current.superview
            }
        }
    }
}
