



import Foundation

public struct iTunesSearchRequest {
    // MARK: - Variables

    var term: String
    var media: String
    var limit: String
    var countryCode: String {
        return Locale.current.regionCode ?? Constants.defaultCountryCode
    }

    public var parameterKeyValue: String {
        let items: [SearchKey: String] = [
            .term : term,
            .country : countryCode,
            .media : media,
            .limit : limit
        ]

        return (items.compactMap({
                return "\($0.key)=\($0.value)"
            }) as [String])
            .sorted()
            .joined(separator: "&")
    }

    // MARK: - Lifecycle

    /// Creates a `iTunesSearchRequest` with the provided queries
    /// - Parameters:
    ///   - term: `String` The URL-encoded text string you want to search for. For example: jack+johnson
    ///   - media: `SearchMedia` The media type you want to search for. For example: movie. The default is `SearchMedia.all`
    ///   - limit: `Int` The number of search results you want the iTunes Store to return from 1-200. For example: 25.The default is 50.
    public init?(term: String,
          media: SearchMedia = .all,
          limit: Int = 50) {
        guard term.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false,
            let termQuery = term
                   .replacingOccurrences(of: " ", with: "+")
                   .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
                   return nil
        }
        self.term = termQuery
        self.media = media.rawValue

        switch limit {
        case ...0:
            self.limit = "1"
        case 1...200:
            self.limit = String(limit)
        case 200...:
            self.limit = "200"
        default:
            self.limit = "50"
        }
    }
}

public extension iTunesSearchRequest {
    internal enum SearchKey: String, RawRepresentable {
        case term
        case country
        case media
        case entity
        case attribute
        case limit
        case lang
        case version
        case explicit
    }

    /// Wrapper for defined media type you want to search for - For example: movie [Documentation](https://affiliate.itunes.apple.com/resources/documentation/itunes-store-web-service-search-api/)
    enum SearchMedia: String, RawRepresentable {
        case movie
        case podcast
        case music
        case musicVideo
        case audiobook
        case shortFilm
        case tvShow
        case software
        case ebook
        case all

        /// Visual title for the specified media. For example: Movie
        public var title: String {
            let pattern = "([a-z0-9])([A-Z])"

            let regex = try? NSRegularExpression(pattern: pattern, options: [])
            let range = NSRange(location: 0, length: self.rawValue.count)
            return regex?.stringByReplacingMatches(in: self.rawValue, options: [], range: range, withTemplate: "$1 $2").capitalized ?? ""
        }

        init?(title: String) {
            let rawScope = title.firstLowercased.replacingOccurrences(of: " ", with: "")

            if let media = SearchMedia(rawValue: rawScope) {
                self = media
            } else {
                return nil
            }
        }
    }
}

extension iTunesSearchRequest {
    struct Constants {
        static let defaultCountryCode = "US"
    }
}

extension StringProtocol {
    var firstLowercased: String { prefix(1).lowercased() + dropFirst() }
}
