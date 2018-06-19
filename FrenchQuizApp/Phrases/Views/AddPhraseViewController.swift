//
//  addPhraseViewController.swift
//  frencQuizApp
//
//  Created by Charlie Scheer on 11/3/17.
//  Copyright © 2017 Praxis. All rights reserved.
//

import UIKit
import CoreData


class AddPhraseViewController: UIViewController {
    
    @IBOutlet weak var newEnglishPhrase: UITextField!
    @IBOutlet weak var newFrenchPhrase: UITextField!
    @IBOutlet weak var addedAlert: UILabel!
    @IBOutlet weak var englishLabel: UILabel!
    @IBOutlet weak var frenchLabel: UILabel!
    
    override func viewDidLoad() {
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        managedData.saveContext()
    }
    
    @IBAction func submitNewPhrase() {
        if newEnglishPhrase.text == "" || newFrenchPhrase.text == "" {
            displayEmptyPhraseAlert()
        } else {
            let englishPhrase = newEnglishPhrase.text!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            let frenchPhrase = newFrenchPhrase.text!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            
            createNewPhrase(primary: englishPhrase, learning: frenchPhrase)
            
            newEnglishPhrase.text! = ""
            newFrenchPhrase.text! = ""
        
        }
        
    }
    
    @IBAction func textFieldPrimaryActionTriggered(_ sender: Any) {
        if newEnglishPhrase.text == "" || newFrenchPhrase.text == "" {
            displayEmptyPhraseAlert()
        } else {
            let primaryPhrase = newEnglishPhrase.text!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            let learningPhrase = newFrenchPhrase.text!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            
            createNewPhrase(primary: primaryPhrase, learning: learningPhrase)
            
            newEnglishPhrase.text! = ""
            newFrenchPhrase.text! = ""
            
        }

    }
    
    func createNewPhrase(primary: String, learning: String) {
        let context = managedData.persistentContainer.viewContext
        if let phrase = NSEntityDescription.insertNewObject(forEntityName: "Phrase",
                                                            into: context) as? Phrase {
            phrase.englishPhrase = primary
            phrase.frenchPhrase = learning
        }
    }
    
    //MARK: - Alert Methods
    func displayEmptyPhraseAlert () {
        let alert = UIAlertController(title: "Enter Phrase", message: "Please enter a phrase for both fields", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
        self.present(alert, animated: true)
    }
    

}


extension AddPhraseViewController: UITableViewDelegate, UITableViewDataSource {
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PhraseCell", for: indexPath) as! PhraseCell
        cell.englishLabel?.text = "English \(indexPath.row)"
        cell.frenchLabel?.text = "French \(indexPath.row)"
        
        return cell
    }
    
    
    
}
