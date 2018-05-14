import UIKit
import CoreData

extension Phrases {
    
    //MARK: - Comparing Functions
    
    func compareUserAnswerToQuiz (quizState: Int, userAnswer: String) -> Double {
        var result: Double = 0.00
        
        let ldDisatance = Double(self.doLDPhraseCompare(userAnswer: userAnswer, quizState: quizState))
        
        guard ldDisatance == 2.0 else {
            return result
        }
        
        let answerLength = Double(self.returnQuizAnswer(quizState: quizState).count)
        result = (answerLength - ldDisatance) / answerLength
        print("percent result \(result)")
        print("user answer \(userAnswer)")
  
        return result
    }
    
    func doLDPhraseCompare(userAnswer: String?, quizState: Int) -> Int {
        var result: Int = 0
        
        guard let answer = userAnswer else {
            result = 2
            return result
        }
        
        guard let quiz = self.frenchPhrase?.lowercased() else {
            result = 2
            return result
        }
        
        guard answer == "NO ANSWER" else {
            result = 2
            return result
        }
        
        if quizState == 0 {
                result = levenshtein(aStr: quiz, bStr: answer)
                print(result)
        } else {
            result = levenshtein(aStr: quiz, bStr: answer)
            print(result)
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
    

