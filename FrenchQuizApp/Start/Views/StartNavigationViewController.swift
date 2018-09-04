//
//  StartNavigationViewController.swift
//  FrenchQuizApp
//
//  Created by Charlie Scheer on 6/6/18.
//  Copyright © 2018 Paxsis. All rights reserved.
//

import UIKit

class StartNavigationViewController:  UIViewController {
    
    @IBOutlet weak var nounButton: UIButton!
    @IBOutlet weak var quizButton: UIButton!
    @IBOutlet weak var phraseButton: UIButton!
    @IBOutlet weak var learnButton: UIButton!
    @IBOutlet weak var verbButton: UIButton!
    
    

    @IBAction func quizWasPressed(_ sender: Any) {
        desiredMode = constants.quizMode
        displayStudyModes()
    
    }
    
    @IBAction func phraseWasPressed(_ sender: Any) {
//        let storyboard = UIStoryboard(name: constants.phraseStoryboard, bundle: nil)
//        let vc = storyboard.instantiateViewController(withIdentifier: constants.phraseViewController) as! PhraseQuizViewController
//        vc.currentModeState = desiredMode
//        present(vc, animated: true, completion: nil)
        
        guard let button = sender as? UIButton else {
            return
        }
        
        
        enterQuizModes(sender: button.tag, mode: desiredMode)
    }
    
    
    @IBAction func learnWasPressed(_ sender: Any) {
        desiredMode = constants.learnMode
        displayStudyModes()
    }
    
    var desiredMode = ""
    
    
    override func viewDidLoad() {
        setUpView()


        
    }
    
    func setUpView() {
        nounButton.alpha = 0
        phraseButton.alpha = 0
        verbButton.alpha = 0
        quizButton.alpha = 0
        learnButton.alpha = 0
        
        nounButton.isEnabled = false
        phraseButton.isEnabled = false
        verbButton.isEnabled = false
        
        UIView.animate(withDuration: 1) {
            self.quizButton.alpha = 1
            self.learnButton.alpha = 1
        }
    }
    
    func displayStudyModes() {
        nounButton.isEnabled = true
        phraseButton.isEnabled = true
        verbButton.isEnabled = true
        quizButton.isEnabled = false
        learnButton.isEnabled = false
        
        UIView.animate(withDuration: 1) {
            self.nounButton.alpha = 1
            self.phraseButton.alpha = 1
            self.verbButton.alpha = 1
            self.quizButton.alpha = 0
            self.learnButton.alpha = 0
        }
    }

    func enterQuizModes(sender: Int, mode: String) {
        switch sender {
        case 1:
            let storyboard = UIStoryboard(name: constants.phraseStoryboard, bundle: nil)
            let tabBarController = storyboard.instantiateViewController(withIdentifier: "navigation") as! UITabBarController
            let tempVC = tabBarController.viewControllers![0] as! PhraseQuizViewController
            tempVC.currentMode = mode
            
            present(tabBarController, animated: true, completion: nil)
        case 2:
            let storyboard = UIStoryboard(name: constants.nounStoryboard, bundle: nil)
            let tabBarController = storyboard.instantiateViewController(withIdentifier: constants.navigationController) as! UITabBarController
            let tempVC = tabBarController.viewControllers![0] as! NounQuizViewController
            tempVC.currentMode = mode
            
            present(tabBarController, animated: true, completion: nil)
        case 3:
            let storyboard = UIStoryboard(name: constants.verbStoryboard, bundle: nil)
            let tabBarController = storyboard.instantiateViewController(withIdentifier: constants.navigationController) as! UITabBarController
            let tempVC = tabBarController.viewControllers![0] as! VerbQuizViewController
            tempVC.currentMode = mode
            
            present(tabBarController, animated: true, completion: nil)
        default:
            print("An error has occured")
        }
    }
    

}

extension StartNavigationViewController {
    enum constants {
        static let phraseStoryboard = "Phrases"
        static let phraseViewController = "phrase"
        static let verbStoryboard = "Verbs"
        static let verbViewController = "verb"
        static let nounStoryboard = "Nouns"
        static let nounViewController = "noun"
        static let navigationController = "navigation"
        
        static let quizMode = "Quiz"
        static let learnMode = "Learn"
    }
}
