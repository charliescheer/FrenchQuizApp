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
    @IBOutlet weak var tableView: UITableView!
    
    var dataResultsController = ManagedData.resultsController
    var managedObjectContext = ManagedData.persistentContainer.viewContext
    
    override func viewDidLoad() {
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        ManagedData.saveContext()
    }
    
    @IBAction func submitNewPhrase() {
        if newEnglishPhrase.text == "" || newFrenchPhrase.text == "" {
            displayEmptyPhraseAlert()
        } else {
            let englishPhrase = newEnglishPhrase.text!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            let frenchPhrase = newFrenchPhrase.text!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            
            createNewPhrase(english: englishPhrase, french: frenchPhrase)
            clearUserFields()
        }
        
    }
    
    @IBAction func textFieldPrimaryActionTriggered(_ sender: Any) {
        if newEnglishPhrase.text == "" || newFrenchPhrase.text == "" {
            displayEmptyPhraseAlert()
        } else {
            let englishPhrase = newEnglishPhrase.text!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            let frenchPhrase = newFrenchPhrase.text!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            
            createNewPhrase(english: englishPhrase, french: frenchPhrase)
            clearUserFields()
        }

    }
    
    
    func createNewPhrase(english: String, french: String) {
        
        if let phrase = NSEntityDescription.insertNewObject(forEntityName: constants.phraseEntity,
                                                            into: managedObjectContext) as? Phrases {
            phrase.englishPhrase = english
            phrase.frenchPhrase = french
            phrase.creationDate = NSDate() as Date
            
            ManagedData.saveContext()
            
            do {
                try dataResultsController.performFetch()
            } catch {
                print("fetch failed")
            }
            
            tableView.reloadData()
            
            
        }
    }
    
    func clearUserFields () {
        newEnglishPhrase.text! = ""
        newFrenchPhrase.text! = ""
    }

    
    //MARK: - Alert Methods
    func displayEmptyPhraseAlert () {
        let alert = UIAlertController(title: "Enter Phrase", message: "Please enter a phrase for both fields", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
        self.present(alert, animated: true)
    }
    

}


extension AddPhraseViewController: UITableViewDelegate, UITableViewDataSource {
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        guard let sections = dataResultsController.sections else { return 0 }
        
        return sections.count
    }
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sectionInfo = dataResultsController.sections?[section] else {
            fatalError("No sections in fetchedResultsController")
        }
        
        return sectionInfo.numberOfObjects
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: constants.tableViewCellIndentifier, for: indexPath) as! PhraseCell
        if let phrase = dataResultsController.object(at: indexPath) as? Phrases {
            cell.englishLabel?.text = phrase.englishPhrase
            cell.frenchLabel?.text = phrase.frenchPhrase
        }

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: constants.showPhraseVC, sender: nil)
    }
    

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        if segue.identifier == constants.showPhraseVC {
            let phraseVC = segue.destination as? PhraseEditViewController
            
            guard let phraseCell = sender as? UITableViewCell,
                let indexPath = tableView.indexPath(for: phraseCell) else {
                    return
            }
            
            if let phrase = dataResultsController.object(at: indexPath) as? Phrases {
                phraseVC?.phrase = phrase
            }
        }
    }
    
}

extension AddPhraseViewController {
    enum constants {
        static let showPhraseVC = "ShowPhrase"
        static let tableViewCellIndentifier = "PhraseCell"
        static let phraseEntity = "Phrases"
    }
}
