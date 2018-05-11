import UIKit
import CoreData

class PhraseQuizViewController: UIViewController, UITextFieldDelegate {
 
    //MARK: - Class Properties
    var mode: String = "Quiz"
    var quizPair: Phrases?
    var savedMemory: [Phrases]? = []
    var quizCount = 0
    var quizState: Int = 0
    
    @IBOutlet weak var correctMessage: UILabel!
    @IBOutlet weak var currentMode: UILabel!
    @IBOutlet weak var currentQuiz: UILabel!
    @IBOutlet weak var answer: UITextField!
    
    
    
    //MARK: - View Controller Buttons
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
    

    
    //MARK: - View Functions and Core Data Manegment
    override func viewDidLoad() {
        super.viewDidLoad()
        
        correctMessage.text = " "
        currentMode.text = mode
        
        getMemoryStore()
        if savedMemory!.count > 0 {
            getQuizPair()
        } else {
            currentQuiz.text = " "
            answer.isUserInteractionEnabled = false
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        managedData.saveContext()
    }

    //get data from core data
    func getMemoryStore() {
        let request: NSFetchRequest<Phrases> = Phrases.fetchRequest()
        var results = [Phrases]()
        
        do {
            results = try managedData.getContext().fetch(request)
            print(results.count)
        }
        catch {
            print(error)
        }

        savedMemory = results
    }
    
    //MARK: - Quiz Setting Methods
    //choose a random pair of words from the memory store, make sure that pair is not already marked as learned.
    //also confirms that there are currently available unlearned pairs to check, if not displays an alert
    func getQuizPair() {
        if let memory = savedMemory {
            if memory.count > 0 {
                let randomIndex = Int(arc4random_uniform(UInt32(memory.count)))
                let newQuizPair = memory[randomIndex]
                quizState = Int(arc4random_uniform(2))
                
                //if there are available pairs, looks for a random one marked as unlearned and returns it to the view
                if arePairsAvailable() == true && newQuizPair.learned == false {
                    print("The pair is \(String(describing: newQuizPair.frenchPhrase)) and \(String(describing: newQuizPair.englishPhrase))")
                    quizPair = newQuizPair
                    displayQuiz(newQuizPair)
                    clearUserAnswer()
                } else {
                    self.getQuizPair()
                }
            } else {
                displayNoAvailableQuizPairsAlert()
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
        currentQuiz.text = currentPhrase.returnQuizQuestion(quizState: quizState) as String as String
    }
    
    func clearUserAnswer() {
        answer.text = " "
    }
    
    
    // MARK: - Testing Functions
    
    //compare the user answer to the quiz
    //in quiz mode a correct or incorrect answer will trigger gaining and losing points towards marking a word as learned
    func doTest () {
        if let quiz = quizPair {
            if getUserAnswer() != "NO ANSWER" {
                let answer = getUserAnswer()
                compare(quiz: quiz, answer: answer, quizState: quizState)
            } else {
                displayNoAnswerAlert()
            }
        }
    }
    
    //Get user answer from text field
    func getUserAnswer() -> String {
        var setAnswer: String = ""
        if let userAnswer = answer.text {
            if userAnswer.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) != "" {
                setAnswer = userAnswer
                
                setAnswer = setAnswer.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                setAnswer = setAnswer.lowercased()
                print("inside getUserAnswer \(setAnswer)")
                } else {
                    setAnswer = "NO ANSWER"
                    print(setAnswer)
                }
            }
        
            
        return setAnswer
    }
    
    func compare(quiz: Phrases, answer: String, quizState: Int) {
        //If the answer is Correct
        if quiz.compareUserAnswerToQuiz(quizState: quizState, userAnswer: answer) == 1{
            compareIsCorrect()
            
            //If the answer is close
        } else if quiz.compareUserAnswerToQuiz(quizState: quizState, userAnswer: answer) > 0.85 {
            compareIsclose(quiz: quiz, quizState: quizState)
            
            //if less then 85% correct
        } else {
            compareIsWrong(quiz: quiz, quizState: quizState)
        }
    }
    
    func compareIsCorrect() {
        correctMessage.text = "Correct!!!"
        
        if mode == "Quiz" {
            quizPair?.addPointtoPhraseCorrectCount()
        }
        
        if quizPair!.learned == true && quizPair!.correctInARow == 10 {
            displayLearnedAlert()
        }
        
        getQuizPair()
    }
    
    func compareIsclose(quiz: Phrases, quizState: Int) {
        if quizCount < 4 {
            quizCount += 1
            correctMessage.text = "Almost, Try again! Try # \(quizCount)"
            print(quizCount)
        } else {
            correctMessage.text = "So close! The answer was: \(quiz.returnQuizAnswer(quizState: quizState))"
            getQuizPair()
            quizCount = 0
        }
    }
    
    func compareIsWrong(quiz: Phrases, quizState: Int) {
        if quizCount < 4 {
            quizCount += 1
            correctMessage.text = "Incorrect :/ Try # \(quizCount)"
            print(quizCount)
        } else {
            if mode == "Quiz" {
                quizPair?.resetCountPhraseCounts()
                quizPair?.addPointToPhraseIncorrectCount()
            }
            
            print("Count reset")
            correctMessage.text = "Incorrect, the answer was: \(quiz.returnQuizAnswer(quizState: quizState))"
            
            getQuizPair()
            quizCount = 0
        }
    }
    

    //MARK: - Alert Functions
    func displayNoAnswerAlert () {
        let alert = UIAlertController(title: "No Answer", message: "Please enter an answer.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Okay", style: .cancel, handler: nil))
        self.present(alert, animated: true)
    }
    
    func displayNoAvailableQuizPairsAlert () {
        let alert = UIAlertController(title: "There are no available phrase pairs", message: "Please add more phrases to learn!", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
        self.present(alert, animated: true)
    }
    
    func displayLearnedAlert () {
        let alert = UIAlertController(title: "Learned!", message: "You've gotten \(quizPair!.englishPhrase ?? "No Phrase Selected") correct 10 times in a row", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Okay", style: .cancel, handler: nil))
        self.present(alert, animated: true)
    }
    
}

