import UIKit
import CoreData

class VerbQuizViewController: UIViewController {
    
    var currentMode : String?
    var verb : Verbs?
    var savedMemory : [Verbs]? = []
    var verbDictionary : [String : [String : String]]?
    var tenses = ["Présent", "Imparfait", "Futur", "Passé", "Passé simple"]
    var articles = ["je", "tu", "il", "nous", "vous", "ils"]
    var quizVerbConjugation : String?
    var quizCount = 1
    
    
    @IBOutlet weak var quizLearnButton: UIToolbar!
    @IBOutlet weak var currentModeLabel: UILabel!
    @IBOutlet weak var currentQuizLabel: UILabel!
    @IBOutlet weak var userAnswerTextField: UITextField!
    @IBOutlet weak var correctMessageLabel: UILabel!
    @IBOutlet weak var currentArticleLabel: UILabel!
    @IBOutlet weak var currentTenseLabel: UILabel!
    @IBOutlet weak var quizStateButton: UIBarButtonItem!
    
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
    
    @IBAction func newQuizWasPressed(_ sender: Any) {
        getQuizVerb()
        setAndDisplayQuizAnswer()
        correctMessageLabel.text = " "
    }
    
    @IBAction func answerWasPressed(_ sender: Any) {
        doQuiz()
    }
    
    @IBAction func backWasPressed(_ sender: Any) {
        let storyboard = UIStoryboard(name: constants.introStoryboard, bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: constants.introViewController) as UIViewController
        present(vc, animated: true, completion: nil)
    }
    
    @IBAction func enterWasPressed(_ sender: Any) {
        doQuiz()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(currentMode)
        
        getMemoryStore()
        setupTapDismissOfKeyboard()
        if savedMemory!.count > 0 {
            getQuizVerb()
            setAndDisplayQuizAnswer()
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
    
    func doQuiz() {
        UIView.animate(withDuration: 0, animations: {self.correctMessageLabel.alpha = 1})
        
        guard let currentVerb = verb else {
            return
        }
        
        guard let currentQuizAnswer = quizVerbConjugation else {
            return
        }
        
        if userAnswerTextField.text != "" {
            let compareResult = currentVerb.compareUserAnswerToVerbQuiz(userAnswer: getUserAnswer(), conjugatedQuiz: currentQuizAnswer)
            print(compareResult)
            
            if quizCount < 6 {
                //Several chances to get the answer correct
                if compareResult == QuizObject.compareResult.correct {
                    compareIsCorrect()
                    quizCount = 1
                } else if compareResult == QuizObject.compareResult.close {
                    compareIsclose()
                } else {
                    compareIsWrong()
                }
            } else {
                //When chances have run out
                correctMessageLabel.text = "Incorrect, the answer was: \(String(describing: quizVerbConjugation))"
                if currentMode == "Quiz" {
                    currentVerb.addPointToPhraseIncorrectCount()
                }
                getQuizVerb()
                setAndDisplayQuizAnswer()
                quizCount = 1
                clearUserAnswer()
            }
        } else {
            displayNoAnswerAlert()
        }
        
        UIView.animate(withDuration: 2, animations: {self.correctMessageLabel.alpha = 0})
    }
    
    func getQuizVerb() {
        guard let memory = savedMemory else {
            return
        }
        
        guard memory.count > 0 else {
            displayNoAvailableVerbsAlert()
            return
        }
        
        let randomIndex = Int(arc4random_uniform(UInt32(memory.count)))
        verb = memory[randomIndex]
        
        verbDictionary = verb!.unarchiveDictionary()
    }
    
    func setAndDisplayQuizAnswer() {
        
        guard let dictionary = verbDictionary else {
            return
        }
        
        guard let currentVerb = verb else {
            return
        }
        
        let quizTense = tenses[Int(arc4random_uniform(UInt32(tenses.count)))]
        let quizArticle = articles[Int(arc4random_uniform(UInt32(articles.count)))]
        print(quizTense)
        print(quizArticle)
        
        currentArticleLabel.text = quizArticle
        currentTenseLabel.text = quizTense
        currentQuizLabel.text = currentVerb.english
        
        quizVerbConjugation = dictionary[quizTense]![quizArticle]! as String
        
        //remove for production
        if let verbConjugation = quizVerbConjugation {
            print(verbConjugation)
        }
    }
    
    
    
    func getMemoryStore() {
        let request: NSFetchRequest<Verbs> = Verbs.fetchRequest()
        var results = [Verbs]()
        
        do {
            results = try ManagedData.getContext().fetch(request)
            print(results.count)
        }
        catch {
            print(error)
        }
        
        for verb in results {
            if verb.learned == false {
                savedMemory?.append(verb)
                
            }
        }
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
    
    func compareIsCorrect() {
        correctMessageLabel.text = "Correct!!!"
        
        if currentMode == "Quiz" {
            verb?.addPointtoPhraseCorrectCount()
        }
        
        if verb!.learned == true && verb!.correctInARow == 10 {
            displayLearnedAlert()
        }
        
        getQuizVerb()
        setAndDisplayQuizAnswer()
        clearUserAnswer()
    }
    
    func compareIsclose() {
        correctMessageLabel.text = "Almost, Try again! Try # \(quizCount)"
        quizCount += 1
    }
    
    func compareIsWrong() {
        correctMessageLabel.text = "Incorrect :/ Try # \(quizCount)"
        quizCount += 1
    }
    
    func clearUserAnswer() {
        userAnswerTextField.text = " "
    }
    
    
    
    
    //MARK: - Alert Functions
    func displayNoAnswerAlert () {
        let alert = UIAlertController(title: "No Answer", message: "Please enter an answer.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Okay", style: .cancel, handler: nil))
        self.present(alert, animated: true)
    }
    
    func displayLearnedAlert () {
        let alert = UIAlertController(title: "Learned!", message: "You've gotten \(verb!.english ?? "No verb Selected") correct 10 times in a row", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Okay", style: .cancel, handler: nil))
        self.present(alert, animated: true)
    }
    
    func displayNoAvailableQuizPairsAlert () {
        let alert = UIAlertController(title: "There are no available verbs", message: "Please add more verbs to learn!", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
        self.present(alert, animated: true)
    }
}


extension VerbQuizViewController {
    func displayNoAvailableVerbsAlert () {
        let alert = UIAlertController(title: "There are no available Verbs", message: "Please add more verbs to learn!", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
        self.present(alert, animated: true)
    }
}


extension VerbQuizViewController {
    enum constants {
        static let introStoryboard = "Intro"
        static let introViewController = "Start"
    }
    
    enum mode {
        static let quiz = "quiz"
        static let learn = "Learn"
    }
}
