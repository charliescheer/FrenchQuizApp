import UIKit
import CoreData

class phraseViewController: UIViewController, UITextFieldDelegate {
 
    //Start Class Properties
    var userAnswer: String?
    var mode: String = "Quiz"
    var message: String = " "
    var learningPhrase: String?
    var primaryPhrase: String?
    var quizAnswer: String?
    var quizPair: Phrases?
    var savedMemory: [Phrases]? = []
    var quizCount = 0
    
    @IBOutlet weak var correctMessage: UILabel!
    @IBOutlet weak var currentMode: UILabel!
    @IBOutlet weak var currentQuiz: UILabel!
    @IBOutlet weak var answer: UITextField!
    
    //Start View Controller Buttons

    
 //learn mode has been removed from scope, function and button on GUI need to be removed
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

//trigger compare user answer and quiz answer from button on screen
    @IBAction func answerQuiz() {
        doTest()
    }

//get new quiz pair
    @IBAction func newQuiz() {
        getQuizPair()

        correctMessage.text = " "
        
    }
    
//trigger compare user answer and quiz from enter button
    @IBAction func textFieldPrimaryActionTriggered(_ sender: Any) {
        doTest()
        
    }
    
//Starter Functions and Core Data Manegment
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        correctMessage.text = " "
        getMemoryStore()
        getQuizPair()

        mode = "Quiz"
        currentMode.text = mode
    }

//get data from core data
    var managedObjectContext: NSManagedObjectContext {
        get {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            return appDelegate.persistentContainer.viewContext
        }
    }
    
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
    
//active functions
    
//choose a random pair of words from the memory store, make sure that pair is not already marked as learned.
//also confirms that there are currently available unlearned pairs to check, if not displays an alert
    func getQuizPair() {
        if let memory = savedMemory {
            if memory.count >= 0 {
                let randomIndex = Int(arc4random_uniform(UInt32(memory.count)))
                let newQuizPair = memory[randomIndex]
                let available = arePairsAvailable()

                
                //if there are available pairs, looks for a random one marked as unlearned and returns it to the view
                if available == true {
                    if newQuizPair.learned == false {
                        newQuizPair.learningLanguage = newQuizPair.learningLanguage?.lowercased()
                        newQuizPair.primaryLanguage = newQuizPair.primaryLanguage?.lowercased()
                        print("The pair is \(String(describing: newQuizPair.learningLanguage)) and \(String(describing: newQuizPair.primaryLanguage))")
                        quizPair = newQuizPair
                        displayQuiz(newQuizPair)
                        answer.text = ""
                    } else {
                        self.getQuizPair()
                    }
                } else {
                    let alert = UIAlertController(title: "There are no available phrase pairs", message: "Please add more phrases to learn!", preferredStyle: .alert)
                    
                    alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
                    
                    self.present(alert, animated: true)
                }
            }
        }
    }
    
    func arePairsAvailable() -> Bool {
        var pairsAreAvailable: Bool = false
        
        if let memory = savedMemory {
            if memory.count >= 0 {
                
                for pair in memory {
                    if pair.learned == false {
                        pairsAreAvailable = true
                        break
                    }
                }
            }
        }
        return pairsAreAvailable
    }

//display the currently selected quiz pair on screen
    func displayQuiz(_ currentPhrase: Phrases) {
        //Displays the current quiz question
        
            learningPhrase = currentPhrase.learningLanguage
            primaryPhrase = currentPhrase.primaryLanguage
            
            let randomNumber = Int(arc4random_uniform(2))
            print("the random number was \(randomNumber)")
            
            switch randomNumber {
            case 0:
                currentQuiz.text = learningPhrase
                quizAnswer = primaryPhrase
            default:
                currentQuiz.text = primaryPhrase
                quizAnswer = learningPhrase
            }
            
        }

//Get user answer from text field
    func getUserAnswer() -> String {
        //needs some work.  Should add some error catching insteadof the current solution.
        
        var setAnswer: String?
        
        setAnswer = answer.text
        setAnswer = setAnswer?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        
        if let a = setAnswer?.lowercased() {
            return a
        } else {return "No ANSWER"}
    }
    
//Feedback to user for answering a message correctly.
    func showCorrectMessage() {
        message = "Correct!!"
        correctMessage.text = message
    }
    
//Trigger the correct test depending on the mode the app is in
    func doTest() {
        switch mode {
        case "Learn":
            doReview()
        case "Quiz":
            doQuiz()
        default:
            print("The mode is out of range")
        }
    }
    
//compare the user answer to the quiz
//in quiz mode a correct or incorrect answer will trigger gaining and losing points towards marking a word as learned
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
        
            if quizPair!.learned == true && quizPair!.correctInARow == 10 {
                let alert = UIAlertController(title: "Learned!", message: "You've gotten \(quizPair!.primaryLanguage ?? "No Phrase Selected") correct 10 times in a row", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Okay", style: .cancel, handler: nil))
                self.present(alert, animated: true)
            }
            
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
    
    
//compare the user answer to the quiz
//in review mode a correct or incorrect answer will NOT trigger gaining and losing points towards marking a word as learned
    func doReview () {
        //get user answer
        userAnswer = getUserAnswer()
        
        //compare user answer and quiz answer to return a percent correct
        let percentCorrect = percentageCompare(quizAnswer: quizAnswer, userAnswer: userAnswer)
        
        //respond to the percentage correct
        //if 100% correct
        if percentCorrect ==  1 {
            showCorrectMessage()
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
    
    
//Levenshein distance comparing the user answer and quiz
//Returns an int of the number of steps to make one string the same as the other
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
    
//uses the results from the LDcompare to create a percentage difference between the user and quiz answers
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
