import UIKit

class VerbQuizViewController: UIViewController {
    
    @IBAction func returnWasPressed(_ sender: Any) {
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
