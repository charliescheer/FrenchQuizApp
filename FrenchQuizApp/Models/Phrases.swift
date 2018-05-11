import UIKit
import CoreData

extension Phrases {
    
    //MARK: - Comparing Functions
    
    func compareUserAnswerToQuiz (quizState: Int, userAnswer: String) -> Double {
        var result: Double = 0.00
        
            let ldDisatance = Double(self.LDCompare(userAnswer: userAnswer, quizState: quizState))
            let answerLength = Double(self.returnQuizAnswer(quizState: quizState).count)
            result = (answerLength - ldDisatance) / answerLength
            print("percent result \(result)")
            print("user answer \(userAnswer)")
      
        return result
    }
    
    func LDCompare(userAnswer: String?, quizState: Int) -> Int {
        var result: Int = 0
        
        
        if quizState == 0 {
            if let answer = userAnswer {
                if let quiz = self.frenchPhrase?.lowercased() {
                    if answer != "NO ANSWER" {
                        result = levenshtein(aStr: quiz, bStr: answer)
                        print(result)
                    }
                }
            }
            
        } else {
            if let answer = userAnswer {
                if let quiz = self.englishPhrase?.lowercased() {
                        if answer != "NO ANSWER" {
                        result = Tools.levenshtein(aStr: quiz, bStr: answer)
                        print(result)
                        } else {
                            result = 2
                    }
                }
            }
        }
        
        return result
    }
    
    //MARK: - View helper functions
    func returnQuizQuestion (quizState: Int) -> String {
        var quiz: String = ""
        
        if quizState == 0 {
            if let french = self.englishPhrase?.lowercased(){
                quiz = french
            }
        } else {
            if let english = self.frenchPhrase?.lowercased() {
                quiz = english
            }
        }
        return quiz
    }
    
    
    func returnQuizAnswer (quizState: Int) -> String {
        var answer: String = " "
        
        if quizState == 0 {
            answer = self.frenchPhrase!.lowercased()
        } else {
            answer = self.englishPhrase!.lowercased()
        }
        
        return answer
    }
    
    

}
    

