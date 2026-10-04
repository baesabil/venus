import SwiftUI

/// Tumpukan kartu yang bisa di-swipe (Tinder-style).
///
/// Kunci anti-lag:
/// 1. Hanya 3 kartu teratas yang digambar, berapa pun jumlah note.
/// 2. Gambar kecil & di-cache (lihat ImageCache).
/// 3. Haptic generator sudah di-prepare, suara sudah di-preload.
struct CardStackView: View {
    let notes: [Note]
    var onOpen: (Note) -> Void
    var onDelete: (Note) -> Void

    /// Index kartu paling atas (dihitung modulo jumlah note, jadi bisa berputar).
    @State private var topIndex = 0
    /// Seberapa jauh kartu atas sedang digeser jari.
    @State private var drag: CGSize = .zero
    /// Kartu yang baru terbang keluar disembunyikan sebentar saat pindah ke belakang tumpukan.
    @State private var hiddenID: UUID?
    @State private var crossedThreshold = false

    private let swipeThreshold: CGFloat = 110

    private struct StackItem: Identifiable {
        let depth: Int      // 0 = paling atas
        let note: Note
        var id: UUID { note.id }
    }

    private var visibleItems: [StackItem] {
        let count = notes.count
        guard count > 0 else { return [] }
        let start = topIndex % count
        // Digambar dari belakang ke depan.
        return (0..<min(3, count)).reversed().map { depth in
            StackItem(depth: depth, note: notes[(start + depth) % count])
        }
    }

    var body: some View {
        GeometryReader { geo in
            let side = min(geo.size.width - 72, 340)
            VStack(spacing: 24) {
                Spacer(minLength: 0)
                ZStack {
                    ForEach(visibleItems) { item in
                        card(item, side: side)
                    }
                }
                .frame(width: side, height: side + 32)
                caption
                Spacer(minLength: 0)
            }
            .frame(maxWidth: .infinity)
        }
    }

    // MARK: - Kartu

    private func card(_ item: StackItem, side: CGFloat) -> some View {
        let isTop = item.depth == 0
        return CoverCardView(note: item.note)
            .frame(width: side, height: side)
            .scaleEffect(1 - CGFloat(item.depth) * 0.06)
            .rotationEffect(.degrees(isTop ? Double(drag.width) / 16 : (item.depth == 1 ? -4 : 5)))
            .offset(x: isTop ? drag.width : 0,
                    y: isTop ? drag.height * 0.4 : CGFloat(item.depth) * 16)
            .opacity(item.note.id == hiddenID ? 0 : 1)
            .zIndex(Double(3 - item.depth))
            .allowsHitTesting(isTop)
            .onTapGesture { if isTop { onOpen(item.note) } }
            .gesture(dragGesture, including: isTop ? .all : .none)
            .contextMenu {
                if isTop {
                    Button(role: .destructive) { onDelete(item.note) } label: {
                        Label("Delete", systemImage: "trash")
                    }
                }
            }
    }

    private var caption: some View {
        let count = notes.count
        let note = notes[topIndex % count]
        return VStack(spacing: 4) {
            Text(note.title.isEmpty ? "Untitled" : note.title)
                .font(.title3.weight(.bold))
                .foregroundStyle(Theme.ink)
                .lineLimit(1)
            Text("\(note.createdAt.formatted(date: .abbreviated, time: .omitted))  ·  \(topIndex % count + 1)/\(count)")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 32)
    }

    // MARK: - Gesture swipe

    private var dragGesture: some Gesture {
        DragGesture(minimumDistance: 8)
            .onChanged { value in
                // Kalau cuma 1 note, kartu hanya "bergetar" sedikit (tidak bisa dibuang).
                guard notes.count > 1 else {
                    drag = CGSize(width: value.translation.width / 4, height: value.translation.height / 4)
                    return
                }
                drag = value.translation
                let crossed = abs(value.translation.width) > swipeThreshold
                if crossed != crossedThreshold {
                    crossedThreshold = crossed
                    if crossed { HapticsManager.shared.tick() }
                }
            }
            .onEnded { value in
                let shouldSwipe = notes.count > 1 &&
                    (abs(value.translation.width) > swipeThreshold || abs(value.predictedEndTranslation.width) > 260)
                if shouldSwipe {
                    commitSwipe(direction: value.translation.width >= 0 ? 1 : -1, y: value.translation.height)
                } else {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) { drag = .zero }
                    crossedThreshold = false
                }
            }
    }

    private func commitSwipe(direction: CGFloat, y: CGFloat) {
        let count = notes.count
        let flownID = notes[topIndex % count].id

        HapticsManager.shared.swipe()
        SoundManager.shared.playSwipe()

        // 1) Kartu terbang keluar layar.
        withAnimation(.easeIn(duration: 0.22)) {
            drag = CGSize(width: direction * 520, height: y)
        }

        Task {
            try? await Task.sleep(for: .milliseconds(220))
            // 2) Kartu berikutnya naik; kartu yang terbang pindah ke belakang (tersembunyi dulu).
            withAnimation(.spring(response: 0.4, dampingFraction: 0.78)) {
                hiddenID = flownID
                topIndex = (topIndex + 1) % count
                drag = .zero
            }
            crossedThreshold = false
            try? await Task.sleep(for: .milliseconds(300))
            // 3) Munculkan lagi di belakang tumpukan.
            withAnimation(.easeOut(duration: 0.25)) { hiddenID = nil }
        }
    }
}
