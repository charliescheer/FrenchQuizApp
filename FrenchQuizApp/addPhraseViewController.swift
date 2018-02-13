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

    var englishPhrase: String?
    var frenchPhrase: String?
    var addAlert: String = "Added"
    
    @IBOutlet weak var newEnglishPhrase: UITextField!
    @IBOutlet weak var newFrenchPhrase: UITextField!
    @IBOutlet weak var addedAlert: UILabel!
    
    @IBAction func submitNewPhrase() {
        englishPhrase = newEnglishPhrase.text!
        frenchPhrase = newFrenchPhrase.text!
        
        addedAlert.text = addAlert
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let context = appDelegate.persistentContainer.viewContext
        
        if let phrase = NSEntityDescription.insertNewObject(forEntityName: "Phrases",
                                                           into: context) as? Phrases {
            phrase.english = englishPhrase
            phrase.french = frenchPhrase
            
            
            appDelegate.saveContext()
        }
        
        
        
    }
    

}
