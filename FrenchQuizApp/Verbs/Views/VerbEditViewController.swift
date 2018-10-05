import UIKit

class VerbEditViewController: UIViewController {
    
    var verb : Verbs?
    var conjugationDictionary : [String : [String : String]] = [ : ]
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var englishTextLabel: UILabel!
    @IBOutlet weak var frenchTextLabel: UILabel!
    @IBOutlet weak var timesCorrectLabel: UILabel!
    @IBOutlet weak var timesIncorrectLabel: UILabel!
    @IBOutlet weak var correctInARowLabel: UILabel!
    @IBOutlet weak var learnedLabel: UILabel!
    @IBOutlet weak var deleteSaveButton: UIBarButtonItem!

    
    
    
    
    @IBAction func backTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func resetTapped(_ sender: Any) {
        if let currentVerb = verb {
            displayResetAlert(verb: currentVerb)
        }
    }
    
    @IBAction func deleteSaveTapped(_ sender: Any) {
            displayDeleteAlert()
    }

    
    override func viewDidLoad() {
        guard let currentVerb = verb else {
            return
        }
        
        conjugationDictionary = currentVerb.unarchiveDictionary()
        
        setupView()
    }
    
    func setupView() {
        if let currentVerb = verb {
            englishTextLabel.text = currentVerb.english
            frenchTextLabel.text = currentVerb.french
            timesCorrectLabel.text = String(currentVerb.timesCorrect)
            timesIncorrectLabel.text = String(currentVerb.timesIncorrect)
            correctInARowLabel.text = String(currentVerb.correctInARow)
            
            if currentVerb.learned {
                learnedLabel.text = "Learned"
            } else {
                learnedLabel.text = "Not Learned"
            }
        
        }
    }
    
    func displayDeleteAlert () {
        if let currentVerb = verb {
            let alert = UIAlertController(title: "Are you sure?", message: "This will delete '\(currentVerb.english ?? "No Phrase Selected")'", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: {action in self.didConfirmDeletePhrase()}))
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            
            self.present(alert, animated: true)
        }
    }
    
    func displayResetAlert (verb: Verbs) {
        let alert = UIAlertController(title: "Reset Counts", message: "This will set the counts for '\(verb.english ?? "No Phrase Selected")' back to 0, are you sure?", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: {action in self.didConfirmResetCounts()}))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        
        self.present(alert, animated: true)
    }
    
    func didConfirmResetCounts (){
        verb!.resetCountPhraseCounts()
        setupView()
    }
    
    func didConfirmDeletePhrase() {
        let context = ManagedData.persistentContainer.viewContext
        
        if let currentVerb = verb {
            context.delete(currentVerb)
            do {
                try context.save()
            } catch {
                print(error)
            }
            
            returnsToList()
        }
    }
    
    func returnsToList () {
        self.dismiss(animated: true, completion: nil)
    }
    
}

extension VerbEditViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let currentVerb = verb else {
            return 0
        }
        
        let tenseArray = currentVerb.returnTenseArray()
        return tenseArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let currentVerb = verb else {
            let cell = UITableViewCell.init(style: .default, reuseIdentifier: constants.tableViewCellIdentifier)
            return cell
        }
        
        let tenseArray = currentVerb.returnTenseArray()
        
        let tenseCell = tableView.dequeueReusableCell(withIdentifier: constants.tableViewCellIdentifier, for: indexPath) as! TenseCell
        tenseCell.tenseTextLabel.text = tenseArray[indexPath.row]
        
        return tenseCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: constants.showVerbArticleVC, sender: nil)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == constants.showVerbArticleVC {
            
            guard let tenseCell = sender as? UITableViewCell, let indexPath = tableView.indexPath(for: tenseCell) else {
                return
            }
            
            guard let currentVerb = verb else {
                return
            }
            
            let tenseArray = currentVerb.returnTenseArray()
            let articleVC = segue.destination as? VerbConjugationViewController
            
            articleVC?.verb = currentVerb
            articleVC?.tense = tenseArray[indexPath.row]
        
        }
            
    }
    
}

extension VerbEditViewController {
    enum constants {
        static let showVerbArticleVC = "showArticle"
        static let tableViewCellIdentifier = "tenseCell"
    }
    
    enum tenses {
        static let present = "Présent"
        static let imparfait = "Imparfait"
        static let futur = "Futur"
        static let passe = "Passé"
        static let simple = "Passé simple"
    }
}

