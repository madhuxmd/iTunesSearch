


import UIKit

extension DashboardViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        // prepare results

        guard let searchString = searchController.searchBar.text?.trimmingCharacters(in: .whitespacesAndNewlines),
            searchString.count >= 3 else {
                return
        }

        guard let searchRequest = iTunesSearchRequest(term: searchString, media: searchScopes[selectedScopeIndex]) else {
            return
        }

        iTunesCatalogLiteManager.shared.searchCatalog(searchRequest) { [weak self] (result) in
            guard let self = self else { return }

            switch result {
            case .success(let data):
                self.decodeData(data)
            case .failure:
                // TODO: Handle errors
                break
            }
        }
    }

    fileprivate func decodeData(_ data: (Data)) {
        iTunesCatalogLiteManager.shared.decodeSearchResponse(from: data) { [weak self] (result) in
            switch result {
            case .success(let searchResults):
                DispatchQueue.main.async {
                    self?.handleSearchResults(searchResults)
                }
            case .failure:
                // TODO: Handle errors
                break
            }
        }
    }

    fileprivate func handleSearchResults(_ results: ([iTunesResultType : [iTunesSearchResult]])) {
        if let resultsController = searchController.searchResultsController as? SearchResultTableViewController {
            resultsController.searchResult = results
            resultsController.tableView.reloadData()

            var resultCount = 0
            for result in results {
                resultCount += result.value.count
            }
            resultsController.resultsLabel?.text = resultCount == 0 ? "No results" : String(format: "Found %d results:", resultCount)
        }
    }

}
