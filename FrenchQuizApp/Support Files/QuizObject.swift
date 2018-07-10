import UIKit

extension QuizObject {
    
    //MARK: - Phrase Score Counting Functions
    func addPointtoPhraseCorrectCount() {
        self.timesCorrect += 1
        self.correctInARow += 1
        checkIfLearned()
    }
    
    func resetCountPhraseCounts() {
        self.correctInARow = 0
        self.timesCorrect = 0
        self.timesIncorrect = 0
        self.correctInARow = 0
        self.learned = false
    }
    
    func addPointToPhraseIncorrectCount() {
        self.timesIncorrect += 1
    }
    
    func checkIfLearned() {
        if correctInARow == 10 {
            self.learned = true
        }
    }
    
    //MARK: - Comparing methods
    
    private class func min(numbers: Int...) -> Int {
        return numbers.reduce(numbers[0], {$0 < $1 ? $0 : $1})
    }
    
    class Array2D {
        var cols:Int, rows:Int
        var matrix: [Int]
        
        
        init(cols:Int, rows:Int) {
            self.cols = cols
            self.rows = rows
            matrix = Array(repeating:0, count:cols*rows)
        }
        
        subscript(col:Int, row:Int) -> Int {
            get {
                return matrix[cols * row + col]
            }
            set {
                matrix[cols*row+col] = newValue
            }
        }
        
        func colCount() -> Int {
            return self.cols
        }
        
        func rowCount() -> Int {
            return self.rows
        }
    }
    
    func levenshtein(aStr: String, bStr: String) -> Int {
        let a = Array(aStr.utf16)
        let b = Array(bStr.utf16)
        
        let dist = Array2D(cols: a.count + 1, rows: b.count + 1)
        
        for i in 1...a.count {
            dist[i, 0] = i
        }
        
        for j in 1...b.count {
            dist[0, j] = j
        }
        
        for i in 1...a.count {
            for j in 1...b.count {
                if a[i-1] == b[j-1] {
                    dist[i, j] = dist[i-1, j-1]  // noop
                } else {
                    dist[i, j] = Swift.min(
                        dist[i-1, j] + 1,  // deletion
                        dist[i, j-1] + 1,  // insertion
                        dist[i-1, j-1] + 1  // substitution
                    )
                }
            }
        }
        
        return dist[a.count, b.count]
    }
    
    func compareUserAnswerToQuiz (quizState: Int, userAnswer: String) -> Double {
        var result: Double = 0.00
        let ldDisatance = Double(self.doLDPhraseCompare(userAnswer: userAnswer, quizState: quizState))
        
        guard ldDisatance != 100 else {
            result = 2
            return result
        }
        
        let answerLength = Double(self.returnQuizAnswer(quizState: quizState).count)
        result = (answerLength - ldDisatance) / answerLength
        
        return result
    }
    
    func doLDPhraseCompare(userAnswer: String?, quizState: Int) -> Int {
        var result: Int = 0
        
        guard let answer = userAnswer else {
            result = 100
            print("LD compare returning 2")
            return result
        }
        
        if quizState == 0 {
            let quiz = self.french!.lowercased()
            result = levenshtein(aStr: quiz, bStr: answer)
        } else {
            let quiz = self.english!.lowercased()
            result = levenshtein(aStr: quiz, bStr: answer)
        }
        
        return result
    }
    
    //MARK: - View helper functions
    func returnQuizQuestion (quizState: Int) -> String {
        var quiz: String = ""
        
        if quizState == 0 {
            if let french = self.english?.lowercased(){
                quiz = french
            }
        } else {
            if let english = self.french?.lowercased() {
                quiz = english
            }
        }
        return quiz
    }
    
    
    func returnQuizAnswer (quizState: Int) -> String {
        var answer: String = " "
        
        if quizState == 0 {
            answer = self.french!.lowercased()
        } else {
            answer = self.english!.lowercased()
        }
        
        return answer
    }
    
    
}
