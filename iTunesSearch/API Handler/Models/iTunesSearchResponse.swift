


import Foundation

/// Wrapper for iTunes Search results [Documentation](https://affiliate.itunes.apple.com/resources/documentation/itunes-store-web-service-search-api/#understand)
public struct iTunesSearchResult: Codable {
    public private(set) var id: Int
    public private(set) var name: String?
    public private(set) var artwork: String?
    public private(set) var genre: String?
    public private(set) var url: String?
    public private(set) var kind: String
    public private(set) var previewUrl: String?
    public private(set) var collectionName: String?

    /// `iTunesResultType` wrapper of the kind of content
    public var type: iTunesResultType {
        return iTunesResultType(rawValue: kind) ?? .unknown
    }

    enum CodingKeys: String, CodingKey {
        case id = "trackId"
        case name = "trackName"
        case artwork = "artworkUrl100"
        case genre = "primaryGenreName"
        case url = "trackViewUrl"
        case kind
        case previewUrl
        case collectionName
    }

}

/// Wrapper for the kind of content returned by the search request.
public enum iTunesResultType: String, RawRepresentable, Codable {
    case album
    case book
    case coachedAudio = "coached-audio"
    case featureMovie = "feature-movie"
    case interactiveBooklet = "interactive-booklet"
    case musicVideo = "music-video"
    case pdfPodcast = "pdf podcast"
    case podcastEpisode = "podcast-episode"
    case softwarePackage = "software-package"
    case song
    case tvEpisode = "tv-episode"
    case artist
    case unknown

    public var displayTitle: String {
        switch self {
        case .album:
            return "Albums"
        case .book:
            return "Books"
        case .coachedAudio:
            return "Coached Audio"
        case .featureMovie:
            return "Movies"
        case .interactiveBooklet:
            return "Interactive Booklet"
        case .musicVideo:
            return "Music Video"
        case .pdfPodcast:
            return "PDF Podcast"
        case .podcastEpisode:
            return "Podcast Episodes"
        case .softwarePackage:
            return "Software"
        case .song:
            return "Songs"
        case .tvEpisode:
            return "TV Episodes"
        case .artist:
            return "Artists"
        case .unknown:
            return "Unknown"
        }
    }
}
