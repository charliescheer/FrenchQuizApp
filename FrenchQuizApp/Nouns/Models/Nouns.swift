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
        var result = getWordCompareResult(quizState: quizState, userAnswer: userAnswer)
        
        //factor in gender
        if correctGenderChoice == false {
            result -= 0.1
        }
        
        let stringResult = getStringResult(result)
        
        return stringResult
    }
}

extension Nouns {
    
    enum constants {
        static let male = "male"
        static let female = "female"
    }
}
