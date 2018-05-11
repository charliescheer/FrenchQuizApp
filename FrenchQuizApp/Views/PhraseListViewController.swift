import UIKit
import CoreData

class PhraseListViewController : UITableViewController {
   lazy var resultsController: NSFetchedResultsController = { () -> NSFetchedResultsController<NSFetchRequestResult> in
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Phrases")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "englishPhrase", ascending: true)]
        let controller = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                    managedObjectContext: self.managedObjectContext,
                                                    sectionNameKeyPath: nil, cacheName: nil)
        controller.delegate = self as? NSFetchedResultsControllerDelegate
        do{
            try controller.performFetch()
        } catch let error as NSError {
            assertionFailure("Failed to performFetch. \(error)")
        }
        var entityCount = controller.sections!.count
    
        return controller
    }()

    var managedObjectContext = managedData.persistentContainer.viewContext
    

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PhraseCell", for: indexPath) as! PhraseCell
        // Set up the cell
        if let phrase = resultsController.object(at: indexPath) as? Phrases {
            cell.englishLabel?.text = phrase.englishPhrase
            cell.frenchLabel?.text = phrase.frenchPhrase
        }
        //Populate the cell from the object
        return cell
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        guard let sections = resultsController.sections else { return 0 }
        return sections.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sectionInfo = resultsController.sections?[section] else {
            fatalError("No sections in fetchedResultsController")
        }
        
        return sectionInfo.numberOfObjects
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        managedData.saveContext()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        if segue.identifier == "ShowPhrase" {
            let phraseVC = segue.destination as? PhraseEditViewController
            
            guard let phraseCell = sender as? UITableViewCell,
                let indexPath = tableView.indexPath(for: phraseCell) else {
                    return
            }
        
            if let phrase = resultsController.object(at: indexPath) as? Phrases {
                phraseVC?.phrase = phrase
            }
        }
    }
}

