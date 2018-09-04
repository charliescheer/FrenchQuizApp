import UIKit

extension Nouns {
        //MARK: - Comparing Functions
    func setGenderMale() {
        self.gender = constants.male
    }
    
    func setGenderFemale() {
        self.gender = constants.female
    }
    
    func compareUserAnswerToQuiz(quizState: Int, userAnswer: String, correctGenderChoice: Bool) -> String {
        var stringResult = ""
        let ldDisatance = Double(levenshtein(aStr: returnQuizAnswer(quizState: quizState), bStr: userAnswer))
        let answerLength = Double(returnQuizAnswer(quizState: quizState).count)
        
        var result = (answerLength - ldDisatance) / answerLength
        
        if correctGenderChoice != true {
            result -= 0.1
        }
        
        if result == 1{
            stringResult = compareResult.correct
        } else if result > 0.85 {
            stringResult = compareResult.close
        } else {
            stringResult = compareResult.incorrect
        }
        
        return stringResult
    }
}

extension Nouns {
    
    enum constants {
        static let male = "male"
        static let female = "female"
    }
}
