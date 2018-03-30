//
//  appInfo.swift
//  FrenchQuizApp
//
//  Created by Charlie Scheer on 3/27/18.
//  Copyright © 2018 Paxsis. All rights reserved.
//

import UIKit

class appData {
    
    static var primaryLanguage: String?
    static var learningLanguage: String?
    
    init(primaryLanguage: String, learningLanguage: String) {
        self.primaryLanguage = primaryLanguage
        self.learningLanguage = learningLanguage
        
    }
    
    private func setLanguages(primaryLanguage primary: String, learningLanguage learning: String){
        self.primaryLanguage = primary
        self.learningLanguage = learning
    }
}


