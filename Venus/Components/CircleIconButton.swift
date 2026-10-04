import SwiftUI

/// Tombol bulat dengan ikon (gaya referensi UI-mu). Bisa dipakai di mana saja.
struct CircleIconButton: View {
    let systemName: String
    var isDark = false
    var size: CGFloat = 46
    let action: () -> Void

    var body: some View {
        Button {
            HapticsManager.shared.tap()
            action()
        } label: {
            Image(systemName: systemName)
                .font(.system(size: size * 0.38, weight: .semibold))
                .foregroundStyle(isDark ? Color.white : Theme.ink)
                .frame(width: size, height: size)
                .background(isDark ? Theme.ink : Theme.paperSurface, in: Circle())
        }
        .buttonStyle(.plain)
    }
}
