import UIKit

class VerbConjugationViewController: UIViewController {
    
    var verb : Verbs?
    var tense : String?
    var conjugationDictionary : [String : [String : String]] = [ : ]
    var tenseDictionary : [String : String] = [ : ]

    var hasChanged = false
    
    @IBOutlet weak var frenchTextLabel: UILabel!
    @IBOutlet weak var tenseTextLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    @IBAction func backTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        guard let currentVerb = verb, let currentTense = tense else {
            return
        }
        
        frenchTextLabel.text = currentVerb.french
        if let currentTense = tense {
            tenseTextLabel.text = currentTense
        }
        conjugationDictionary = currentVerb.unarchiveDictionary()
        for article in conjugationDictionary[currentTense]! {
            tenseDictionary[article.key] = article.value
            print(tenseDictionary)
        }
        
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        guard let currentTense = tense else {
            return
        }
        
        if verb != nil {
            if hasChanged == true {
                conjugationDictionary[currentTense] = tenseDictionary
                let mutatedDictionary = verb!.mutateDictionaryToData(conjugationDictionary)
                
                verb!.conjugationDictionary = mutatedDictionary
                ManagedData.saveContext()
            }
        }
    }
    
    func mutateDictionaryToData() -> Data {
        let data: Data = NSKeyedArchiver.archivedData(withRootObject: conjugationDictionary)
        
        return data
    }
    
    func displayEditAlert(sender: ArticleCell) {
        let alert = UIAlertController(title: "Enter Conjugation", message: "Enter a new conjugation for \(sender.conjugationTextLabel.text ?? "current conjugation")", preferredStyle: .alert)
        
        
        
        alert.addTextField { (textField) in
            textField.placeholder = sender.conjugationTextLabel.text
        }
        
        
        
        let submitAction = UIAlertAction(title: "Save", style: .default) { (action) in
            let text = alert.textFields![0].text
            alert.textFields![0].keyboardAppearance = UIKeyboardAppearance.alert
            
            if text != "" {
                self.hasChanged = true
                sender.conjugationTextLabel.text = text
                self.tenseDictionary[sender.articleTextLabel.text!] = text
                print(self.tenseDictionary)
            }
        }
        
        alert.addAction(submitAction)
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
    
        
        self.present(alert, animated: true, completion: nil)
    }

}

extension VerbConjugationViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let currentVerb = verb else {
            return 0
        }
        
        let articleArray = currentVerb.returnArticleArray()
        
        return articleArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let currentVerb = verb else {
            let cell = UITableViewCell.init(style: .default, reuseIdentifier: constants.tableViewCellIdentifier)
            return cell
        }
        let articleCell = tableView.dequeueReusableCell(withIdentifier: constants.tableViewCellIdentifier, for: indexPath) as! ArticleCell
        let articleArray = currentVerb.returnArticleArray()
        
        articleCell.articleTextLabel.text = articleArray[indexPath.row]
        articleCell.conjugationTextLabel.text = tenseDictionary[articleArray[indexPath.row]]
        
        return articleCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        displayEditAlert(sender: tableView.cellForRow(at: indexPath) as! ArticleCell)
    }
}

extension VerbConjugationViewController {
    enum constants {
        static let tableViewCellIdentifier = "articleCell"
    }
}
