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
}
