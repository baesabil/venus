import SwiftUI

/// Tombol + hitam di tengah bawah Home.
struct AddNoteButton: View {
    let action: () -> Void

    var body: some View {
        Button {
            HapticsManager.shared.tap()
            action()
        } label: {
            Image(systemName: "plus")
                .font(.system(size: 28, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 72, height: 72)
                .background(Theme.ink, in: Circle())
                .shadow(color: .black.opacity(0.2), radius: 10, y: 5)
        }
        .buttonStyle(.plain)
    }
}
