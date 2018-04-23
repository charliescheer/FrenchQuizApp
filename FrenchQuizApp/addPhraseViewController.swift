//
//  addPhraseViewController.swift
//  frencQuizApp
//
//  Created by Charlie Scheer on 11/3/17.
//  Copyright © 2017 Praxis. All rights reserved.
//

import UIKit
import CoreData


class addPhraseViewController: UIViewController {
//
//    var primaryPhrase: String?
//    var learningPhrase: String?
//    var addAlert: String = " "
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    @IBOutlet weak var newPrimaryPhrase: UITextField!
    @IBOutlet weak var newLearningPhrase: UITextField!
    @IBOutlet weak var addedAlert: UILabel!
    
    override func viewDidLoad() {
        addedAlert.text = ""
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        managedData.saveContext()
    }
    
    @IBAction func submitNewPhrase() {
        if newPrimaryPhrase.text == "" || newLearningPhrase.text == "" {
            emptyPhraseAlert()
        } else {
            let primaryPhrase = newPrimaryPhrase.text!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            let learningPhrase = newLearningPhrase.text!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            
            createNewPhrase(primary: primaryPhrase, learning: learningPhrase)
            
            newLearningPhrase.text! = ""
            newPrimaryPhrase.text! = ""
        
        }
        
    }
    
    func createNewPhrase(primary: String, learning: String) {
        let context = managedData.persistentContainer.viewContext
        if let phrase = NSEntityDescription.insertNewObject(forEntityName: "Phrases",
                                                            into: context) as? Phrases {
            phrase.primaryLanguage = primary
            phrase.learningLanguage = learning
        }
    }
    
    //Alert Methods
    func emptyPhraseAlert () {
        let alert = UIAlertController(title: "Enter Phrase", message: "Please enter a phrase for both fields", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
        self.present(alert, animated: true)
    }
    

}
