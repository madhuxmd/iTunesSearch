


import Foundation

/// API Manager responsible for creating requests
public class iTunesCatalogLiteManager {

    /// Singleton instance of the `APIManager`
    public static var shared = iTunesCatalogLiteManager()

    private init() {
        // no-op
    }

    /// Searches the iTunes Catalog asynchronously for the given search request
    /// - Parameters:
    ///   - searchRequest: `iTunesSearchRequest` used to gather data from iTunes
    ///   - completion: `Result<Data, CatalogAPIError` that holds the JSON response or an error
    public func searchCatalog(_ searchRequest: iTunesSearchRequest,
                              completion: @escaping (Result<Data, CatalogAPIError>) -> Void) {
        guard let urlRequest = createUrlRequest(searchRequest) else {
            completion(.failure(.malformedUrlRequestError))
            return
        }

        // fetching
        URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
            // handle errors
            guard error == nil,
                (response as? HTTPURLResponse)?.statusCode == 200,
                let data = data else {
                completion(.failure(.generalError))
                return
            }

            // gather raw data in [String: AnyHashable]
            guard let rawJson: [String: AnyHashable] = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: AnyHashable],
                let dataResponse = self.constructData(from: rawJson) else {
                completion(.failure(.decodingError))
                return
            }
            completion(.success(dataResponse))
        }.resume()
    }

    /// Helper to decode iTunes Search requests to a type safe model
    /// - Parameters:
    ///   - jsonData: `Data` of the response data from `searchCatalog`
    ///   - completion: `Result<[iTunesResultType: [iTunesSearchResult]], CatalogAPIError` that holds the typed response or an error
    public func decodeSearchResponse(from jsonData: Data,
                                     completion: @escaping (Result<[iTunesResultType: [iTunesSearchResult]], CatalogAPIError>) -> Void) {
        guard let response = try? JSONDecoder().decode([String: [iTunesSearchResult]].self, from: jsonData) else {
            completion(.failure(.decodingError))
            return
        }

        var typedResponse = [iTunesResultType: [iTunesSearchResult]]()

        for result in response {
            if let type = iTunesResultType(rawValue: result.key.lowercased()) {
                typedResponse[type] = result.value
            }
        }

        completion(.success(typedResponse))
    }
}

// MARK: - Private Helpers
extension iTunesCatalogLiteManager {
    func createUrlRequest(_ searchRequest: iTunesSearchRequest) -> URLRequest? {
        let urlString = Endpoints.search.path + "?" + searchRequest.parameterKeyValue
        guard let url = URL(string: urlString) else {
            return nil
        }

        return URLRequest(url: url,
                          cachePolicy: .returnCacheDataElseLoad,
                          timeoutInterval: iTunesCatalogLiteManager.requestTimeout)
    }

    func constructData(from jsonObject: [String: AnyHashable]) -> Data? {
        guard let results = jsonObject["results"] as? [AnyHashable] else {
            return nil
        }

        var response = [String: [AnyHashable]]()

        // parse all of the unique types
        results.forEach({ result in
            if let media = result as? [String: AnyHashable],
                let kind = media["kind"] as? String {
                if var existingValues = response[kind] {
                    existingValues.append(result)
                    response.updateValue(existingValues, forKey: kind)
                } else {
                    response[kind] = [result]
                }
            }
        })

        let jsonData: Data?
        if #available(iOS 11.0, *) {
            jsonData = try? JSONSerialization.data(withJSONObject: response, options: .sortedKeys)
        } else {
            jsonData = try? JSONSerialization.data(withJSONObject: response, options: .prettyPrinted)
        }

        return jsonData
    }
}

// MARK: - Private Constants
extension iTunesCatalogLiteManager {
    static let iTunesDomain: String = "https://itunes.apple.com"
    static let requestTimeout = TimeInterval(floatLiteral: 20.0)

    enum Endpoints: String, RawRepresentable {
        case search

        var path: String {
            return  iTunesDomain + "/" + self.rawValue
        }

    }
}
