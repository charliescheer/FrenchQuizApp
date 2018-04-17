import UIKit
import CoreData

class phraseEditView: UIViewController {
    
    var phrase: Phrases?
    var mode = "View"
    
    let appDelegate = UIApplication.shared.delegate as? AppDelegate
    
    
    @IBOutlet weak var correctLabel: UILabel?
    @IBOutlet weak var incorrectLabel: UILabel?
    @IBOutlet weak var inRowLabel: UILabel?
    @IBOutlet weak var learned: UILabel?
    @IBOutlet weak var primaryPhrase: UITextField?
    @IBOutlet weak var learningPhrase: UITextField?
    @IBOutlet weak var modeLabel: UIBarButtonItem?
    @IBOutlet weak var deleteSaveButton: UIBarButtonItem?
    
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
            deleteAlert()
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
                resetAlert(phrase: currentPhrase)
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
        appDelegate?.saveContext()
    }
    
    func resetCounts() {
        phrase?.timesCorrect = 0
        phrase?.timesIncorrect = 0
        phrase?.correctInARow = 0
        phrase?.learned = false
        
        displayPhrase()
    }
    
    func displayPhrase() {
        if let currentPhrase = phrase {
            primaryPhrase?.text = currentPhrase.primaryLanguage
            learningPhrase?.text = currentPhrase.learningLanguage
            
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
            phrase?.primaryLanguage = primaryPhrase?.text
            phrase?.learningLanguage = learningPhrase?.text
            
            appDelegate?.saveContext()
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
    
    func deletePhrase() {
        let context = appDelegate?.persistentContainer.viewContext

        if let currentPhrase = phrase {
            if let currentContext = context {
                currentContext.delete(currentPhrase)
                returnsToList()
          
            }
        }
    }
    
    func returnsToList () {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "PhraseListViewController")
        self.dismiss(animated: true, completion: nil)
        self.present(controller, animated: true, completion: nil)
    }
    
    //Alert methods
    func deleteAlert () {
        if let currentPhrase = phrase {
            let alert = UIAlertController(title: "Are you sure?", message: "This will delete '\(currentPhrase.primaryLanguage ?? "No Phrase Selected")'", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: {action in self.deletePhrase()}))
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            
            self.present(alert, animated: true)
        }
    }
    
    func resetAlert (phrase: Phrases) {
        let alert = UIAlertController(title: "Reset Counts", message: "This will set the counts for '\(phrase.primaryLanguage ?? "No Phrase Selected")' back to 0, are you sure?", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: {action in self.resetCounts()}))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        
        self.present(alert, animated: true)
    }
}

