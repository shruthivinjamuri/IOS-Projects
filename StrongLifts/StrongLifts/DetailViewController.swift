//
//  DetailViewController.swift
//  StrongLifts
//
//  Created by Shruthi Vinjamuri on 11/5/16.
//  Copyright © 2016 Shruthi Vinjamuri. All rights reserved.
//

import UIKit

protocol WeightsChanged {
    func UserChangedWeights(_ newWeight: Int, unit: String)
}

class DetailViewController: UIViewController, WeightsChanged {
    
    var currentlyEditedButton: UIButton! = nil
    
    @IBOutlet weak var deadliftReps: UIButton!
    @IBOutlet var benchReps: [UIButton]!
    @IBOutlet var squatReps: [UIButton]!
    
    
    @IBOutlet weak var squatWeight: UIButton!
    @IBOutlet weak var benchWeight: UIButton!
    @IBOutlet weak var deadliftWeight: UIButton!
    @IBOutlet weak var bodyWeight: UIButton!

    var detailItem: Workout? {
        didSet {
            self.configureView()
        }
    }
    
    var delegate: RepsUpdated?

    func configureView() {

        // Update the user interface for the detail item.
        if let workout = self.detailItem {
            if let squatReps = self.squatReps {
                // update the squats view
                for (index, value) in workout.squatsSet.enumerated() {
                    updateButton(squatReps[index], value: value)
                }
            }
            
            if let benchReps = self.benchReps {
                //update the bench view
                for (index, value) in workout.benchSet.enumerated() {
                    updateButton(benchReps[index], value: value)
                }
            }
            
            // update the deadlift value
            if let deadliftReps = self.deadliftReps {
                updateButton(deadliftReps, value: workout.deadlifts)
            }
            
            // Update weight button values
            if let squatWeight = self.squatWeight {
            squatWeight.setTitle(String(workout.data[Exercise.squat]!.weight) + toString(workout.data[Exercise.squat]!.unit) , for: UIControlState())
            }
            
            if let benchWeight = self.benchWeight {
                benchWeight.setTitle(String(workout.data[Exercise.bench]!.weight) + toString(workout.data[Exercise.bench]!.unit) , for: UIControlState())
            }
            
            if let deadliftWeight = self.deadliftWeight {
                deadliftWeight.setTitle(String(workout.data[Exercise.deadlifts]!.weight) + toString(workout.data[Exercise.deadlifts]!.unit) , for: UIControlState())
            }
            
            if let bodyWeight = self.bodyWeight {
                bodyWeight.setTitle(String(workout.data[Exercise.bodyWeight]!.weight) + toString(workout.data[Exercise.bodyWeight]!.unit) , for: UIControlState())
            }
            
        }
        else {
            
            let bounds = UIScreen.main.bounds
            let screen = UIView()
            screen.frame = CGRect(x: 0, y: 0, width: bounds.width, height: bounds.height)
            screen.backgroundColor = UIColor.white
            
            let label = UILabel()
            label.center = screen.center;
            
            label.frame = CGRect(x: 0, y: 0, width: bounds.width, height: bounds.height)
            label.text = "Please select a Workout"
            label.textAlignment = NSTextAlignment.center
            label.textColor = UIColor.red
            label.font = UIFont(name: "Palatino-Italic", size: 20)
            
            screen.addSubview(label)
            self.view.addSubview(screen)
        }
    }
    
    fileprivate func toString(_ unit: Units) -> String {
        switch unit {
        case .pounds:
            return "LB"
        case .kilograms:
            return "KG"
        }
    }
    
    fileprivate func updateButton(_ btn: UIButton, value: Int) {
        var title: String = ""
        var imgFile: String = "grey.png"
        
        if value > 0 && value < 6 {
            title = String(value)
            imgFile = "red.png"
        }
        
        btn.setTitle(title, for: UIControlState())
        btn.setBackgroundImage(UIImage(named: imgFile), for: UIControlState())

    }

    func UserChangedWeights(_ newWeight: Int, unit: String) {
        currentlyEditedButton!.setTitle(String(newWeight) + unit, for: UIControlState())
        if let workout = self.detailItem {
            let exercise = getExerciseEnum(currentlyEditedButton.tag)
            workout.data[exercise]?.weight = newWeight
            workout.data[exercise]?.unit = UnitEnum(unit)
        }
        
        if let delegate = self.delegate {
            delegate.UserUpdatedReps()
        }
    }
    
    fileprivate func UnitEnum(_ unit: String) -> Units {
        switch(unit) {
            case "KG": return Units.kilograms
            case "LB": return Units.pounds
        default: return Units.pounds
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.configureView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    fileprivate func parseWeightUnits(_ wtUnitPair: String) -> (weight: Int, unit: String) {
        //remove the last two characters which represent units
        let index = wtUnitPair.index(wtUnitPair.endIndex, offsetBy: -2)
        let unit = wtUnitPair.substring(from: index	)
        // get the characters except for the last two characters
        let weight = wtUnitPair.substring(to: index)
        
        // return a tuple of weight and units
        return (Int(weight)!, unit)
    }

    // MARK: - Segues
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showPopOver" {
            let controller = segue.destination as! WeightViewController
            self.currentlyEditedButton = sender as! UIButton
            controller.delegate = self
            let wtUnitPair = parseWeightUnits(self.currentlyEditedButton!.currentTitle!)
            controller.initialWeight = wtUnitPair.weight
            controller.initialUnits = wtUnitPair.unit
        }
    }
    
    
    @IBAction func repsButtonClick(_ sender: UIButton) {
        let superViewTag = sender.superview!.tag
        let viewTag = sender.tag
        let oldValue = getValue(superViewTag, viewTag: viewTag)
        var newValue = 0
        if oldValue < 1 {
            newValue = 5
        }
        else if oldValue < 6 {
            newValue = oldValue - 1
        }
        updateButton(sender, value: newValue)
        setValue(superViewTag, viewTag: viewTag, value: newValue)
        
        if let delegate = self.delegate {
            delegate.UserUpdatedReps()
        }
    }
    
    fileprivate func setValue(_ superViewTag: Int, viewTag: Int, value: Int) {
        switch superViewTag {
        case 0:
            self.detailItem!.squatsSet[viewTag] = value
        case 1:
            self.detailItem!.benchSet[viewTag] = value
        case 2:
            self.detailItem!.deadlifts = value
        default:
            break
        }

    }
    
    fileprivate func getValue(_ superViewTag: Int, viewTag: Int) -> Int {
        switch superViewTag {
        case 0:
            return self.detailItem!.squatsSet[viewTag]
        case 1:
            return self.detailItem!.benchSet[viewTag]
        case 2:
            return self.detailItem!.deadlifts
        default:
            return -1
        }
    }
    
    
    fileprivate func getExerciseEnum(_ tag: Int) -> Exercise {
        switch(tag) {
        case 0:
            return Exercise.squat
        case 1:
            return Exercise.bench
        case 2:
            return Exercise.deadlifts
        case 3:
            return Exercise.bodyWeight
        default:
            return Exercise.squat
        }
    }


}

