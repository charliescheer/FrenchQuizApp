import UIKit
import CoreData

class AddNounViewController:  UIViewController {
    
    @IBOutlet weak var englishTextField: UITextField!
    @IBOutlet weak var frenchTextField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var genderSwitch: UISwitch!
    
    var dataResultsController = ManagedData.nounResultsController
    var managedObjectContext = ManagedData.persistentContainer.viewContext
    
    override func viewDidLoad() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    
    override func viewDidDisappear(_ animated: Bool) {
        ManagedData.saveContext()
    }
    
    @IBAction func addPhraseButtonWasPressed(_ sender: Any) {
        if englishTextField.text == "" || frenchTextField.text == "" {
            displayEmptyNounAlert()
        } else {
            let englishNoun = englishTextField.text!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            let frenchNoun = frenchTextField.text!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            
            createNewNoun(english: englishNoun, french: frenchNoun)
            clearUserFields()
        }
    }
    
    func createNewNoun(english: String, french: String) {
        if let newNoun = NSEntityDescription.insertNewObject(forEntityName: "Nouns", into: managedObjectContext) as? Nouns {
            newNoun.english = english
            newNoun.french = french
            newNoun.creationDate = NSDate() as Date
            
            if genderSwitch.isOn {
                newNoun.setGenderFemale()
            } else {
                newNoun.setGenderMale()
            }
            
            ManagedData.saveContext()
        } else {
            print("couldn't create new object")
        }
        
        do {
            try dataResultsController.performFetch()
        } catch {
            print("fetch failed")
        }
        print(dataResultsController.fetchedObjects?.count)
        tableView.reloadData()
    }
    
    func clearUserFields() {
        englishTextField.text! = ""
        frenchTextField.text! = ""
        genderSwitch.isOn = false
    }
    
    func displayEmptyNounAlert () {
        let alert = UIAlertController(title: "Enter Noun", message: "Please enter a Noun for both fields", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
        self.present(alert, animated: true)
    }
}

extension AddNounViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        guard  let sections = dataResultsController.sections else {
            return 0
        }
        
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sectionInfo = dataResultsController.sections?[section] else {
            fatalError("No sections in fetchedResultsController")
        }
        
        return sectionInfo.numberOfObjects
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: constants.tableViewCellIdentifier, for: indexPath) as! NounCell
        
        if let noun = dataResultsController.object(at: indexPath) as? Nouns {
            cell.englishNounTextLabel.text = noun.english
            cell.frenchNounTextLabel.text = noun.french
        }
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: constants.showNounVC, sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == constants.showNounVC {
            let nounVC = segue.destination as? NounEditViewController
            
            guard let nounCell = sender as? UITableViewCell, let indexPath = tableView.indexPath(for: nounCell) else {
                return
            }
            
            if let noun  = dataResultsController.object(at: indexPath) as? Nouns {
                nounVC?.noun = noun
            }
        }
    }

}

extension AddNounViewController {
    enum constants {
        static let tableViewCellIdentifier = "nounCell"
        static let showNounVC = "ShowNoun"
    }
}
