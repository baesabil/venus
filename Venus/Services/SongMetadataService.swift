import Foundation

struct SpotifyTrackInfo {
    let title: String
    let thumbnailURL: String?
}

enum SongMetadataError: Error {
    case notSpotifyLink
    case badResponse
}

/// Mengambil judul + cover lagu dari link Spotify.
/// Memakai endpoint "oEmbed" publik milik Spotify: tanpa API key, tanpa login.
enum SongMetadataService {
    private struct OEmbedResponse: Decodable {
        let title: String
        let thumbnail_url: String?
    }

    static func fetch(link: String) async throws -> SpotifyTrackInfo {
        guard let url = URL(string: link), (url.host ?? "").contains("spotify") else {
            throw SongMetadataError.notSpotifyLink
        }
        var components = URLComponents(string: "https://open.spotify.com/oembed")!
        components.queryItems = [URLQueryItem(name: "url", value: url.absoluteString)]

        let (data, response) = try await URLSession.shared.data(from: components.url!)
        guard (response as? HTTPURLResponse)?.statusCode == 200 else {
            throw SongMetadataError.badResponse
        }
        let decoded = try JSONDecoder().decode(OEmbedResponse.self, from: data)
        return SpotifyTrackInfo(title: decoded.title, thumbnailURL: decoded.thumbnail_url)
    }
}
