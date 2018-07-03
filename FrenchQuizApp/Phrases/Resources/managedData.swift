import UIKit
import CoreData


class ManagedData: NSObject {
    
    class func getContext() -> NSManagedObjectContext{
        return ManagedData.persistentContainer.viewContext
    }
    
    static var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: constants.persistantContainerName)
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
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
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: constants.entityName)
        var managedObjectContext = ManagedData.persistentContainer.viewContext
        
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: constants.sortDescriptor, ascending: false)]
        
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

extension ManagedData {
    enum constants {
        static let entityName = "Phrases"
        static let sortDescriptor = "creationDate"
        static let persistantContainerName = "FrenchQuizApp"
    }
}
