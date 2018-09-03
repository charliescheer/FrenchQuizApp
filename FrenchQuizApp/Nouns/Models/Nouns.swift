import UIKit

extension Nouns {
        //MARK: - Comparing Functions
    func setGenderMale() {
        self.gender = constants.male
    }
    
    func setGenderFemale() {
        self.gender = constants.female
    }
}

extension Nouns {
    
    enum constants {
        static let male = "male"
        static let female = "female"
    }
}
