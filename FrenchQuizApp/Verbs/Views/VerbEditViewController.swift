import UIKit

class VerbEditViewController: UIViewController {
    
    var verb : Verbs?
    var conjugationDictionary : [String : [String : String]] = [ : ]
    
    
    override func viewDidLoad() {
        guard let currentVerb = verb else {
            return
        }
        
        if let conjugationData = currentVerb.conjugationDictionary {
            conjugationDictionary = NSKeyedUnarchiver.unarchiveObject(with: conjugationData) as! [String : [String : String]]
        }
        
        print(conjugationDictionary)
    }
    
    
}

extension VerbEditViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let infinitiveCell = UITableViewCell(style: .default, reuseIdentifier: "infinitive")
        
        
        return infinitiveCell
    }
    
    
    
}


