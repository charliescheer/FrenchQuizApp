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

    var primaryPhrase: String?
    var learningPhrase: String?
    var addAlert: String = "Added"
    
    @IBOutlet weak var newPrimaryPhrase: UITextField!
    @IBOutlet weak var newLearningPhrase: UITextField!
    @IBOutlet weak var addedAlert: UILabel!
    
    @IBAction func submitNewPhrase() {
        primaryPhrase = newPrimaryPhrase.text!
        learningPhrase = newLearningPhrase.text!
        
        addedAlert.text = addAlert
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let context = appDelegate.persistentContainer.viewContext
        
        if let phrase = NSEntityDescription.insertNewObject(forEntityName: "Phrases",
                                                           into: context) as? Phrases {
            phrase.primaryLanguage = primaryPhrase
            phrase.learningLanguage = learningPhrase
            
            
            appDelegate.saveContext()
        }
        
        
        
    }
    

}
