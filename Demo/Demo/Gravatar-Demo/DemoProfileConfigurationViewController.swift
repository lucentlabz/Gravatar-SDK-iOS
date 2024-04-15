import UIKit
import Gravatar
import GravatarUI

class DemoProfileConfigurationViewController: UITableViewController {
    lazy var dataSource = UITableViewDiffableDataSource<Section, String>(tableView: tableView) { [weak self] tableView, indexPath, itemIdentifier in
        let cellID = "ProfileCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID) ?? UITableViewCell(style: .default, reuseIdentifier: cellID)
        let model = self?.models[itemIdentifier]
        cell.contentConfiguration = ProfileViewConfiguration.summary(model: model)
        return cell
    }

    var snapshot = NSDiffableDataSourceSnapshot<Section, String>()
    var models = [String: UserProfile]()

    override func viewDidLoad() {
        super.viewDidLoad()
        snapshot.appendSections([.main])
        dataSource.apply(snapshot)
        dataSource.defaultRowAnimation = .fade

        view.backgroundColor = .secondarySystemBackground

        navigationItem.rightBarButtonItem = UIBarButtonItem(
            systemItem: .add,
            primaryAction: UIAction() {[weak self] _ in
                self?.requestEmail()
            }
        )
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if snapshot.itemIdentifiers.isEmpty {
            requestEmail()
        }
    }

    func requestEmail() {
        let alert = UIAlertController(
            title: "Add Email",
            message: "Insert an email to add a new Gravatar profile",
            preferredStyle: .alert
        )
        var textField: UITextField?
        alert.addTextField { alertTextField in
            textField = alertTextField
        }

        alert.addAction(UIAlertAction(title: "Add", style: .destructive, handler: { action in
            Task {
                await self.addEmail(textField?.text ?? "")
            }
        }))

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { action in
            self.dismiss(animated: true)
        }))

        present(alert, animated: true)
    }

    func addEmail(_ email: String) async {
        guard !email.isEmpty else { return }

        snapshot.appendItems([email])
        await dataSource.apply(snapshot)

        let service = ProfileService()
        do {
            let profile = try await service.fetch(with: .email(email))
            models[email] = profile
            snapshot.reloadItems([email])
            await dataSource.apply(snapshot)
        } catch {
            print(error)
        }
    }
}

enum Section {
    case main
}
