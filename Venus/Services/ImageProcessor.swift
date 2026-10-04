import UIKit
import ImageIO

/// Memperkecil gambar dengan cara hemat memori.
/// ImageIO membuat thumbnail langsung dari data, tanpa membuka foto penuh
/// (foto kamera 12MP+ bisa makan puluhan MB kalau dibuka utuh).
enum ImageProcessor {
    static func downsample(data: Data, maxPixel: CGFloat) -> UIImage? {
        let sourceOptions: [CFString: Any] = [kCGImageSourceShouldCache: false]
        guard let source = CGImageSourceCreateWithData(data as CFData, sourceOptions as CFDictionary) else {
            return nil
        }
        let options: [CFString: Any] = [
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceShouldCacheImmediately: true,
            kCGImageSourceCreateThumbnailWithTransform: true,   // hormati orientasi foto
            kCGImageSourceThumbnailMaxPixelSize: maxPixel
        ]
        guard let cgImage = CGImageSourceCreateThumbnailAtIndex(source, 0, options as CFDictionary) else {
            return nil
        }
        return UIImage(cgImage: cgImage)
    }
}
