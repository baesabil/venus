import SwiftUI

/// Preview cover di atas halaman note. Ditekan -> buka editor cover.
struct CoverHeaderView: View {
    var vm: NoteEditorViewModel
    var onEdit: () -> Void

    var body: some View {
        Button(action: onEdit) {
            ZStack {
                if vm.hasCover {
                    ScaledCoverContainer {
                        CoverCanvasView(
                            baseImage: vm.baseImage,
                            photoScale: vm.photoScale,
                            photoOffset: vm.photoOffset,
                            layers: .constant(vm.layers),
                            selectedID: .constant(nil),
                            drawing: vm.drawing
                        )
                    }
                } else {
                    placeholder
                }
            }
            .aspectRatio(1, contentMode: .fit)
            .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.card, style: .continuous))
            .overlay(alignment: .bottomTrailing) {
                if vm.hasCover {
                    Label("Edit cover", systemImage: "pencil")
                        .font(.footnote.weight(.semibold))
                        .padding(.horizontal, 12).padding(.vertical, 8)
                        .background(.ultraThinMaterial, in: Capsule())
                        .padding(12)
                }
            }
        }
        .buttonStyle(.plain)
    }

    private var placeholder: some View {
        RoundedRectangle(cornerRadius: Theme.Radius.card, style: .continuous)
            .fill(Theme.paperSurface.opacity(0.5))
            .overlay {
                VStack(spacing: 10) {
                    Image(systemName: "photo.badge.plus").font(.system(size: 36))
                    Text("Add cover").font(.subheadline.weight(.semibold))
                }
                .foregroundStyle(Theme.ink.opacity(0.7))
            }
    }
}
