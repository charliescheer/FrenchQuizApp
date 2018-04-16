import UIKit
import CoreData

class phraseViewController: UIViewController, UITextFieldDelegate {
 
    //Start Class Properties
    
    //should the variable Mode be something other then a string?
    var mode: String = "Quiz"
    var quizPair: Phrases?
    var savedMemory: [Phrases]? = []
    var quizCount = 0
    var quizState: Int = 0
    let appDelegate = UIApplication.shared.delegate as? AppDelegate
    
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
        if savedMemory!.count > 0 {
            getQuizPair()
        } else {
            currentQuiz.text = " "
            answer.isUserInteractionEnabled = false
        }
        currentMode.text = mode
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        appDelegate?.saveContext()
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
            if memory.count > 0 {
                let randomIndex = Int(arc4random_uniform(UInt32(memory.count)))
                let newQuizPair = memory[randomIndex]
                quizState = Int(arc4random_uniform(2))

                //if there are available pairs, looks for a random one marked as unlearned and returns it to the view
                if arePairsAvailable() == true {
                    if newQuizPair.learned == false {
                        print("The pair is \(String(describing: newQuizPair.learningLanguage)) and \(String(describing: newQuizPair.primaryLanguage))")
                        quizPair = newQuizPair
                        displayQuiz(newQuizPair)
                        clearUserAnswer()
                    } else {
                        self.getQuizPair()
                    }
                } else {
                    NoAvailableQuizPairsAlert()
                }
            }
        }
    }
    
    //compare the user answer to the quiz
    //in quiz mode a correct or incorrect answer will trigger gaining and losing points towards marking a word as learned
    func doTest () {
        if let quiz = quizPair {
            if getUserAnswer() != "No ANSWER" {
                let answer = getUserAnswer()
                
                //If the answer is Correct
                if quiz.doCompare(quizState: quizState, userAnswer: answer) == 1{
                    correctMessage.text = "Correct!!!"
                    
                    if mode == "Quiz" {
                        quizPair?.addPoint()
                    }
                    
                    if quizPair!.learned == true && quizPair!.correctInARow == 10 {
                        learnedAlert()
                    }
                    
                    getQuizPair()
                    
                //If the answer is close
                } else if quiz.doCompare(quizState: quizState, userAnswer: answer) > 0.85 {
                    if quizCount < 4 {
                        quizCount += 1
                        correctMessage.text = "Almost, Try again! Try # \(quizCount)"
                        print(quizCount)
                    } else {
                        correctMessage.text = "So close! The answer was: \(quiz.returnAnswer(quizState: quizState))"
                        getQuizPair()
                        quizCount = 0
                    }
                    
                //if less then 85% correct
                } else {
                    if quizCount < 4 {
                        quizCount += 1
                        correctMessage.text = "Incorrect :/ Try # \(quizCount)"
                        print(quizCount)
                    } else {
                        if mode == "Quiz" {
                            quizPair?.resetCount()
                            quizPair?.takePoint()
                        }
                        
                        print("Count reset")
                        correctMessage.text = "Incorrect, the answer was: \(quiz.returnAnswer(quizState: quizState))"
                        
                        getQuizPair()
                        quizCount = 0
                    }
                }
                
            //If the user answer field was blank
            } else {
                noAnswerAlert()
            }
            
        }
    }
    
    //Check to make sure there are phrases stored in memory
    func arePairsAvailable() -> Bool {
        var pairsAreAvailable: Bool = false
        
        if let memory = savedMemory {
            if memory.count > 0 {
                
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
            currentQuiz.text = currentPhrase.returnQuiz(quizState: quizState)
        }

//Get user answer from text field
    func getUserAnswer() -> String {
        if let userAnswer = answer.text {
            var setAnswer: String = userAnswer
        
            setAnswer = setAnswer.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            setAnswer = setAnswer.lowercased()
            
            return setAnswer
            
            } else {return "No ANSWER"}
        }


    func clearUserAnswer() {
        answer.text = " "
    }

//Alert Functions
    func noAnswerAlert () {
        let alert = UIAlertController(title: "No Answer", message: "Please enter an answer.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Okay", style: .cancel, handler: nil))
        self.present(alert, animated: true)
    }
    
    func NoAvailableQuizPairsAlert () {
        let alert = UIAlertController(title: "There are no available phrase pairs", message: "Please add more phrases to learn!", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
        self.present(alert, animated: true)
    }
    
    func learnedAlert () {
        let alert = UIAlertController(title: "Learned!", message: "You've gotten \(quizPair!.primaryLanguage ?? "No Phrase Selected") correct 10 times in a row", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Okay", style: .cancel, handler: nil))
        self.present(alert, animated: true)
    }

}
