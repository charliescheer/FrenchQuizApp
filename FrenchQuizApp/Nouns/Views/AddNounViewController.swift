import UIKit
import CoreData

class AddNounViewController:  UIViewController {
    
    @IBOutlet weak var englishTextField: UITextField!
    @IBOutlet weak var frenchTextField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var genderSwitch: UISwitch!
    
    var dataResultsController = ManagedData.resultsController
    var managedObjectContext = ManagedData.persistentContainer.viewContext
    
    
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
        }
        
        do {
            try dataResultsController.performFetch()
        } catch {
            print("fetch failed")
        }
        
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
