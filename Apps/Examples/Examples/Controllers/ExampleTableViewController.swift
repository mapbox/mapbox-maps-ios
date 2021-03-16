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

        return 0
    }

    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        if isFiltering {
          return filteredExamples.count
        }

        return allExamples.count
    }

    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        var example: Example

        if isFiltering {
          example = filteredExamples[indexPath.row]
        } else {
          example = allExamples[indexPath.row]
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
          example = allExamples[indexPath.row]
        }

        show(example: example)
    }

    internal func show(example: Example) {
        let exampleToDisplay = makeViewController(for: example)
        navigationController?.pushViewController(exampleToDisplay, animated: true)
    }

    public func filterContentForSearchText(_ searchText: String) {
        filteredExamples = allExamples.filter {
            return $0.title.lowercased().contains(searchText.lowercased())
        }

      tableView.reloadData()
    }

    public func makeViewController(for example: Example) -> UIViewController {
        guard let exampleClass = example.type as? UIViewController.Type else {
            fatalError("Unable to get class name from example named \(example.type)")
        }

        let exampleViewController = exampleClass.init()
        exampleViewController.title = example.title
        exampleViewController.navigationItem.largeTitleDisplayMode = .never

        let association = ExampleAssociation(example: example, viewController: exampleViewController)
        objc_setAssociatedObject(exampleViewController, &ExampleAssociationHandle, association, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        let barButtonItem = UIBarButtonItem(title: "Info", style: .plain, target: association, action: #selector(ExampleAssociation.presentAlert))

        exampleViewController.navigationItem.setRightBarButton(barButtonItem, animated: false)

        return exampleViewController
    }
}

private var ExampleAssociationHandle: UInt8 = 0
internal class ExampleAssociation: NSObject {

    internal let example: Example
    internal weak var viewController: UIViewController?

    internal init(example: Example, viewController: UIViewController) {
        self.example = example
        self.viewController = viewController
        super.init()
    }

    @objc func presentAlert() {
        guard let viewController = viewController else {
            return
        }

        let alert = UIAlertController(title: "About this example",
                                      message: example.description,
                                      preferredStyle: .alert)
        let action = UIAlertAction(title: "Got it", style: .default, handler: nil)
        alert.addAction(action)
        viewController.present(alert, animated: true, completion: nil)
    }
}
