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
        self.setAsNotLearned()
    }
    
    func addPointToPhraseIncorrectCount() {
        self.timesIncorrect += 1
        self.correctInARow = 0
    }
    
    func checkIfLearned() {
        if correctInARow == 10 {
            self.setAsLearned()
        }
    }
    
    //MARK: - Comparing methods
    /**
     * Levenshtein edit distance calculator
     * Usage: levenstein <string> <string>
     *
     * Inspired by https://gist.github.com/bgreenlee/52d93a1d8fa1b8c1f38b
     * Improved with http://stackoverflow.com/questions/26990394/slow-swift-arrays-and-strings-performance
     */
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

    
    func compareUserAnswerToQuiz (quizState: Int, userAnswer: String) -> String {
        let result = getWordCompareResult(quizState: quizState, userAnswer: userAnswer)
        
        let stringResult = getStringResult(result)
        
        return stringResult
    }
    
    func getWordCompareResult (quizState: Int, userAnswer: String) -> Double {
        let ldDisatance = Double(levenshtein(aStr: returnQuizAnswer(quizState: quizState), bStr: userAnswer))
        let answerLength = Double(returnQuizAnswer(quizState: quizState).count)
        
        let result = (answerLength - ldDisatance) / answerLength
        
        return result
    }
    
    func getStringResult(_ result: Double) -> String {
        var stringResult = ""
        if result == 1{
            stringResult = compareResult.correct
        } else if result > 0.85 {
            stringResult = compareResult.close
        } else {
            stringResult = compareResult.incorrect
        }
        
        return stringResult
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
    
    func setAsLearned(){
       self.learned = true
    }
    
    func setAsNotLearned(){
        self.learned = false
    }
    
    
}

extension QuizObject {
    enum compareResult {
        static let correct = "correct"
        static let incorrect = "incorrect"
        static let close = "close"
    }
}
