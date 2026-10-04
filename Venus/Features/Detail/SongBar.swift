import SwiftUI

/// Bar lagu di bawah halaman detail. Ditekan -> langsung buka Spotify.
struct SongBar: View {
    let note: Note
    @Environment(\.openURL) private var openURL

    var body: some View {
        Button {
            if let link = note.songURL, let url = URL(string: link) { openURL(url) }
        } label: {
            HStack(spacing: 12) {
                Image(systemName: "music.note")
                    .font(.title3)
                    .foregroundStyle(.secondary)
                VStack(alignment: .leading, spacing: 1) {
                    Text(note.songTitle ?? "Spotify link")
                        .font(.subheadline)
                        .lineLimit(1)
                    Text("Spotify")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer(minLength: 8)
                Text("Open in Spotify").font(.subheadline)
            }
            .foregroundStyle(Theme.ink)
            .padding(.horizontal, 18)
            .padding(.vertical, 14)
            .background(Theme.paper, in: Capsule())
            .overlay(Capsule().strokeBorder(Theme.ink.opacity(0.1)))
        }
        .buttonStyle(.plain)
    }
}
