import UIKit
import CoreData

class NounQuizViewController: UIViewController {
    
    var currentMode : String?
    var quizPair: Nouns?
    var savedMemory: [Nouns]? = []
    var quizCount = 1
    var quizState: Int = 0
    
    
    @IBOutlet weak var currentModeLabel: UILabel!
    @IBOutlet weak var currentQuizLabel: UILabel!
    @IBOutlet weak var userAnswerTextField: UITextField!
    @IBOutlet weak var quizButton: UIBarButtonItem!
    @IBOutlet weak var quizStateButton: UIBarButtonItem!
    @IBOutlet weak var correctMessageLabel: UILabel!
    @IBOutlet weak var genderSwitch: UISwitch!
    
    
    @IBAction func quizButtonWasPressed(_ sender: Any) {
        guard let modeState = currentMode else {
            return
        }
        
        if modeState == mode.quiz {
            setModeToLearn()
        } else {
            setModeToQuiz()
        }
    }
    
    @IBAction func newQuizButtonWasPressed(_ sender: Any) {
        getQuizPair()
        correctMessageLabel.text = " "
    }
    
    @IBAction func answerWasPressed(_ sender: Any) {
        doTest()
    }
    
    func doTest () {
        guard quizPair != nil else {
            return
        }
        
        if userAnswerTextField.text != "" {
            compareCurrentAnswerWithQuiz(answer: getUserAnswer())
        } else {
            displayNoAnswerAlert()
        }
        
    }
    
    @IBAction func backWasPressed(_ sender: Any) {
        let storyboard = UIStoryboard(name: constants.introStoryboard, bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: constants.introViewController) as UIViewController
        present(vc, animated: true, completion: nil)
    }
    
    @IBAction func enterWasPressed(_ sender: Any) {
        doTest()
        print(currentMode)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        getMemoryStore()
        setupTapDismissOfKeyboard()
        if savedMemory!.count > 0 {
            getQuizPair()
        } else {
            currentQuizLabel.text = " "
            userAnswerTextField.isUserInteractionEnabled = false
            displayNoAvailableQuizPairsAlert()
        }
        
        
        if let modeState = currentMode {
            setupInitialModeState(modeState: modeState)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        getMemoryStore()
        if savedMemory!.count > 0 {
            getQuizPair()
        } else {
            currentQuizLabel.text = " "
            userAnswerTextField.isUserInteractionEnabled = false
            displayNoAvailableQuizPairsAlert()
        }

    }
    
    override func viewDidDisappear(_ animated: Bool) {
    ManagedData.saveContext()
}

func setupTapDismissOfKeyboard() {
    let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
    view.addGestureRecognizer(tap)
}

@objc func dismissKeyboard() {
    view.endEditing(true)
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
    
    print("The pair is \(String(describing: newQuizPair.french)) and \(String(describing: newQuizPair.english))")
    quizPair = newQuizPair
    displayQuiz(newQuizPair)
    clearUserAnswer()
}

func clearUserAnswer() {
    userAnswerTextField.text = " "
}


//display the currently selected quiz pair on screen
func displayQuiz(_ currentNoun: Nouns) {
    currentQuizLabel.text = currentNoun.returnQuizQuestion(quizState: quizState) as String as String
}

func getUserAnswer() -> String {
    var setAnswer: String = ""
    
    guard let userAnswer = userAnswerTextField.text else {
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

func compareCurrentAnswerWithQuiz(answer: String) {
    
    UIView.animate(withDuration: 0, animations: {self.correctMessageLabel.alpha = 1})
    
    if let currentQuiz = quizPair {
        
        //Factor in if the user got the correct gender
        var userGenderResponse = ""
        var userGenderChoiceCorrect = false
        if genderSwitch.isOn {
            userGenderResponse = Nouns.constants.female
        } else {
            userGenderResponse = Nouns.constants.male
        }
        
        if userGenderResponse == currentQuiz.gender {
            userGenderChoiceCorrect = true
        }
        
        //Compare the two words and the gender choice
        let compareResult = currentQuiz.compareUserAnswerToQuiz(quizState: quizState, userAnswer: getUserAnswer(), correctGenderChoice: userGenderChoiceCorrect)
        
        //Multiple change Quiz Loop
        if quizCount < 6 {
            //Several chances to get the answer correct
            if compareResult == QuizObject.compareResult.correct {
                compareIsCorrect()
                quizCount = 0
            } else if compareResult == QuizObject.compareResult.close {
                compareIsclose()
            } else {
                compareIsWrong()
            }
        } else {
            //When chances have run out
            correctMessageLabel.text = "Incorrect, the answer was: \(currentQuiz.returnQuizAnswer(quizState: quizState)) and the gender was \(String(describing: currentQuiz.gender))"
            if currentMode == "Quiz" {
                currentQuiz.addPointToPhraseIncorrectCount()
            }
            getQuizPair()
            quizCount = 1
        }
        
    }
    
    UIView.animate(withDuration: 2, animations: {self.correctMessageLabel.alpha = 0})
}

func compareIsCorrect() {
    correctMessageLabel.text = "Correct!!!"
    
    if currentMode == "Quiz" {
        quizPair!.addPointtoPhraseCorrectCount()
    }
    
    if quizPair!.learned == true && quizPair!.correctInARow == 10 {
        displayLearnedAlert()
    }
    
    getQuizPair()
}

func compareIsclose() {
    correctMessageLabel.text = "Almost, Try again! Try # \(quizCount)"
    quizCount += 1
}

func compareIsWrong() {
    correctMessageLabel.text = "Incorrect :/ Try # \(quizCount)"
    quizCount += 1
}

func setupInitialModeState (modeState: String){
    if modeState == mode.quiz {
        print("Quiz")
        setModeToQuiz()
    } else {
        print("Learn")
        setModeToLearn()
    }
}

func getMemoryStore() {
    let request: NSFetchRequest<Nouns> = Nouns.fetchRequest()
    var results = [Nouns]()
    
    do {
        results = try ManagedData.getContext().fetch(request)
        print("in getMemoryStore  \(results.count)")
    }
    catch {
        print(error)
    }
    if results.count == 0 {
        savedMemory = []
    } else {
        for noun in results {
            if noun.learned == false {
                savedMemory?.append(noun)
            }
        }
    }
}

//MARK: - Alert Functions
func displayNoAnswerAlert () {
    let alert = UIAlertController(title: "No Answer", message: "Please enter an answer.", preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "Okay", style: .cancel, handler: nil))
    self.present(alert, animated: true)
}

func displayNoAvailableQuizPairsAlert () {
    let alert = UIAlertController(title: "There are no available nouns pairs", message: "Please add more nouns to learn!", preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
    self.present(alert, animated: true)
}

func displayLearnedAlert () {
    let alert = UIAlertController(title: "Learned!", message: "You've gotten \(quizPair!.english ?? "No Noun Selected") correct 10 times in a row", preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "Okay", style: .cancel, handler: nil))
    self.present(alert, animated: true)
}

func displayCouldNotCompareAlert () {
    let alert = UIAlertController(title: "Noun Error", message: "An error has occured.", preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "Okay", style: .cancel, handler: nil))
    self.present(alert, animated: true)
}

}




extension NounQuizViewController {
    enum constants {
        static let introStoryboard = "Intro"
        static let introViewController = "Start"
    }
    
    enum mode {
        static let quiz = "Quiz"
        static let learn = "Learn"
    }
}


