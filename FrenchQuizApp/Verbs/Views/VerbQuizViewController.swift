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
    
    
    @IBOutlet weak var quizLearnButton: UIToolbar!
    @IBOutlet weak var currentModeLabel: UILabel!
    @IBOutlet weak var currentQuizLabel: UILabel!
    @IBOutlet weak var userAnswerTextField: UITextField!
    @IBOutlet weak var correctMessageLabel: UILabel!
    @IBOutlet weak var currentArticleLabel: UILabel!
    @IBOutlet weak var currentTenseLabel: UILabel!
    
    @IBAction func newQuizWasPressed(_ sender: Any) {
    }
    
    @IBAction func answerWasPressed(_ sender: Any) {
        guard let currentVerb = verb else {
            return
        }
        
        guard let currentQuizAnswer = quizVerbConjugation else {
            return
        }
        
        print(currentVerb.compareUserAnswerToVerbQuiz(userAnswer: getUserAnswer(), conjugatedQuiz: currentQuizAnswer))
    }
    
    @IBAction func backWasPressed(_ sender: Any) {
        let storyboard = UIStoryboard(name: constants.introStoryboard, bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: constants.introViewController) as UIViewController
        present(vc, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getMemoryStore()
        
        if savedMemory!.count > 0 {
            getQuizVerb()
            
            setAndDisplayQuizAnswer()
            print(quizVerbConjugation)
        }
        
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
}
