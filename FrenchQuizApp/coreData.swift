////
////  coreData.swift
////  FrenchQuizApp
////
////  Created by Charlie Scheer on 3/6/18.
////  Copyright © 2018 Paxsis. All rights reserved.
////
//
//import UIKit
//import CoreData
//
//class testingmethod {
//    var resultsController: NSFetchedResultsController = { () -> NSFetchedResultsController<NSFetchRequestResult> in
//        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Phrases")
//        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "primaryLanguage", ascending: true)]
//        let controller = NSFetchedResultsController(fetchRequest: fetchRequest,
//                                                    managedObjectContext: self.managedObjectContext,
//                                                    sectionNameKeyPath: nil, cacheName: nil)
//        controller.delegate = self as? NSFetchedResultsControllerDelegate
//        do{
//            try controller.performFetch()
//        } catch let error as NSError {
//            assertionFailure("Failed to performFetch. \(error)")
//        }
//        var entityCount = controller.sections!.count
//
//        return controller
//    }()
//
//    var managedObjectContext: NSManagedObjectContext {
//        get {
//            let appDelegate = UIApplication.shared.delegate as! AppDelegate
//            return appDelegate.persistentContainer.viewContext
//        }
//    }
//}

