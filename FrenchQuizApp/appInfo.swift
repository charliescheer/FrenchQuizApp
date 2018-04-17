//
//  appInfo.swift
//  FrenchQuizApp
//
//  Created by Charlie Scheer on 3/27/18.
//  Copyright © 2018 Paxsis. All rights reserved.
//

import UIKit

class appData {
    
    var primaryLanguage: String?
    var learningLanguage: String?
    
    init(primaryLanguage: String, learningLanguage: String) {
        self.primaryLanguage = primaryLanguage
        self.learningLanguage = learningLanguage
        
    }
    
    private func setLanguages(primaryLanguage primary: String, learningLanguage learning: String){
        self.primaryLanguage = primary
        self.learningLanguage = learning
    }
    
//    func isAppAlreadyLaunchedOnce()->Bool{
//        let defaults = UserDefaults.standard
//        if let _ = defaults.string(forKey: "isAppAlreadyLaunchedOnce"){
//            print("App already launched")
//            return true
//        }else{
//            defaults.set(true, forKey: "isAppAlreadyLaunchedOnce")
//            print("App launched first time")
//            return false
//        }
    
}


