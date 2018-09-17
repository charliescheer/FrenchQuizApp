import UIKit

class VerbEditViewController: UIViewController {
    
    var verb : Verbs?
    var conjugationDictionary : [String : [String : String]] = [ : ]
    var tenseArray = ["Présent", "Imparfait", "Futur", "Passé", "Passé simple"]
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var englishTextLabel: UILabel!
    @IBOutlet weak var frenchTextLabel: UILabel!
    
    
    @IBAction func backTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        guard let currentVerb = verb else {
            return
        }
        
        conjugationDictionary = currentVerb.unarchiveDictionary()
        
        englishTextLabel.text = currentVerb.english
        frenchTextLabel.text = currentVerb.french
    }
    
}

extension VerbEditViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tenseArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
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

