import UIKit
import CoreData

extension Phrases {
    
    //MARK: - Comparing Functions
    func doCompare (quizState: Int, userAnswer: String) -> Double {
        let percentCorrect = percentageCompare(userAnswer: userAnswer, quizState: quizState)
        return percentCorrect
    }
    
    func percentageCompare (userAnswer: String?, quizState: Int) -> Double {
        var result: Double = 0.00
        
        if let user = userAnswer {
            let ldDisatance = Double(self.LDCompare(userAnswer: user, quizState: quizState))
            let answerLength = Double(user.count)
            result = (answerLength - ldDisatance) / answerLength
            print("percent result \(result)")
        }
        return result
    }
    
    func LDCompare(userAnswer: String?, quizState: Int) -> Int {
        var result: Int = 0
        let state = quizState
        
        if state == 0 {
            if let answer = userAnswer {
                if let quiz = self.french {
                    result = Tools.levenshtein(aStr: quiz, bStr: answer)
                }
            }
            
        } else {
            if let answer = userAnswer {
                if let quiz = self.english {
                    result = Tools.levenshtein(aStr: quiz, bStr: answer)
                }
            }
        }
        
        return result
    }
    
    //MARK: - View helper functions
    func returnQuiz (quizState: Int) -> String {
        var quiz: String = ""
        
        if quizState == 0 {
            if let french = self.french?.lowercased(){
                quiz = french
            }
        } else {
            if let english = self.english?.lowercased() {
                quiz = english
            }
        }
        return quiz
    }
    
    
    func returnAnswer (quizState: Int) -> String {
        var answer: String = " "
        
        if quizState == 0 {
            answer = self.english!.lowercased()
        } else {
            answer = self.french!.lowercased()
        }
        
        return answer
    }
    
    
    //MARK: - Phrase Score Counting Functions
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
    

