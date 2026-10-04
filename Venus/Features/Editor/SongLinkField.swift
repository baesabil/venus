import SwiftUI

/// Kolom link lagu Spotify. Tempel link -> judul & cover lagu terisi otomatis.
/// Ditekan -> langsung terbuka di app Spotify.
struct SongLinkField: View {
    @Bindable var vm: NoteEditorViewModel
    @State private var input = ""
    @Environment(\.openURL) private var openURL

    var body: some View {
        if vm.songURL.isEmpty {
            inputRow
        } else if vm.songTitleFailed {
            manualTitleRow
        } else {
            songChip
        }
    }

    // 1) Belum ada lagu: kolom tempel link
    private var inputRow: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 10) {
                Image(systemName: "music.note")
                TextField("Paste a Spotify link", text: $input)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .keyboardType(.URL)
                    .submitLabel(.go)
                    .onSubmit { submit(input) }
                if vm.isFetchingSong {
                    ProgressView()
                } else {
                    // PasteButton = tempel tanpa popup izin clipboard.
                    PasteButton(payloadType: String.self) { strings in
                        if let first = strings.first {
                            input = first
                            submit(first)
                        }
                    }
                    .labelStyle(.iconOnly)
                    .buttonBorderShape(.capsule)
                    .tint(Theme.ink)
                }
            }
            .padding(.horizontal, 16).padding(.vertical, 10)
            .background(Theme.paperSurface.opacity(0.5), in: Capsule())

            if let error = vm.songError {
                Text(error).font(.caption).foregroundStyle(.red).padding(.leading, 16)
            }
        }
    }

    // 2) Link ada tapi judul gagal diambil: ketik manual
    private var manualTitleRow: some View {
        HStack(spacing: 10) {
            Image(systemName: "music.note")
            TextField("Couldn't fetch the title, type it", text: $vm.songTitle)
            Button("Done") {
                if !vm.songTitle.isEmpty { vm.songTitleFailed = false }
            }
            .font(.subheadline.weight(.semibold))
        }
        .padding(.horizontal, 16).padding(.vertical, 10)
        .background(Theme.paperSurface.opacity(0.5), in: Capsule())
    }

    // 3) Lagu sudah ada: chip dengan cover + judul
    private var songChip: some View {
        HStack(spacing: 12) {
            Button {
                if let url = URL(string: vm.songURL) { openURL(url) }
            } label: {
                HStack(spacing: 12) {
                    AsyncImage(url: URL(string: vm.songThumbnailURL)) { image in
                        image.resizable().scaledToFill()
                    } placeholder: {
                        Theme.paperSurface
                    }
                    .frame(width: 44, height: 44)
                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))

                    VStack(alignment: .leading, spacing: 2) {
                        Text(vm.songTitle)
                            .font(.subheadline.weight(.semibold))
                            .lineLimit(1)
                        Text("Open in Spotify")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .foregroundStyle(Theme.ink)
                    Spacer(minLength: 0)
                }
            }
            .buttonStyle(.plain)

            Button { vm.clearSong(); input = "" } label: {
                Image(systemName: "xmark.circle.fill").foregroundStyle(.secondary)
            }
            .buttonStyle(.plain)
        }
        .padding(10)
        .background(Theme.paperSurface.opacity(0.5), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
    }

    private func submit(_ link: String) {
        Task { await vm.attachSong(link: link) }
    }
}
