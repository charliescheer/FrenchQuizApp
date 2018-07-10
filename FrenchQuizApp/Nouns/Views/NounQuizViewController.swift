import UIKit

class NounQuizViewController: UIViewController {

    @IBOutlet weak var currentQuizLabel: UILabel!
    @IBOutlet weak var userAnswerTextField: UITextField!
    @IBOutlet weak var quizButton: UIBarButtonItem!
    
    @IBAction func quizButtonWasPressed(_ sender: Any) {
    }
    
    @IBAction func newQuizButtonWasPressed(_ sender: Any) {
    }
    
    @IBAction func answerWasPressed(_ sender: Any) {
    }
    
    @IBAction func backWasPressed(_ sender: Any) {
            let storyboard = UIStoryboard(name: constants.introStoryboard, bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: constants.introViewController) as UIViewController
            present(vc, animated: true, completion: nil)
        }
    }
    
    
    extension NounQuizViewController {
        enum constants {
            static let introStoryboard = "Intro"
            static let introViewController = "Start"
        }
    }


