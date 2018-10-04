import UIKit

extension Verbs {
    
    func unarchiveDictionary() -> [String : [String : String]] {
        var unarchivedDictionary : [String : [String : String]] = [ : ]
        
        if let conjugationData = self.conjugationDictionary {
            unarchivedDictionary = NSKeyedUnarchiver.unarchiveObject(with: conjugationData) as! [String : [String : String]]
        }
        return unarchivedDictionary
    }
    
    func compareUserAnswerToVerbQuiz (userAnswer: String, conjugatedQuiz: String) -> String {
        
        let result = getVerbCompareResult(userAnswer: userAnswer, conjugatedQuiz: conjugatedQuiz)
        
        let stringResult = getStringResult(result)
        
        return stringResult
    }
    
    func getVerbCompareResult(userAnswer: String, conjugatedQuiz: String) -> Double {
        let ldDistance = Double(levenshtein(aStr: userAnswer, bStr: conjugatedQuiz))
        let answerLength = Double(conjugatedQuiz.count)
        
        let result = (answerLength - ldDistance) / answerLength
        
        return result
    }
    
    func returnArticleArray() -> [String] {
        let articleArray = ["je", "tu", "il", "nous", "vous", "ils"]
        
        return articleArray
    }
    
    func returnTenseArray() -> [String] {
        let tenseArray = ["Présent", "Imparfait", "Futur", "Passé", "Passé simple"]
        
        return tenseArray 
    }
}


