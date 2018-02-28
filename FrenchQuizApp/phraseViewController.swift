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
    var quizCount = 0
    
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
    
    func showCorrectMessage() {
        message = "Correct!!"
        correctMessage.text = message
    }
    
    func doTest() {
        switch mode {
        case "Review":
            doReview()
        case "Quiz":
            doQuiz()
        default:
            print("The mode is out of range")
        }
    }
    
    func doQuiz () {
        //get user answer
        userAnswer = getUserAnswer()
        
        //compare user answer and quiz answer to return a percent correct
        let percentCorrect = percentageCompare(quizAnswer: quizAnswer, userAnswer: userAnswer)
        
        //respond to the percentage correct
        //if 100% correct
        if percentCorrect ==  1 {
            showCorrectMessage()
            quizPair!.addPoint()
            print(quizPair!.timesCorrect)
            getQuizPair()
            quizCount = 0
            //if 85% or more
        } else if percentCorrect > 0.85 {
            if quizCount < 4 {
                quizCount += 1
                correctMessage.text = "Almost, Try again! Try # \(quizCount)"
                print(quizCount)
            } else {
                correctMessage.text = "So close! The answer was: \(quizAnswer!)"
                getQuizPair()
                quizCount = 0
            }
            //if less then 85% correct
        } else {
            if quizCount < 4 {
                message = "Incorrect :/"
                quizCount += 1
                correctMessage.text = "Incorrect :/ Try # \(quizCount)"
                print(quizCount)
            } else {
                quizPair?.resetCount()
                quizPair?.takePoint()
                print("Count reset")
                correctMessage.text = "Incorrect, the answer was: \(quizAnswer!)"
                getQuizPair()
                quizCount = 0
            }
            
            
        }
    }
    
    func doReview () {
        //get user answer
        userAnswer = getUserAnswer()
        
        //compare user answer and quiz answer to return a percent correct
        let percentCorrect = percentageCompare(quizAnswer: quizAnswer, userAnswer: userAnswer)
        
        //respond to the percentage correct
        //if 100% correct
        if percentCorrect ==  1 {
            showCorrectMessage()
            quizPair!.addPoint()
            print(quizPair!.timesCorrect)
            getQuizPair()
            quizCount = 0
            //if 85% or more
        } else if percentCorrect > 0.85 {
            if quizCount < 4 {
                quizCount += 1
                correctMessage.text = "Almost, Try again! Try # \(quizCount)"
                print(quizCount)
            } else {
                correctMessage.text = "So close! The answer was: \(quizAnswer!)"
                getQuizPair()
                quizCount = 0
            }
            //if less then 85% correct
        } else {
            if quizCount < 4 {
                message = "Incorrect :/"
                quizCount += 1
                correctMessage.text = "Incorrect :/ Try # \(quizCount)"
                print(quizCount)
            } else {
                print("Count reset")
                correctMessage.text = "Incorrect, the answer was: \(quizAnswer!)"
                getQuizPair()
                quizCount = 0
            }
            
            
        }
    }
    
    
    func LDCompare(quizAnswer: String?, userAnswer: String?) -> Int {
        var result: Int = 0
        if let answer = quizAnswer {
            if let user = userAnswer {
                result = Tools.levenshtein(aStr: answer, bStr: user)
                print(answer)
                print(user)
                print("LD distance number \(result)")
            }
        }
        
        return result
    }
    
    func percentageCompare (quizAnswer: String?, userAnswer: String?) -> Double {
        var result: Double = 0.00
        if let answer = quizAnswer {
            if let user = userAnswer {
                let ldDisatance = Double(LDCompare(quizAnswer: answer, userAnswer: user))
                let answerLength = Double(answer.count)
                result = (answerLength - ldDisatance) / answerLength
                print("percent result \(result)")
            }}
        return result
    }
    

}
