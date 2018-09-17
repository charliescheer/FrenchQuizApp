import UIKit

class VerbConjugationViewController: UIViewController {
    
    var verb : Verbs?
    var tense : String?
    var conjugationDictionary : [String : [String : String]] = [ : ]
    var tenseDictionary : [String : String] = [ : ]
    var articleArray = ["je", "tu", "il", "nous", "vous", "ils"]
    
    @IBOutlet weak var tableView: UITableView!
    
    
    @IBAction func backTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    
    override func viewDidLoad() {
        guard let currentVerb = verb, let currentTense = tense else {
            return
        }
        
        conjugationDictionary = currentVerb.unarchiveDictionary()
        for article in conjugationDictionary[currentTense]! {
            tenseDictionary[article.key] = article.value
            print(tenseDictionary)
        }
    }
}

extension VerbConjugationViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return articleArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let articleCell = tableView.dequeueReusableCell(withIdentifier: constants.tableViewCellIdentifier, for: indexPath) as! ArticleCell
        
        articleCell.articleTextLabel.text = articleArray[indexPath.row]
        articleCell.conjugationTextLabel.text = tenseDictionary[articleArray[indexPath.row]]
        
        return articleCell
    }
}

extension VerbConjugationViewController {
    enum constants {
        static let tableViewCellIdentifier = "articleCell"
    }
}
