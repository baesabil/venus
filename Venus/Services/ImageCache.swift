import UIKit

/// Cache gambar di memori supaya swipe kartu & scroll grid tidak lag.
/// Gambar hanya di-decode SEKALI, lalu dipakai ulang.
final class ImageCache {
    static let shared = ImageCache()
    private let cache = NSCache<NSString, UIImage>()

    /// Cover untuk kartu/grid (kecil, 800px). Kunci cache memakai `updatedAt`,
    /// jadi kalau note diedit, cache otomatis dianggap baru.
    func coverImage(for note: Note) -> UIImage? {
        cover(for: note, maxPixel: 800, prefix: "cover")
    }

    /// Cover untuk halaman detail (lebih tajam, 1300px, karena tampil selebar layar).
    func detailCover(for note: Note) -> UIImage? {
        cover(for: note, maxPixel: 1300, prefix: "detail")
    }

    private func cover(for note: Note, maxPixel: CGFloat, prefix: String) -> UIImage? {
        let key = "\(prefix)-\(note.id.uuidString)-\(note.updatedAt.timeIntervalSince1970)" as NSString
        if let hit = cache.object(forKey: key) { return hit }
        guard let data = note.coverImageData,
              let image = ImageProcessor.downsample(data: data, maxPixel: maxPixel) else { return nil }
        cache.setObject(image, forKey: key)
        return image
    }

    /// Foto di dalam isi note.
    func blockImage(named file: String) -> UIImage? {
        let key = "block-\(file)" as NSString
        if let hit = cache.object(forKey: key) { return hit }
        guard let image = ImageStore.load(file) else { return nil }
        cache.setObject(image, forKey: key)
        return image
    }
}
