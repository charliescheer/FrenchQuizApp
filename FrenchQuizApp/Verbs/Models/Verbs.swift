import UIKit

extension Verbs {
    
    
    func unarchiveDictionary() -> [String : [String : String]] {
        var unarchivedDictionary : [String : [String : String]] = [ : ]
        
        if let conjugationData = self.conjugationDictionary {
            unarchivedDictionary = NSKeyedUnarchiver.unarchiveObject(with: conjugationData) as! [String : [String : String]]
        }
        return unarchivedDictionary
    }
    
}

