import UIKit

class VerbQuizViewController: UIViewController {
    
    var currentMode : String?
    
    @IBOutlet weak var quizLearnButton: UIToolbar!
    @IBOutlet weak var currentModeLabel: UILabel!
    @IBOutlet weak var currentQuizLabel: UILabel!
    @IBOutlet weak var userAnswerLabel: UITextField!
    @IBOutlet weak var correctMessageLabel: UILabel!
    
    @IBAction func newQuizWasPressed(_ sender: Any) {
    }
    
    @IBAction func answerWasPressed(_ sender: Any) {
    }
    
    @IBAction func backWasPressed(_ sender: Any) {
        let storyboard = UIStoryboard(name: constants.introStoryboard, bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: constants.introViewController) as UIViewController
        present(vc, animated: true, completion: nil)
    }
}


extension VerbQuizViewController {
    enum constants {
        static let introStoryboard = "Intro"
        static let introViewController = "Start"
    }
}
