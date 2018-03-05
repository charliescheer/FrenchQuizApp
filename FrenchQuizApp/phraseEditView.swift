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
    @IBOutlet weak var englishPhrase: UITextField?
    @IBOutlet weak var frenchPhrase: UITextField?
    @IBOutlet weak var modeLabel: UIBarButtonItem?
    @IBOutlet weak var deleteSaveButton: UIBarButtonItem?
    
    @IBAction func editPhrase() {
        if mode == "View" {
            enterEdit()

        } else if mode == "Edit" {
            updatePhrase()
            enterView()

        } else {
            print("The mode is not correct")
        }
    }
    
    @IBAction func saveDeleteButtonAction() {
        if mode == "View" {
            deletePhrase()
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
                let alert = UIAlertController(title: "Reset Counts", message: "This will set the counts for '\(currentPhrase.english ?? "No Phrase Selected")' back to 0, are you sure?", preferredStyle: .alert)
                
                alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: {action in self.resetCounts()}))
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                
                
                self.present(alert, animated: true)
            }
        }
        
        
    }
    
    func resetCounts() {
        phrase?.timesCorrect = 0
        phrase?.timesIncorrect = 0
        phrase?.correctInARow = 0
        phrase?.learned = false
        
        displayPhrase()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        displayPhrase()
        
        if mode == "View"{
            modeLabel?.title = "Edit"
            deleteSaveButton?.title = "Delete"
            englishPhrase?.isUserInteractionEnabled = false
            frenchPhrase?.isUserInteractionEnabled = false
        } else if mode == "Edit" {
            modeLabel?.title = "View"
            deleteSaveButton?.title = "Save"
            englishPhrase?.isUserInteractionEnabled = true
            frenchPhrase?.isUserInteractionEnabled = true
        } else {
            print("Error: Mode is out of range")
        }
        
        englishPhrase?.isUserInteractionEnabled = false
        frenchPhrase?.isUserInteractionEnabled = false
    }
    
    func displayPhrase() {
        if let currentPhrase = phrase {
            englishPhrase?.text = currentPhrase.english
            frenchPhrase?.text = currentPhrase.french
            
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
            phrase?.english = englishPhrase?.text
            phrase?.french = frenchPhrase?.text
            
            appDelegate?.saveContext()
        }
    }
    

    
    func enterView() {
        mode = "View"
        modeLabel?.title = "Edit"
        deleteSaveButton?.title = "Delete"
        
        
        englishPhrase?.isUserInteractionEnabled = false
        frenchPhrase?.isUserInteractionEnabled = false
    }
    
    func enterEdit() {
        mode = "Edit"
        modeLabel?.title = "View"
        deleteSaveButton?.title = "Save"
        
        
        englishPhrase?.isUserInteractionEnabled = true
        frenchPhrase?.isUserInteractionEnabled = true
    }
    
    func deletePhrase() {
        let context = appDelegate?.persistentContainer.viewContext

        if let currentPhrase = phrase {
            if let currentContext = context {
                currentContext.delete(currentPhrase)
                appDelegate?.saveContext()
            }
        }
    }

}

