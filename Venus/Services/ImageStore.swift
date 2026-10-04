import UIKit

/// Menyimpan foto di dalam note sebagai FILE di folder Documents.
/// Di database cukup disimpan nama filenya (lihat NoteBlock.imageFile).
enum ImageStore {
    private static var directory: URL {
        let url = URL.documentsDirectory.appending(path: "BlockImages", directoryHint: .isDirectory)
        try? FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
        return url
    }

    /// Kecilkan (maks 1600px), simpan sebagai JPEG, kembalikan nama file.
    static func save(data: Data) -> String? {
        guard let image = ImageProcessor.downsample(data: data, maxPixel: 1600),
              let jpeg = image.jpegData(compressionQuality: 0.8) else { return nil }
        let name = UUID().uuidString + ".jpg"
        do {
            try jpeg.write(to: directory.appending(path: name))
            return name
        } catch {
            return nil
        }
    }

    static func load(_ name: String) -> UIImage? {
        UIImage(contentsOfFile: directory.appending(path: name).path)
    }

    static func delete(_ name: String) {
        try? FileManager.default.removeItem(at: directory.appending(path: name))
    }
}
