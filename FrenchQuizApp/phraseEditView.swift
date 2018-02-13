import UIKit
import CoreData

class phraseEditView: UIViewController {
    
    var phrase: Phrases?
    var mode = "View"
    
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
            phrase?.timesCorrect = 0
            phrase?.timesIncorrect = 0
            phrase?.correctInARow = 0
            phrase?.learned = false
        }
        
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
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
                return
            }
            
            let context = appDelegate.persistentContainer.viewContext
            

            phrase?.english = englishPhrase?.text
            phrase?.french = frenchPhrase?.text
            
            do {
                try context.save()
            } catch {
                fatalError("failure")
            }
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
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let context = appDelegate.persistentContainer.viewContext

        if let currentPhrase = phrase {
        context.delete(currentPhrase)
        
            do {
                try context.save()
            } catch {
                fatalError("failure")
                }
        }
    }
}

