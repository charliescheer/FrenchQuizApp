import UIKit

class VerbEditViewController: UIViewController {
    
    var verb : Verbs?
    var conjugationDictionary : [String : [String : String]] = [ : ]
    enum TableSection : Int {
        case Présent = 0, Imparfait, simple, Passé, Futur, total
    }
    let SectionHeaderHeight: CGFloat = 25
    
    var data = [TableSection: [[String: String]]]()
    
    
    @IBAction func backTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    
    override func viewDidLoad() {
        guard let currentVerb = verb else {
            return
        }
        
        if let conjugationData = currentVerb.conjugationDictionary {
            conjugationDictionary = NSKeyedUnarchiver.unarchiveObject(with: conjugationData) as! [String : [String : String]]
        }
        
        print(conjugationDictionary.keys)
    }
    
}

extension VerbEditViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let articleCell = UITableViewCell(style: .default, reuseIdentifier: "article")
        articleCell.textLabel?.text = "article"
        
        let conjugationCell =  UITableViewCell(style: .default, reuseIdentifier: "conjugation")
        
        return articleCell
    }
    
    
    
}


