import SwiftUI
import SwiftData
import PencilKit

/// Perintah format dari toolbar ke blok teks yang sedang fokus.
struct FormatCommand: Equatable {
    enum Kind { case bold, italic }
    let id = UUID()
    let kind: Kind
}

/// "Otak" halaman editor. Menyimpan draft sementara selama kamu mengedit,
/// lalu menulisnya ke `Note` (SwiftData) saat kamu menekan back.
@MainActor
@Observable
final class NoteEditorViewModel {
    // Isi
    var title = ""
    var blocks: [NoteBlock] = [.emptyText()]

    // Cover
    var baseImage: UIImage?
    var photoScale: CGFloat = 1
    var photoOffset: CGSize = .zero
    var layers: [CoverTextLayer] = []
    var drawing = PKDrawing()

    // Lagu
    var songURL = ""
    var songTitle = ""
    var songThumbnailURL = ""
    var songTitleFailed = false
    var songError: String?
    var isFetchingSong = false

    // Koordinasi toolbar <-> blok
    var focusedBlockID: UUID?
    var formatCommand: FormatCommand?
    var focusRequestID: UUID?

    var hasCover: Bool { baseImage != nil || !layers.isEmpty || !drawing.strokes.isEmpty }

    var isBlank: Bool {
        title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        && !hasCover && songURL.isEmpty && blocks.allSatisfy(\.isEmpty)
    }

    // MARK: - Load

    init(note: Note?) {
        guard let note else { return }
        title = note.title
        if let data = note.coverBaseData { baseImage = ImageProcessor.downsample(data: data, maxPixel: 1600) }
        photoScale = CGFloat(note.coverPhotoScale)
        photoOffset = CGSize(width: note.coverPhotoOffsetX, height: note.coverPhotoOffsetY)
        layers = note.coverTextLayers
        if let data = note.coverDrawingData, let saved = try? PKDrawing(data: data) { drawing = saved }
        let saved = note.blocks
        blocks = saved.isEmpty ? [.emptyText()] : saved
        if blocks.last?.kind != .text { blocks.append(.emptyText()) }   // selalu ada tempat mengetik di bawah
        songURL = note.songURL ?? ""
        songTitle = note.songTitle ?? ""
        songThumbnailURL = note.songThumbnailURL ?? ""
    }

    // MARK: - Cover

    func setCoverPhoto(data: Data) {
        guard let image = ImageProcessor.downsample(data: data, maxPixel: 1600) else { return }
        baseImage = image
        photoScale = 1
        photoOffset = .zero
    }

    func addTextLayer() -> UUID {
        let layer = CoverTextLayer()
        layers.append(layer)
        return layer.id
    }

    func deleteLayer(_ id: UUID) {
        layers.removeAll { $0.id == id }
    }

    // MARK: - Blocks

    /// Menyisipkan blok baru tepat sebelum kolom teks kosong di paling bawah.
    private func insertBeforeTrailingText(_ block: NoteBlock) {
        if let last = blocks.last, last.kind == .text, last.isEmpty {
            blocks.insert(block, at: blocks.count - 1)
        } else {
            blocks.append(block)
            blocks.append(.emptyText())
        }
    }

    func addPhoto(data: Data) {
        guard let file = ImageStore.save(data: data) else { return }
        insertBeforeTrailingText(NoteBlock(kind: .photo, imageFile: file))
    }

    func addList(kind: NoteBlock.Kind) {
        let item = NoteBlock(kind: kind)
        insertBeforeTrailingText(item)
        focusRequestID = item.id
    }

    /// Tombol return di item list: buat item baru, atau keluar dari list kalau item kosong.
    func submitListItem(_ id: UUID) {
        guard let index = blocks.firstIndex(where: { $0.id == id }) else { return }
        let current = blocks[index]
        if current.plain.isEmpty {
            blocks[index] = .emptyText()
        } else {
            let next = NoteBlock(kind: current.kind)
            blocks.insert(next, at: index + 1)
            focusRequestID = next.id
        }
    }

    func removeBlock(_ id: UUID) {
        guard let index = blocks.firstIndex(where: { $0.id == id }) else { return }
        if let file = blocks[index].imageFile { ImageStore.delete(file) }
        blocks.remove(at: index)
        if blocks.isEmpty || blocks.last?.kind != .text { blocks.append(.emptyText()) }
    }

    // MARK: - Lagu

    func attachSong(link: String) async {
        let trimmed = link.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        songError = nil
        isFetchingSong = true
        defer { isFetchingSong = false }
        do {
            let info = try await SongMetadataService.fetch(link: trimmed)
            songURL = trimmed
            songTitle = info.title
            songThumbnailURL = info.thumbnailURL ?? ""
            songTitleFailed = false
        } catch SongMetadataError.notSpotifyLink {
            songError = "That doesn't look like a Spotify link."
        } catch {
            // Link valid tapi gagal ambil judul (offline, dll) -> user ketik judul sendiri.
            songURL = trimmed
            songTitle = ""
            songThumbnailURL = ""
            songTitleFailed = true
        }
    }

    func clearSong() {
        songURL = ""; songTitle = ""; songThumbnailURL = ""
        songTitleFailed = false; songError = nil
    }

    // MARK: - Save

    func save(existing: Note?, context: ModelContext) {
        let note = existing ?? Note()
        note.title = title.trimmingCharacters(in: .whitespacesAndNewlines)

        note.coverBaseData = baseImage?.jpegData(compressionQuality: 0.85)
        note.coverPhotoScale = Double(photoScale)
        note.coverPhotoOffsetX = Double(photoOffset.width)
        note.coverPhotoOffsetY = Double(photoOffset.height)
        note.coverTextLayers = layers
        note.coverDrawingData = drawing.strokes.isEmpty ? nil : drawing.dataRepresentation()
        note.coverImageData = hasCover
            ? CoverRenderer.render(base: baseImage, photoScale: photoScale,
                                   photoOffset: photoOffset, layers: layers, drawing: drawing)
            : nil

        note.blocks = blocks
        note.songURL = songURL.isEmpty ? nil : songURL
        note.songTitle = songTitle.isEmpty ? nil : songTitle
        note.songThumbnailURL = songThumbnailURL.isEmpty ? nil : songThumbnailURL
        note.updatedAt = .now

        if existing == nil { context.insert(note) }
        try? context.save()
    }
}
