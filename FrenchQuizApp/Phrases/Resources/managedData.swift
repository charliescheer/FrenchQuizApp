import UIKit
import CoreData


class managedData: NSObject {
    
    private override init() {
        
    }
    
    class func getContext() -> NSManagedObjectContext{
        return managedData.persistentContainer.viewContext
    }
    
    static var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "FrenchQuizApp")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // MARK: - Core Data Saving support
    
    class func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    static var resultsController: NSFetchedResultsController = { () -> NSFetchedResultsController<NSFetchRequestResult> in
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Phrase")
        var managedObjectContext = managedData.persistentContainer.viewContext
        
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        
        let controller = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                    managedObjectContext: managedObjectContext,
                                                    sectionNameKeyPath: nil, cacheName: nil)
        
        
        
        do{
            try controller.performFetch()
        } catch let error as NSError {
            assertionFailure("Failed to performFetch. \(error)")
        }
        
        var entityCount = controller.sections!.count
        
        return controller
    }()
}
