import UIKit
import CoreData

class PhraseListViewController : UITableViewController {

        lazy var resultsController: NSFetchedResultsController = { () -> NSFetchedResultsController<NSFetchRequestResult> in
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Phrases")
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "primaryLanguage", ascending: true)]
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

        var managedObjectContext: NSManagedObjectContext {
            get {
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                return appDelegate.persistentContainer.viewContext
            }
        }



        override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "PhraseCell", for: indexPath) as! phraseCell
            // Set up the cell
            if let phrase = resultsController.object(at: indexPath) as? Phrases {
                cell.primaryLabel?.text = phrase.primaryLanguage
                cell.learningLabel?.text = phrase.learningLanguage
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


        func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
            tableView.beginUpdates()
        }

        func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
            switch type {
            case .insert:
                tableView.insertSections(IndexSet(integer: sectionIndex), with: .fade)
            case .delete:
                tableView.deleteSections(IndexSet(integer: sectionIndex), with: .fade)
            case .move:
                break
            case .update:
                break
            }
        }

        func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
            switch type {
            case .insert:
                tableView.insertRows(at: [newIndexPath!], with: .fade)
            case .delete:
                tableView.deleteRows(at: [indexPath!], with: .fade)
            case .update:
                tableView.reloadRows(at: [indexPath!], with: .fade)
            case .move:
                tableView.moveRow(at: indexPath!, to: newIndexPath!)
            }
        }

        func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
            tableView.endUpdates()
        }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        if segue.identifier == "ShowPhrase" {
            let phraseVC = segue.destination as? phraseEditView
            
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

