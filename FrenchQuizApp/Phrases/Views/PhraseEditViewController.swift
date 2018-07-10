import UIKit
import CoreData

class PhraseEditViewController: UIViewController {
    
    var phrase: Phrases?
    var mode = "View"
    
    @IBOutlet weak var correctLabel: UILabel?
    @IBOutlet weak var incorrectLabel: UILabel?
    @IBOutlet weak var inRowLabel: UILabel?
    @IBOutlet weak var learned: UILabel?
    @IBOutlet weak var primaryPhrase: UITextField?
    @IBOutlet weak var learningPhrase: UITextField?
    @IBOutlet weak var modeLabel: UIBarButtonItem?
    @IBOutlet weak var deleteSaveButton: UIBarButtonItem?
    
    @IBAction func back(_ sender: Any) {
        dismiss(animated: true, completion: nil)
        
    }
    
    
    @IBAction func editPhrase() {
        if mode == "View" {
            enterEdit()
        } else if mode == "Edit" {
            updatePhrase()
            enterView()
        } else {
            print("The mode is out of range")
        }
    }
    
    @IBAction func saveDeleteButtonAction() {
        if mode == "View" {
            displayDeleteAlert()
        } else if mode == "Edit" {
            updatePhrase()
            enterView()
        } else {
            print("Error: The mode is not correct")
        }
    }
    
    @IBAction func resetAllCounts() {
       
        if phrase != nil{
            if let currentPhrase = phrase {
                displayResetAlert(phrase: currentPhrase)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        displayPhrase()
        
        if mode == "View"{
            modeLabel?.title = "Edit"
            deleteSaveButton?.title = "Delete"
        } else if mode == "Edit" {
            modeLabel?.title = "View"
            deleteSaveButton?.title = "Save"
        } else {
            print("Error: Mode is out of range")
        }
        
        primaryPhrase?.isUserInteractionEnabled = false
        learningPhrase?.isUserInteractionEnabled = false
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        ManagedData.saveContext()
    }
    
    func displayPhrase() {
        if let currentPhrase = phrase {
            primaryPhrase?.text = currentPhrase.english
            learningPhrase?.text = currentPhrase.french
            
            correctLabel?.text = String(currentPhrase.timesCorrect)
            incorrectLabel?.text = String(currentPhrase.timesIncorrect)
            inRowLabel?.text = String(currentPhrase.correctInARow)
            
            if currentPhrase.learned == true {
                learned?.text = "Learned!!"
            } else {
                learned?.text = "Not Learned"
            }
        }
    }
    
    
    func updatePhrase() {
        if phrase != nil {
            phrase?.english = primaryPhrase?.text
            phrase?.french = learningPhrase?.text
        }
    }

    
    func enterView() {
        mode = "View"
        modeLabel?.title = "Edit"
        deleteSaveButton?.title = "Delete"
        
        
        primaryPhrase?.isUserInteractionEnabled = false
        learningPhrase?.isUserInteractionEnabled = false
    }
    
    func enterEdit() {
        mode = "Edit"
        modeLabel?.title = "View"
        deleteSaveButton?.title = "Save"
        
        
        primaryPhrase?.isUserInteractionEnabled = true
        learningPhrase?.isUserInteractionEnabled = true
    }
    
    
    //MARK: - Alert methods
    func displayDeleteAlert () {
        if let currentPhrase = phrase {
            let alert = UIAlertController(title: "Are you sure?", message: "This will delete '\(currentPhrase.english ?? "No Phrase Selected")'", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: {action in self.didConfirmDeletePhrase()}))
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            
            self.present(alert, animated: true)
        }
    }
    
    func displayResetAlert (phrase: Phrases) {
        let alert = UIAlertController(title: "Reset Counts", message: "This will set the counts for '\(phrase.english ?? "No Phrase Selected")' back to 0, are you sure?", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: {action in self.didConfirmResetCounts()}))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        
        self.present(alert, animated: true)
    }
    
    func didConfirmDeletePhrase() {
        let context = ManagedData.persistentContainer.viewContext
        
        if let currentPhrase = phrase {
            context.delete(currentPhrase)
            returnsToList()
        }
    }
    
    func didConfirmResetCounts (){
        phrase!.resetCountPhraseCounts()
        displayPhrase()
    }
    
    func returnsToList () {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "PhraseListViewController")
        self.dismiss(animated: true, completion: nil)
        self.present(controller, animated: true, completion: nil)
    }
}

