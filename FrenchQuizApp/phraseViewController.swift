import UIKit
import CoreData

class phraseViewController: UIViewController, UITextFieldDelegate {
 
    //Start Class Properties
    var userAnswer: String?
    var mode: String = "Review"
    var message: String = " "
    var frenchPhrase: String?
    var englishPhrase: String?
    var quizAnswer: String?
    var quizPair: Phrases?
    var savedMemory: [Phrases]? = []
    
    @IBOutlet weak var correctMessage: UILabel!
    @IBOutlet weak var currentMode: UILabel!
    @IBOutlet weak var currentQuiz: UILabel!
    @IBOutlet weak var answer: UITextField!
    
    //Start View Controller Buttons
    @IBAction func reviewMode() {
        mode = "Review"
        currentMode.text = mode
        print(mode)
    }
    
    @IBAction func learnMode() {
        mode = "Learn"
        currentMode.text = mode
        print(mode)
    }
    
    @IBAction func quizMode() {
        mode = "Quiz"
        currentMode.text = mode
        print(mode)
    }
    
    @IBAction func answerQuiz() {
        userAnswer = getUserAnswer()
        doTest()
    }
    
    @IBAction func newQuiz() {
        getQuizPair()

        correctMessage.text = " "
        
    }
    
    
    @IBAction func textFieldPrimaryActionTriggered(_ sender: Any) {
        userAnswer = getUserAnswer()
        doTest()
    }
    
    //Starter Functions and Core Data Manegment
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        correctMessage.text = " "
        getMemoryStore()
        getQuizPair()

        mode = "Review"
        currentMode.text = mode
    }

    
    var managedObjectContext: NSManagedObjectContext {
        get {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            return appDelegate.persistentContainer.viewContext
        }
    }
    


//Active Functions
    
    func getMemoryStore() {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Phrases")
        var results = [Phrases]()
        
        do {
            results = try managedObjectContext.fetch(request) as! [Phrases]
            } catch let error as NSError {
                print("Could not fetch \(error), \(error.userInfo)")
            }
        savedMemory = results
    }
    
    func getQuizPair() {
        if let memory = savedMemory {
            if memory.count >= 0 {
                let randomIndex = Int(arc4random_uniform(UInt32(memory.count)))
                let newQuizPair = memory[randomIndex]
                
                newQuizPair.french = newQuizPair.french?.lowercased()
                newQuizPair.english = newQuizPair.english?.lowercased()
                print("The pair is \(String(describing: newQuizPair.french)) and \(String(describing: newQuizPair.english))")
                quizPair = newQuizPair
                displayQuiz(newQuizPair)
            }
        }
    }

    func displayQuiz(_ currentPhrase: Phrases) {
        //Displays the current quiz question
        
            frenchPhrase = currentPhrase.french
            englishPhrase = currentPhrase.english
            
            let randomNumber = Int(arc4random_uniform(2))
            print("the random number was \(randomNumber)")
            
            switch randomNumber {
            case 0:
                currentQuiz.text = frenchPhrase
                quizAnswer = englishPhrase
            default:
                currentQuiz.text = englishPhrase
                quizAnswer = frenchPhrase
            }
            
        }
    
    func getUserAnswer() -> String {
        //needs some work.  Should add some error catching insteadof the current solution.
        
        var setAnswer: String?
        
        setAnswer = answer.text
        
        if let a = setAnswer?.lowercased() {
            return a
        } else {return "No ANSWER"}
    }
    
    func compareAnswer (quizAnswer: String?, userAnswer: String?, quizPair: Phrases?) -> Bool {
        //gets the clues for the current quiz and compares them to the user answer
        var correct: Bool = false
        
        if let currentQuiz = quizAnswer {
        
            if userAnswer == currentQuiz{
                print("The answers are the same")
                correct = true
                answer.text = ""
            } else {
                message = "Incorrect :/"
                print("The answers are not the same")
            }
            
        }
        return correct
    }
    
    func showCorrectMessage() {
        message = "Correct!!"
        correctMessage.text = message
    }
    
    func doTest() {
        userAnswer = getUserAnswer()
        switch mode {
        case "Review":
            if compareAnswer(quizAnswer: quizAnswer, userAnswer: userAnswer, quizPair: quizPair) == true {
                print("true")
                showCorrectMessage()
                getQuizPair()
            }
        case "Learn":
            if compareAnswer(quizAnswer: quizAnswer, userAnswer: userAnswer, quizPair: quizPair) == true {
                print("true")
                showCorrectMessage()
                getQuizPair()
            }
        case "Quiz":
            if compareAnswer(quizAnswer: quizAnswer, userAnswer: userAnswer, quizPair: quizPair) == true {
                print("true")
                print("quiz")
                showCorrectMessage()
                quizPair!.addPoint()
                print(quizPair!.timesCorrect)
                getQuizPair()
                
            } else {
                    quizPair?.resetCount()
                    print("Count reset")
            }
        default:
            print("error: mode out of range")
        }
    }
    
}
