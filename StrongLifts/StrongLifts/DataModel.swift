//
//  DataModel.swift
//  StrongLifts
//
//  Created by Shruthi Vinjamuri on 11/5/16.
//  Copyright © 2016 Shruthi Vinjamuri. All rights reserved.
//

import Foundation

enum Units {
    case pounds
    case kilograms
}

enum Exercise {
    case squat
    case bench
    case deadlifts
    case bodyWeight
}

class Workout {
    let index: Int
    var data: [Exercise: (weight: Int, unit: Units)]
    var squatsSet = Array<Int>(repeating: 0, count: 5)
    var benchSet = Array<Int>(repeating: 0, count: 5)
    var deadlifts: Int = 0
    
    init(index: Int, data: [Exercise: (weight: Int, unit: Units)]) {
        self.index = index
        self.data = data
    }
    
    convenience init(index: Int, previous: Workout) {
        var data = [Exercise: (weight: Int, unit: Units)]()
        data[Exercise.bodyWeight] = previous.getWeightUnits(Exercise.bodyWeight)
        var weightUnits = previous.getWeightUnits(Exercise.squat)
        if previous.completeSquat() {
            weightUnits.weight += weightUnits.unit == .pounds ? 10 : 5
        }
        data[Exercise.squat] = weightUnits
        
        weightUnits = previous.getWeightUnits(Exercise.bench)
        if previous.completeBench() {
            weightUnits.weight += weightUnits.unit == .pounds ? 10 : 5
        }
        data[Exercise.bench] = weightUnits
        
        weightUnits = previous.getWeightUnits(Exercise.deadlifts)
        if previous.completeDeadlifts() {
            weightUnits.weight += weightUnits.unit == .pounds ? 10 : 5
        }
        data[Exercise.deadlifts] = weightUnits
        self.init(index: index, data: data)
    }
    
    convenience init(index: Int) {
        var data = [Exercise: (weight: Int, unit: Units)]()
        data[Exercise.bodyWeight] = (160, Units.pounds)
        data[Exercise.squat] = (215, Units.pounds)
        data[Exercise.bench] = (135, Units.pounds)
        data[Exercise.deadlifts] = (250, Units.pounds)
        self.init(index: index, data: data)
    }
    
    internal func completeSquat() -> Bool {
        return isWorkoutComplete(squatsSet)
    }
    
    internal func completeBench() -> Bool {
        return isWorkoutComplete(benchSet)
    }
    
    internal func completeDeadlifts() -> Bool {
        return deadlifts == 5
    }
    
    fileprivate func isWorkoutComplete(_ workout: [Int]) -> Bool {
        for idx in 0..<workout.count {
            if workout[idx] != 5 {
                return false
            }
        }
        return true
    }
    
    internal func toString() -> String {
        var str: String = ""
        str += textifyWorkout(squatsSet) + textifyUnits(data[.squat]!) + "\n"
        str += textifyWorkout(benchSet) + textifyUnits(data[.bench]!) + "\n"
        str += (deadlifts == 5 ? "1x5" : deadlifts == 0 ? "-" : String(deadlifts)) + " " + textifyUnits(data[.deadlifts]!)
        return str;
    }
    
    fileprivate func textifyWorkout(_ workout: [Int]) -> String {
        if isWorkoutComplete(workout) {
           return "5x5 "
        }
        var reps: String = ""
        for (idx, val) in workout.enumerated() {
            reps += val != 0 ? String(val) : "-"
            reps += idx != 4 ? "/" : " "
        }
        return reps
    }
    
    internal func textifyUnits(_ value: (Int, Units)) -> String {
        return String(value.0) + toString(value.1)
    }
    
    fileprivate func toString(_ unit: Units) -> String {
        switch unit {
        case .pounds:
            return "LB"
        case .kilograms:
            return "KG"
        }
    }
    
    internal func getWeightUnits(_ exercise: Exercise) -> (weight: Int, unit: Units) {
        return data[exercise]!
    }
}
