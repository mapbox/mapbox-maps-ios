import UIKit
import ObjectiveC

//swiftlint:disable force_cast
final class ExampleTableViewController: UITableViewController {

    internal var searchBar = UISearchBar()

    let allExamples = Examples.all
    var filteredExamples = [Example]()

    var isFiltering: Bool {
        let searchText = searchBar.text?.isEmpty ?? true
        return !searchText
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Examples"

        searchBar.delegate = self

        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "reuseIdentifier")
    }
}

extension ExampleTableViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if let searchText = searchBar.text {
            filterContentForSearchText(searchText)
        }
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}

extension ExampleTableViewController {

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            searchBar.placeholder = "Search examples"
            return searchBar
        }

        return nil
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 60.0
        }

        return 30
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        if isFiltering {
            return 1
        }

        return allExamples.count + 1
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return nil
        } else {
            return allExamples[section - 1]["title"] as? String
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        if isFiltering {
          return filteredExamples.count
        }

        if section == 0 {
            return 0
        }
        let examples = allExamples[section - 1]["examples"] as! [Example]
        return examples.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        var example: Example

        if isFiltering {
          example = filteredExamples[indexPath.row]
        } else {
            let examples = allExamples[indexPath.section - 1]["examples"] as! [Example]
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
            let examples = allExamples[indexPath.section - 1]["examples"] as! [Example]
          example = examples[indexPath.row]
        }

        let exampleViewController = example.makeViewController()
        navigationController?.pushViewController(exampleViewController, animated: true)
    }

    func filterContentForSearchText(_ searchText: String) {
        var examples = [Example]()

        for array in allExamples {
            examples.append(contentsOf: array["examples"] as! [Example])
        }
        filteredExamples = examples.filter {
            return $0.title.lowercased().contains(searchText.lowercased())
        }

      tableView.reloadData()
    }
}
