import SwiftUI

/// Satu teks di cover. Saat `isInteractive`, teks bisa dipilih (tap) & digeser (drag).
struct CoverTextLayerView: View {
    @Binding var layer: CoverTextLayer
    let side: CGFloat
    let isSelected: Bool
    let isInteractive: Bool
    let onSelect: () -> Void

    @State private var dragStart: CGSize?

    var body: some View {
        Text(layer.text)
            .font(.custom(CoverFont(rawValue: layer.fontIndex)?.fontName ?? "Didot-Bold",
                          size: layer.size * side))
            .foregroundStyle(CoverPalette.color(layer.colorIndex))
            .multilineTextAlignment(.center)
            .shadow(color: .black.opacity(0.25), radius: 2)
            .fixedSize()
            .padding(6)
            .overlay {
                if isInteractive && isSelected {
                    RoundedRectangle(cornerRadius: 6)
                        .strokeBorder(style: StrokeStyle(lineWidth: 1.5, dash: [5]))
                        .foregroundStyle(.white)
                }
            }
            .rotationEffect(.degrees(layer.rotation))
            .offset(x: layer.offsetX * side, y: layer.offsetY * side)
            .allowsHitTesting(isInteractive)
            .onTapGesture { onSelect() }
            .gesture(dragGesture)
    }

    /// Drag dihitung di ruang koordinat "cover" (satuan logis 360),
    /// bukan koordinat layar, jadi tetap akurat walau kanvas diperbesar/kecilkan.
    private var dragGesture: some Gesture {
        DragGesture(minimumDistance: 2, coordinateSpace: .named("cover"))
            .onChanged { value in
                onSelect()
                if dragStart == nil {
                    dragStart = CGSize(width: layer.offsetX, height: layer.offsetY)
                }
                guard let start = dragStart else { return }
                layer.offsetX = start.width + value.translation.width / side
                layer.offsetY = start.height + value.translation.height / side
            }
            .onEnded { _ in dragStart = nil }
    }
}
