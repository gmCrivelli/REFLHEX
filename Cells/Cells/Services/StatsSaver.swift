//
//  StatsSaver.swift
//  Cells
//
//  Created by Gustavo De Mello Crivelli on 01/02/18.
//  Copyright © 2018 Gustavo De Mello Crivelli. All rights reserved.
//

import Foundation

protocol StatSaverProtocol {
    func getBestScore() -> Int
    func getBestCombo() -> Int
    func getTotalHexagons() -> Int
    func updateBestScore(score: Int) -> Bool
    func updateBestCombo(combo: Int) -> Bool
    func updateTotalHexagons(by: Int)

}

// Service for saving the score locally and into GameCenter too, probably
class StatSaverService : StatSaverProtocol {
    
    private let defaults = UserDefaults.standard
    
    /// MARK: Properties
    func getBestScore() -> Int {
        return defaults.object(forKey: "BestScore") as! Int
    }
    
    func getBestCombo() -> Int {
        return defaults.object(forKey: "BestCombo") as! Int
    }
    
    func getTotalHexagons() -> Int {
        return defaults.object(forKey: "TotalHexagons") as! Int
    }
    
    func updateBestScore(score: Int) -> Bool {
        let prevBest = defaults.object(forKey: "BestScore") as? Int ?? 0
        if score > prevBest {
            defaults.set(score, forKey: "BestScore")
            return true
        }
        return false
    }
    
    func updateBestCombo(combo: Int) -> Bool {
        let prevBest = defaults.object(forKey: "BestCombo") as? Int ?? 0
        if combo > prevBest {
            defaults.set(combo, forKey: "BestCombo")
            return true
        }
        return false
    }
    
    func updateTotalHexagons(by hexagonsTapped: Int) {
        let total = defaults.object(forKey: "TotalHexagons") as! Int
        defaults.set(total + hexagonsTapped, forKey: "TotalHexagons")
    }
    
}
