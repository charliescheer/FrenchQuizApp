import UIKit
import CoreData

class PhraseQuizViewController: UIViewController {
 
    //MARK: - Class Properties
    var currentMode: String?
    var quizPair: Phrases?
    var savedMemory: [Phrases]? = []
    var quizCount = 0
    var quizState: Int = 0
    
    @IBOutlet weak var correctMessageLabel: UILabel!
    @IBOutlet weak var currentModeLabel: UILabel!
    @IBOutlet weak var currentQuizLabel: UILabel!
    @IBOutlet weak var answerTextField: UITextField!
    @IBOutlet weak var quizStateButton: UIBarButtonItem!
    
    
    
    //MARK: - View Controller Buttons
    @IBAction func backWasPressed(_ sender: Any) {
        let storyboard = UIStoryboard(name: constants.initialViewController, bundle: nil)
        let vc = storyboard.instantiateInitialViewController()
        present(vc!, animated: true, completion: nil)
    }
    
    
    @IBAction func quizMode() {
        guard let modeState = currentMode else {
            return
        }
        
        if modeState == mode.quiz {
            setModeToLearn()
            
        } else {
            setModeToQuiz()
        }

    }
    
    //trigger compare user answer and quiz answer from button on screen
    @IBAction func answerQuiz() {
        doTest()
    }

    //get new quiz pair
    @IBAction func newQuiz() {
        getQuizPair()
        correctMessageLabel.text = " "
    }
    
    //trigger compare user answer and quiz from enter button    
    @IBAction func enterWasPressed(_ sender: Any) {
        doTest()
    }
    
    
    //MARK: - View Functions and Core Data Manegment
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        guard let tempMode = currentMode else {
            return
        }
        
        if tempMode == "Quiz" {
            print("Quiz")
            setModeToQuiz()
        } else {
            print("Learn")
            setModeToLearn()
            
        }
        
        correctMessageLabel.text = " "
        
        
        getMemoryStore()
        
        if savedMemory!.count > 0 {
            getQuizPair()
        } else {
            currentQuizLabel.text = " "
            answerTextField.isUserInteractionEnabled = false
            displayNoAvailableQuizPairsAlert()
        }
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        ManagedData.saveContext()
    }

    //get data from core data
    func getMemoryStore() {
        let request: NSFetchRequest<Phrases> = Phrases.fetchRequest()
        var results = [Phrases]()
        
        do {
            results = try ManagedData.getContext().fetch(request)
            print(results.count)
        }
        catch {
            print(error)
        }
        
        for phrase in results {
            if phrase.learned == false {
                savedMemory?.append(phrase)
            }
        }
    }
    
    func setModeToQuiz() {
        currentModeLabel.text = mode.quiz
        quizStateButton.title = mode.learn
        currentMode = mode.quiz
    }
    
    func setModeToLearn() {
        currentModeLabel.text = mode.learn
        quizStateButton.title = mode.quiz
        currentMode = mode.learn
    }
    
    //MARK: - Quiz Setting Methods
    //choose a random pair of words from the memory store, make sure that pair is not already marked as learned.
    //also confirms that there are currently available unlearned pairs to check, if not displays an alert
    func getQuizPair() {
        guard let memory = savedMemory else {
            return
        }
        
        guard memory.count > 0 else {
            displayNoAvailableQuizPairsAlert()
            return
        }
        
        let randomIndex = Int(arc4random_uniform(UInt32(memory.count)))
        let newQuizPair = memory[randomIndex]
        quizState = Int(arc4random_uniform(2))
        
        print("The pair is \(String(describing: newQuizPair.frenchPhrase)) and \(String(describing: newQuizPair.englishPhrase))")
        quizPair = newQuizPair
        displayQuiz(newQuizPair)
        clearUserAnswer()
    }
    
    //display the currently selected quiz pair on screen
    func displayQuiz(_ currentPhrase: Phrases) {
        currentQuizLabel.text = currentPhrase.returnQuizQuestion(quizState: quizState) as String as String
    }
    
    func clearUserAnswer() {
        answerTextField.text = " "
    }
    
    
    // MARK: - Testing Functions
    
    //compare the user answer to the quiz
    //in quiz mode a correct or incorrect answer will trigger gaining and losing points towards marking a word as learned
    func doTest () {
        guard let quiz = quizPair else {
            return
        }
        
        if getUserAnswer() != "NO ANSWER" {
            let answer = getUserAnswer()
            compareCurrentAnswerWithQuiz(quiz: quiz, answer: answer, quizState: quizState)
        } else {
            displayNoAnswerAlert()
        }
        
    }
    
    //Get user answer from text field
    func getUserAnswer() -> String {
        var setAnswer: String = ""
        
        guard let userAnswer = answerTextField.text else {
            setAnswer = "NO ANSWER"
            return setAnswer
        }
        
        if userAnswer.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) != "" {
            setAnswer = userAnswer
            setAnswer = setAnswer.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            setAnswer = setAnswer.lowercased()
        } else {
            setAnswer = "NO ANSWER"
        }
        
        return setAnswer
    }
    
    func compareCurrentAnswerWithQuiz(quiz: Phrases, answer: String, quizState: Int) {
        //If the answer is Correct
        
        if quiz.compareUserAnswerToQuiz(quizState: quizState, userAnswer: answer) == 2 {
            displayCouldNotCompareAlert()
            
        } else if quiz.compareUserAnswerToQuiz(quizState: quizState, userAnswer: answer) == 1{
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
        correctMessageLabel.text = "Correct!!!"
        
        if currentMode == "Quiz" {
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
            correctMessageLabel.text = "Almost, Try again! Try # \(quizCount)"
            print(quizCount)
        } else {
            correctMessageLabel.text = "So close! The answer was: \(quiz.returnQuizAnswer(quizState: quizState))"
            getQuizPair()
            quizCount = 0
        }
    }
    
    func compareIsWrong(quiz: Phrases, quizState: Int) {
        if quizCount < 4 {
            quizCount += 1
            correctMessageLabel.text = "Incorrect :/ Try # \(quizCount)"
            print(quizCount)
        } else {
            if currentMode == "Quiz" {
                quizPair?.resetCountPhraseCounts()
                quizPair?.addPointToPhraseIncorrectCount()
            }
            
            print("Count reset")
            correctMessageLabel.text = "Incorrect, the answer was: \(quiz.returnQuizAnswer(quizState: quizState))"
            
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
    
    func displayCouldNotCompareAlert () {
        let alert = UIAlertController(title: "Phrase Error", message: "An error has occured.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Okay", style: .cancel, handler: nil))
        self.present(alert, animated: true)
    }
    
    
}

extension PhraseQuizViewController {
    enum constants {
        static let initialViewController = "Intro"
    }
    
    enum mode  {
        static let quiz = "Quiz"
        static let learn = "Learn"
    }
}



