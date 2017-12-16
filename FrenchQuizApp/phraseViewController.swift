import UIKit
import CoreData

class phraseViewController: UIViewController {
 
    //Start Class Properties
    var userAnswer: String?
    var mode: String = "Review"
    var message: String = " "
    var frenchPhrase: String?
    var englishPhrase: String?
    var quizAnswer: String?
    var quizPair: Phrases?
    
    @IBOutlet weak var correctMessage: UILabel!
    @IBOutlet weak var currentMode: UILabel!
    @IBOutlet weak var currentQuiz: UILabel!
    @IBOutlet weak var answer: UITextField!
    
    //Start View Controller Buttons
    @IBAction func reviewMode() {
        mode = "Review"
        currentMode.text = mode
    }
    
    @IBAction func learnMode() {
        mode = "Learn"
        currentMode.text = mode
    }
    
    @IBAction func quizMode() {
        mode = "Quiz"
        currentMode.text = mode
    }
    
    @IBAction func answerQuiz() {
        userAnswer = getUserAnswer()
        if compareAnswer(quizAnswer: quizAnswer, userAnswer: userAnswer, quizPair: quizPair) == true {
            print("true")
            showCorrectMessage()
            quizPair = getQuizPair()
        }
    }
    
    @IBAction func newQuiz() {
        quizPair = getQuizPair()
        if let quiz = quizPair {
            displayQuiz(quiz)
        }
        correctMessage.text = " "
        
    }
    
//Starter Functions and Core Data Manegment
    override func viewDidLoad() {
        super.viewDidLoad()
        correctMessage.text = " "
        quizPair = getQuizPair()
        
        if let quiz = quizPair {
            displayQuiz(quiz)
        }
        
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
    func getQuizPair() -> Phrases? {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Phrases")
        var results = [Phrases]()
        
        guard results.count >= 0 else {
        do {
            results = try managedObjectContext.fetch(request) as! [Phrases]
            
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
        let randomIndex = Int(arc4random_uniform(UInt32(results.count)))
        let currentPhrase = results[randomIndex]
    
        print("The current quiz pair is \(currentPhrase.french ?? "empty") and \(currentPhrase.english ?? "empty")")
        return currentPhrase
        }
        
        return nil
    }

    func displayQuiz(_ currentPhrase: Phrases) {
        //Displays the current quiz question
        
        if let currentPhrase = quizPair {
            frenchPhrase = currentPhrase.french
            englishPhrase = currentPhrase.english
            
            let randomNumber = Int(arc4random_uniform(UInt32(1)))
            
            switch randomNumber {
            case 0:
                currentQuiz.text = frenchPhrase
                quizAnswer = englishPhrase
                print("the random number was \(randomNumber)")
            default:
                currentQuiz.text = englishPhrase
                quizAnswer = frenchPhrase
                print("the random number was \(randomNumber)")
            }
            
        }
    }
    
    func getUserAnswer() -> String {
        //needs some work.  Should add some error catching insteadof the current solution.
        
        var setAnswer: String?
        
        setAnswer = answer.text
        
        if let a = setAnswer {
            return a
        } else {return "No ANSWER"}
    }
    
    func compareAnswer (quizAnswer: String?, userAnswer: String?, quizPair: Phrases?) -> Bool {
        //gets the clues for the current quiz and compares them to the user answer
        var correct: Bool = false
        
        if let currentQuiz = quizAnswer {
            if let currentAnswer = answer.text {
        
            if currentAnswer == currentQuiz{
                if let pair = quizPair {
                    pair.addPoint()
                }
                showCorrectMessage()
                print("The answers are the same")
                correct = true
            } else {
                if let pair = quizPair {
                    pair.resetCount()
                }
                
                message = "Incorrect :/"
                print("The answers are not the same")
                
            }
            }
        }
        return correct
    }
    
    func showCorrectMessage() {
        message = "Correct!!"
        correctMessage.text = message
    }
    
}
