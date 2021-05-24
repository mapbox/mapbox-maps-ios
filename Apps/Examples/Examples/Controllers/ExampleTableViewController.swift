import UIKit
import ObjectiveC

public class ExampleTableViewController: UITableViewController {

    internal var searchBar = UISearchBar()

    public let allExamples = Examples.all
    public var filteredExamples = [Example]()

    public var isFiltering: Bool {
        let searchText = searchBar.text?.isEmpty ?? true
        return !searchText
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        title = "Examples"

        searchBar.delegate = self

        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "reuseIdentifier")
    }
}

extension ExampleTableViewController: UISearchBarDelegate {
    public func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if let searchText = searchBar.text {
            filterContentForSearchText(searchText)
        }
    }

    public func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}

extension ExampleTableViewController {

    public override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            searchBar.placeholder = "Search examples"
            return searchBar
        }

        return nil
    }

    public override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 60.0
        }

        return 30
    }

    public override func numberOfSections(in tableView: UITableView) -> Int {
        if isFiltering {
            return 1
        }

        return allExamples.count
    }

    public override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return nil
        } else {
            return allExamples[section - 1]["title"] as? String
        }
    }
    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        if isFiltering {
          return filteredExamples.count
        }

        if section == 0 {
            return 0
        }
        let examples = allExamples[section - 1]["examples"] as! [Example]
        return examples.count
    }

    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        var example: Example

        if isFiltering {
          example = filteredExamples[indexPath.row]
        } else {
            let examples = allExamples[indexPath.section - 1]["examples"] as! [Example]
          example = examples[indexPath.row]
        }

        let cell = UITableViewCell(style: .default, reuseIdentifier: "reuseIdentifier")
        cell.textLabel?.text = example.title
        return cell
    }

    public override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

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

    public func filterContentForSearchText(_ searchText: String) {
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
