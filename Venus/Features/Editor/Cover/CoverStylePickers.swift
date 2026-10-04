import SwiftUI

/// Baris pilihan font (tiap chip menampilkan "Aa" dengan font-nya sendiri).
struct FontPickerRow: View {
    @Binding var selection: Int

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(CoverFont.allCases) { font in
                    let selected = font.rawValue == selection
                    Button {
                        HapticsManager.shared.tick()
                        selection = font.rawValue
                    } label: {
                        Text("Aa")
                            .font(.custom(font.fontName, size: 24))
                            .frame(width: 56, height: 56)
                            .background(selected ? Theme.ink : Theme.surface,
                                        in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                            .foregroundStyle(selected ? Color.white : Theme.ink)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}

/// Baris pilihan warna dasar.
struct ColorPickerRow: View {
    @Binding var selection: Int

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(CoverPalette.colors.indices, id: \.self) { index in
                    Button {
                        HapticsManager.shared.tick()
                        selection = index
                    } label: {
                        Circle()
                            .fill(CoverPalette.color(index))
                            .frame(width: 34, height: 34)
                            .overlay(Circle().strokeBorder(Color.black.opacity(0.15), lineWidth: 1))
                            .overlay {
                                if selection == index {
                                    Circle().strokeBorder(Theme.ink, lineWidth: 3).padding(-5)
                                }
                            }
                    }
                    .buttonStyle(.plain)
                    .padding(.vertical, 6)
                }
            }
            .padding(.horizontal, 6)
        }
    }
}
