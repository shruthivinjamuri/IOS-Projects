//
//  WeightViewController.swift
//  StrongLifts
//
//  Created by Shruthi Vinjamuri on 11/6/16.
//  Copyright © 2016 Shruthi Vinjamuri. All rights reserved.
//

import UIKit

class WeightViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {

    var pickerWeightsDataSource: [String] = [];
    var pickerUnitsDataSource = ["LB", "KG"]
    var initialWeight: Int = 150;
    var initialUnits: String = "LB"
    
    var updatedWeight: Int = 150
    var updatedUnits: String = "LB"
    
    var delegate: WeightsChanged?
    
    @IBOutlet weak var lblWeightDiff: UILabel!
    @IBOutlet weak var pickerView: UIPickerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.pickerView.dataSource = self;
        self.pickerView.delegate = self;
        loadSource()
        self.pickerView.selectRow(indexForValue(self.initialWeight) + (self.pickerWeightsDataSource.count * 50), inComponent: 0, animated: false)
        self.pickerView.selectRow(self.initialUnits == "LB" ? 0 : 1, inComponent: 1, animated: false)
        lblWeightDiff.text = "+0LB / +0KG"
    }
    
    fileprivate func indexForValue(_ value: Int) -> Int {
        // all the values are multiples of 5, a value's index will be value/5 from initial value
        // Since initial value is 45 we have to remove 9 indices from the list
        return ((value/5) - 9)
    }
    
    fileprivate func loadSource() {
        var val = 45
        while val <= 300 {
            pickerWeightsDataSource.append(String(val))
            val += 5
        }
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2 // For Weights and Units
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if component == 0 {
            return pickerWeightsDataSource.count * 100
        }
        else {
            return pickerUnitsDataSource.count
        }
    }
    
    @IBAction func onClickOKButton(_ sender: AnyObject) {
        if let caller = self.delegate {
                caller.UserChangedWeights(self.updatedWeight, unit: self.updatedUnits)
        }
        
       self.dismiss(animated: true, completion: {})
    }
    
    
    @IBAction func onClickCancelButton(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: {})
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if component == 0 {
            return pickerWeightsDataSource[row % pickerWeightsDataSource.count]
        }
        else {
            return pickerUnitsDataSource[row]
        }
    }
    
    func convertLbToKg(_ weight: Int) -> Int {
        let ret = Double(weight)/2.20462
        return Int(ret)
    }
    
    func convertKgToLb(_ weight: Int) -> Int {
        let ret = Double(weight) * 2.20462
        return Int(ret)
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow: Int, inComponent: Int) {
        if inComponent == 0 {
            self.updatedWeight = Int(pickerWeightsDataSource[didSelectRow % pickerWeightsDataSource.count])!
            self.updatedUnits = pickerUnitsDataSource[pickerView.selectedRow(inComponent: 1)]
        }
        else {
            self.updatedUnits = pickerUnitsDataSource[didSelectRow]
            self.updatedWeight = Int(pickerWeightsDataSource[pickerView.selectedRow(inComponent: 0) % pickerWeightsDataSource.count])!
        }
        
        var lbs: Int = 0
        var kgs: Int = 0
        var sign: Character = "-"
        if self.updatedUnits == "LB" {
            if self.initialUnits == "LB" {
                if self.updatedWeight >= self.initialWeight {
                    sign = "+"
                }
                lbs = abs(self.updatedWeight-self.initialWeight)
                kgs = convertLbToKg(lbs)
            }
            else {
                let initWeightLb = convertKgToLb(self.initialWeight)
                    if self.updatedWeight >= initWeightLb {
                         sign = "+"
                    }
                lbs = abs(self.updatedWeight-initWeightLb)
                kgs = convertLbToKg(lbs)
                
            }
        }
        else { // Change everything based on KG
            if self.initialUnits == "KG" {
                if self.updatedWeight >= self.initialWeight {
                    sign = "+"
                }
                kgs = abs(self.updatedWeight-self.initialWeight)
                lbs = convertKgToLb(kgs)
            }
            else {
                let initWeightKg = convertLbToKg(self.initialWeight)
                    if self.updatedWeight >= initWeightKg {
                        sign = "+"
                    }
                kgs = abs(self.updatedWeight-initWeightKg)
                lbs = convertLbToKg(kgs)
            }
        }
        lblWeightDiff.text = "\(sign)\(lbs)LB / \(sign)\(kgs)KG"
    }
}
