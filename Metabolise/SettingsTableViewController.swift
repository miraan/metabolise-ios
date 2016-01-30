//
//  SettingsTableViewController.swift
//  Metabolise
//
//  Created by Miraan on 30/01/2016.
//  Copyright © 2016 Miraan. All rights reserved.
//

import UIKit

class SettingsTableViewController: UITableViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    
    @IBOutlet weak var weightTextField: UITextField!
    @IBOutlet weak var heightTextField: UITextField!
    @IBOutlet weak var ageTextField: UITextField!
    @IBOutlet weak var sexPickerView: UIPickerView!
    @IBOutlet weak var startOfDayPickerView: UIPickerView!
    
    var sexPickerData: [[String]]!
    var startOfDayPickerData: [[String]]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
    }
    
    func setup() {
        sexPickerView.delegate = self
        sexPickerView.dataSource = self
        startOfDayPickerView.delegate = self
        startOfDayPickerView.dataSource = self
        
        sexPickerData = [["male", "female"]]
        
        var hours: [String] = []
        for i in 0...23 {
            hours.append(String(format: "%02d", arguments: [i]))
        }
        var minutes: [String] = []
        for i in 0...59 {
            minutes.append(String(format: "%02d", arguments: [i]))
        }
        startOfDayPickerData = []
        startOfDayPickerData.append(hours)
        startOfDayPickerData.append(minutes)
        
        startOfDayPickerView.selectRow(7, inComponent: 0, animated: false)
        startOfDayPickerView.selectRow(0, inComponent: 1, animated: false)
        
        populate()
    }
    
    func populate() {
        if let state = State.get() {
            weightTextField.text = "\(state.weight)"
            ageTextField.text = "\(state.age)"
            heightTextField.text = "\(state.height)"
            if state.sex == State.Sex.Male {
                sexPickerView.selectRow(0, inComponent: 0, animated: false)
            } else {
                sexPickerView.selectRow(1, inComponent: 0, animated: false)
            }
            startOfDayPickerView.selectRow(state.startOfDayHour, inComponent: 0, animated: false)
            startOfDayPickerView.selectRow(state.startOfDayMinute, inComponent: 1, animated: false)
        }
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        if pickerView == sexPickerView {
            return sexPickerData.count
        } else {
            return startOfDayPickerData.count
        }
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == sexPickerView {
            return sexPickerData[component].count
        } else {
            return startOfDayPickerData[component].count
        }
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == sexPickerView {
            return sexPickerData[component][row]
        } else {
            return startOfDayPickerData[component][row]
        }
    }
    
    func formError() -> String? {
        if weightTextField.text == nil || weightTextField.text == "" {
            return "You must enter your weight."
        }
        if heightTextField.text == nil || heightTextField.text == "" {
            return "You must enter your height."
        }
        if ageTextField.text == nil || ageTextField.text == "" {
            return "You must enter your age."
        }
        return nil
    }
    
    @IBAction func didTapSaveButton(sender: AnyObject) {
        if let error = formError() {
            Helper.displayPopup(error, vc: self)
            return
        }
        
        var state = State.get()
        if state == nil {
            state = State()
            state!.meals = []
            state!.setupTime = NSDate()
        }
        
        state!.weight = Int(weightTextField.text!)
        state!.height = Int(heightTextField.text!)
        state!.dob = Helper.dateOfBirthFromAge(Int(ageTextField.text!)!)
        state!.sex = State.Sex(rawValue: sexPickerData[0][sexPickerView.selectedRowInComponent(0)])
        state!.startOfDayHour = Int(startOfDayPickerData[0][startOfDayPickerView.selectedRowInComponent(0)])
        state!.startOfDayMinute = Int(startOfDayPickerData[1][startOfDayPickerView.selectedRowInComponent(1)])
        
        state!.save()
        
        self.navigationController!.popViewControllerAnimated(true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
