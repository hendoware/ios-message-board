import UIKit

enum ReuseIdentifiers: String {
    case messageThreadCell = "ThreadCell"
    case messageCell = "MessageCell"
}

enum SegueIdentifiers: String {
    case toMessageThreadDetailsScene = "ShowMessageThreadDetails"
    case toMessageDetailsScene = "ShowMessageDetails"
    case toNewMessageScene = "ShowNewMessage"
}

class MessageThreadsTableViewController: UITableViewController {
    
    let messageThreadController = MessageThreadController()
    
    @IBOutlet weak var textField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let refreshControl = UIRefreshControl()
        tableView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(fetchThreads(_:)), for: .valueChanged)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchThreads(self)
        self.tableView.reloadData()
    }
    
    @objc private func fetchThreads(_ sender: Any) {
        messageThreadController.fetchMessageThreads { (error) -> (Void) in
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.tableView.refreshControl?.endRefreshing()
            }
        }
    }
    
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messageThreadController.messageThreads.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ReuseIdentifiers.messageThreadCell.rawValue, for: indexPath)
        
        cell.textLabel?.text = messageThreadController.messageThreads[indexPath.row].title
        
        return cell
    }
    
    @IBAction func textAction(_ sender: Any) {
        guard let threadTitle = textField.text else { return }
        
        messageThreadController.createMessageThread(with: threadTitle) { (error) -> (Void) in
            self.fetchThreads(self)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == SegueIdentifiers.toMessageThreadDetailsScene.rawValue {
            guard let destination = segue.destination as? MessageThreadDetailTableViewController,
                let index = tableView.indexPathForSelectedRow?.row else { return }
            destination.messageThreadController = messageThreadController
            destination.messageThread = messageThreadController.messageThreads[index]
        }
    }
}

