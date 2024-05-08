import UIKit
import ObjectiveC
import os

//swiftlint:disable force_cast
final class ExampleTableViewController: UITableViewController {
    let startingExampleTitleKey = "com.mapbox.startingExampleTitle"

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
        if #available(iOS 14.0, *) {
            navigationItem.leftBarButtonItem = UIBarButtonItem(title: "SwiftUI", style: .plain, target: self, action: #selector(openSwiftUI))
        }
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "reuseIdentifier")

        navigationController?.delegate = self

        let shouldReopenLastExample = ProcessInfo.processInfo.environment["MAPBOX_REOPEN_EXAMPLE"] == "1"

        if let exampleTitleToStart = UserDefaults.standard.value(forKey: startingExampleTitleKey) as? String, shouldReopenLastExample {

            let initialExample = allExamples
                .flatMap(\.examples)
                .first(where: { $0.title == exampleTitleToStart })
            if let initialExample = initialExample {
                open(example: initialExample, animated: false)
                os_log("Restored example class \"%@\" (%@)", exampleTitleToStart, "\(initialExample.type)")
            } else {
                removeExampleForReopening()
            }
        }
    }

    func storeExampleForReopening(_ example: Example) {
        UserDefaults.standard.set(example.title, forKey: startingExampleTitleKey)
    }

    func removeExampleForReopening() {
        UserDefaults.standard.removeObject(forKey: startingExampleTitleKey)
    }

    @available(iOS 14.0, *)
    @objc func openSwiftUI() {
        present(createSwiftUIExamplesController(), animated: true)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setToolbarHidden(true, animated: false)
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

        return allExamples[section].title
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering {
          return filteredExamples.count
        }

        let examples = allExamples[section].examples
        return examples.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        var example: Example

        if isFiltering {
          example = filteredExamples[indexPath.row]
        } else {
            let examples = allExamples[indexPath.section].examples
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
            let examples = allExamples[indexPath.section].examples
          example = examples[indexPath.row]
        }

        open(example: example)
    }

    func filterContentForSearchText(_ searchText: String) {
        let flatExamples = allExamples.flatMap(\.examples)
        if searchText.isEmpty {
            filteredExamples = flatExamples
        } else {
            filteredExamples = flatExamples.filter { example in
                example.title.lowercased().contains(searchText.lowercased()) ||
                String(describing: example.type).lowercased().contains(searchText.lowercased())
            }
        }

        tableView.reloadData()
    }

    func open(example: Example, animated: Bool = true) {
        storeExampleForReopening(example)
        let exampleViewController = example.makeViewController()
        navigationController?.pushViewController(exampleViewController, animated: animated)
    }
}

extension ExampleTableViewController: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {

        // Remove stored example if we are back to the list
        if self == viewController {
            removeExampleForReopening()
        }
    }
}
