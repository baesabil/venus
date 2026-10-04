import UIKit

/// Semua getaran (haptic) dikumpulkan di sini.
/// Generator dibuat sekali & di-`prepare()` supaya respons instan (anti-lag).
final class HapticsManager {
    static let shared = HapticsManager()

    private let light = UIImpactFeedbackGenerator(style: .light)
    private let medium = UIImpactFeedbackGenerator(style: .medium)
    private let selection = UISelectionFeedbackGenerator()
    private let notification = UINotificationFeedbackGenerator()

    func prepare() {
        light.prepare(); medium.prepare(); selection.prepare()
    }

    /// Tap ringan (tombol).
    func tap() { light.impactOccurred(); light.prepare() }
    /// "Klik" kecil (melewati batas swipe, ganti pilihan).
    func tick() { selection.selectionChanged(); selection.prepare() }
    /// Swipe kartu berhasil.
    func swipe() { medium.impactOccurred(); medium.prepare() }
    func success() { notification.notificationOccurred(.success) }
}
