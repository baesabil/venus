import SwiftUI
import PencilKit

/// Jembatan ke PencilKit (UIKit) supaya bisa mencoret cover pakai jari.
/// UIViewRepresentable = cara memakai view UIKit di dalam SwiftUI.
struct DrawingCanvas: UIViewRepresentable {
    @Binding var drawing: PKDrawing
    var tool: PKTool

    func makeUIView(context: Context) -> PKCanvasView {
        let canvas = PKCanvasView()
        canvas.drawingPolicy = .anyInput          // jari ATAU Apple Pencil
        canvas.backgroundColor = .clear
        canvas.isOpaque = false
        canvas.isScrollEnabled = false
        canvas.overrideUserInterfaceStyle = .light // warna tinta tidak ikut dark mode
        canvas.drawing = drawing
        canvas.tool = tool
        canvas.delegate = context.coordinator
        return canvas
    }

    func updateUIView(_ canvas: PKCanvasView, context: Context) {
        canvas.tool = tool
        // Hanya ganti isi kanvas kalau berubah dari luar (undo / clear).
        if canvas.drawing.strokes.count != drawing.strokes.count {
            canvas.drawing = drawing
        }
    }

    func makeCoordinator() -> Coordinator { Coordinator(self) }

    /// Mendengar perubahan coretan dan menuliskannya kembali ke `drawing`.
    final class Coordinator: NSObject, PKCanvasViewDelegate {
        var parent: DrawingCanvas
        init(_ parent: DrawingCanvas) { self.parent = parent }

        func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
            parent.drawing = canvasView.drawing
        }
    }
}
