import UIKit

class NounEditViewController : UIViewController {
    
    var noun : Nouns?
    var mode = "View"
    
    @IBOutlet weak var englishTextField: UITextField!
    @IBOutlet weak var frenchTextField: UITextField!
    @IBOutlet weak var genderSwitch: UISwitch!
    @IBOutlet weak var correctLabel: UILabel!
    @IBOutlet weak var incorrectLabel: UILabel!
    @IBOutlet weak var inARowLabel: UILabel!
    @IBOutlet weak var learnedLabel: UILabel!
    @IBOutlet weak var deleteSaveButton: UIBarButtonItem!
    @IBOutlet weak var editViewButton: UIBarButtonItem!
    
    
    @IBAction func backTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func editTapped(_ sender: Any) {
        if mode == "View" {
            enterEdit()
        } else if mode == "Edit" {
            updatePhrase()
            enterView()
        } else {
            print("The mode is out of range")
        }
    }
    
    @IBAction func resetTapped(_ sender: Any) {
    }
    
    @IBAction func deleteSaveTapped(_ sender: Any) {
        if mode == "View" {
            displayDeleteAlert()
        } else if mode == "Edit" {
            updatePhrase()
            enterView()
        } else {
            print("Error: The mode is not correct")
        }
    }
    
    override func viewDidLoad() {
        setupView()
        setupMode()
    }
    
    func enterView() {
        mode = "View"
        editViewButton.title = "Edit"
        deleteSaveButton.title = "Delete"
        
        
        englishTextField?.isUserInteractionEnabled = false
        frenchTextField?.isUserInteractionEnabled = false
    }
    
    func enterEdit() {
        mode = "Edit"
        editViewButton.title = "View"
        deleteSaveButton?.title = "Save"
        
        
        englishTextField?.isUserInteractionEnabled = true
        frenchTextField?.isUserInteractionEnabled = true
    }
    
    
    func updatePhrase() {
        if noun != nil {
            noun?.english = englishTextField.text
            noun?.french = frenchTextField.text
        }
    }
    
    func didConfirmResetCounts (){
        noun!.resetCountPhraseCounts()
        setupView()
    }
    
    func didConfirmDeletePhrase() {
        let context = ManagedData.persistentContainer.viewContext
        
        if let currentNoun = noun {
            context.delete(currentNoun)
            returnsToList()
        }
    }
    
    func returnsToList () {
        let storyboard = UIStoryboard(name: "Nouns", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "addNoun")
        self.dismiss(animated: true, completion: nil)
        self.present(controller, animated: true, completion: nil)
    }
    
    func setupView() {
        if let currentNoun = noun {
            englishTextField.text = currentNoun.english
            frenchTextField.text = currentNoun.french
            correctLabel.text = String(currentNoun.timesCorrect)
            incorrectLabel.text = String(currentNoun.timesIncorrect)
            inARowLabel.text = String(currentNoun.correctInARow)
            
            if currentNoun.learned {
                learnedLabel.text = "Learned"
            } else {
                learnedLabel.text = "Not Learned"
            }
            
            if currentNoun.gender == Nouns.constants.male {
                genderSwitch.isOn = false
            } else {
                genderSwitch.isOn = true
            }
        }
    }
    
    func setupMode() {
        if mode == "View"{
            editViewButton.title = "Edit"
            deleteSaveButton?.title = "Delete"
        } else if mode == "Edit" {
            editViewButton.title = "View"
            deleteSaveButton?.title = "Save"
        } else {
            print("Error: Mode is out of range")
        }
    }
    
    func displayDeleteAlert () {
        if let currentNoun = noun {
            let alert = UIAlertController(title: "Are you sure?", message: "This will delete '\(currentNoun.english ?? "No Phrase Selected")'", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: {action in self.didConfirmDeletePhrase()}))
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            
            self.present(alert, animated: true)
        }
    }
    
    func displayResetAlert (phrase: Phrases) {
        let alert = UIAlertController(title: "Reset Counts", message: "This will set the counts for '\(noun?.english ?? "No Phrase Selected")' back to 0, are you sure?", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: {action in self.didConfirmResetCounts()}))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        
        self.present(alert, animated: true)
    }
}
