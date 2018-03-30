import UIKit
import CoreData

extension Phrases {
    
    func addPoint() {
        self.timesCorrect += 1
        self.correctInARow += 1
        checkIfLearned()
    }
    
    func resetCount() {
        self.correctInARow = 0
    }
    
    func takePoint() {
        self.timesIncorrect += 1
    }
    
    func checkIfLearned() {
        if correctInARow == 10 {
            self.learned = true
        }
    }
    
    func LDCompare(userAnswer: String?, quizState: Int) -> Int {
        var result: Int = 0
        let state = quizState
        
        if state == 0 {
            if let answer = userAnswer {
                if let quiz = self.learningLanguage {
                    result = Tools.levenshtein(aStr: quiz, bStr: answer)
                }
            }
        
        } else {
            if let answer = userAnswer {
                if let quiz = self.primaryLanguage {
                    result = Tools.levenshtein(aStr: quiz, bStr: answer)
                }
            }
        }
        
        return result
    }
    
    
}
