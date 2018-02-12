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
    
    @IBAction func editPhrase() {
        if mode == "View" {
            mode = "Edit"
            unlockPhrase()
            
        } else if mode == "Edit" {
            lockPhrase()
        } else {
            print("The mode is not correct")
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
        lockPhrase()
        displayPhrase()
        
        
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
    
    func lockPhrase() {
        englishPhrase?.isUserInteractionEnabled = false
        frenchPhrase?.isUserInteractionEnabled = false
    }
    
    func unlockPhrase() {
        englishPhrase?.isUserInteractionEnabled = true
        frenchPhrase?.isUserInteractionEnabled = true
    }
}

