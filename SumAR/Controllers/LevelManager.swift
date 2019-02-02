//
//  LevelManager.swift
//  SumAR
//
//  Created by Álvaro Ávalos Hernández on 1/8/19.
//  Copyright © 2019 OliverPérez. All rights reserved.
//

import Foundation
import GameplayKit

// MARK: - Variables
struct Level {
    var goal: Int
    var maxAddend: Int
    var minAddend: Int
}

var levels: [Level] = []

// MARK: - Get data by level
func numberGenerator(){
    for _ in 0..<10{
        levels.append(Level(goal: 10, maxAddend: 9, minAddend: 1))
    }
}

// MARK: - Send data to screen
func randomSum(_ currentLevel: Int) -> String {
    let randomChoice = GKRandomDistribution(lowestValue: levels[currentLevel].minAddend, highestValue: (levels[currentLevel].maxAddend + 1))
    let addendOne: Int = randomChoice.nextInt()
    let addendTwo: Int = levels[currentLevel].goal - addendOne
    let sum: String = "\(addendOne) + \(addendTwo)"
    return sum
}