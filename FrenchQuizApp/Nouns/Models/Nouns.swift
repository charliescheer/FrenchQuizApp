import UIKit

extension Nouns {
        //MARK: - Comparing Functions
        
    func compareUserAnswerToQuiz (quizState: Int, userAnswer: String) -> Double {
        var result: Double = 0.00
        let ldDisatance = Double(self.doLDNounCompare(userAnswer: userAnswer, quizState: quizState))
        
        guard ldDisatance != 100 else {
            result = 2
            return result
        }
        
        let answerLength = Double(self.returnQuizAnswer(quizState: quizState).count)
        result = (answerLength - ldDisatance) / answerLength
        
        return result
    }
    
    func doLDNounCompare(userAnswer: String?, quizState: Int) -> Int {
        var result: Int = 0
        
        guard let answer = userAnswer else {
            result = 100
            print("LD compare returning 2")
            return result
        }
        
        if quizState == 0 {
            let quiz = self.frenchNoun!.lowercased()
            result = levenshtein(aStr: quiz, bStr: answer)
        } else {
            let quiz = self.englishNoun!.lowercased()
            result = levenshtein(aStr: quiz, bStr: answer)
        }
        
        return result
    }
    
    //MARK: - View helper functions
    func returnQuizQuestion (quizState: Int) -> String {
        var quiz: String = ""
        
        if quizState == 0 {
            if let french = self.englishNoun?.lowercased(){
                quiz = french
            }
        } else {
            if let english = self.frenchNoun?.lowercased() {
                quiz = english
            }
        }
        return quiz
    }
    
    
    func returnQuizAnswer (quizState: Int) -> String {
        var answer: String = " "
        
        if quizState == 0 {
            answer = self.frenchNoun!.lowercased()
        } else {
            answer = self.englishNoun!.lowercased()
        }
        
        return answer
    }
}
