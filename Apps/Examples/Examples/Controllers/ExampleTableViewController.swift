import UIKit
import ObjectiveC

//swiftlint:disable force_cast
final class ExampleTableViewController: UITableViewController {

    let allExamples = Examples.all
    var filteredExamples = [Example]()

    var isFiltering: Bool { navigationItem.searchController?.isActive ?? false }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Examples"

        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.searchBar.placeholder = "Search examples"
        searchController.obscuresBackgroundDuringPresentation = false
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "reuseIdentifier")
    }
}

extension ExampleTableViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        if let searchText = searchController.searchBar.text {
            filterContentForSearchText(searchText)
        }
    }
}

extension ExampleTableViewController {

    override func numberOfSections(in tableView: UITableView) -> Int {
        if isFiltering {
            return 1
        }

        return allExamples.count
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if isFiltering {
            return nil
        }

        return allExamples[section]["title"] as? String
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering {
          return filteredExamples.count
        }

        let examples = allExamples[section]["examples"] as! [Example]
        return examples.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        var example: Example

        if isFiltering {
          example = filteredExamples[indexPath.row]
        } else {
            let examples = allExamples[indexPath.section]["examples"] as! [Example]
          example = examples[indexPath.row]
        }

        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "reuseIdentifier")
        cell.textLabel?.text = example.title
        cell.textLabel?.numberOfLines = 2
        cell.detailTextLabel?.text = example.description.trimmingCharacters(in: .whitespacesAndNewlines)
        cell.detailTextLabel?.numberOfLines = 2
        if #available(iOS 13.0, *) {
            cell.detailTextLabel?.textColor = .secondaryLabel
        } else {
            cell.detailTextLabel?.textColor = .lightGray
        }
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        var example: Example

        if isFiltering {
          example = filteredExamples[indexPath.row]
        } else {
            let examples = allExamples[indexPath.section]["examples"] as! [Example]
          example = examples[indexPath.row]
        }

        let exampleViewController = example.makeViewController()
        navigationController?.pushViewController(exampleViewController, animated: true)
    }

    func filterContentForSearchText(_ searchText: String) {
        let flatExamples = allExamples.flatMap { $0["examples"] as! [Example] }
        if searchText.isEmpty {
            filteredExamples = flatExamples
        } else {
            filteredExamples = flatExamples.filter { $0.title.lowercased().contains(searchText.lowercased()) }
        }

      tableView.reloadData()
    }
}
