//
//  ViewController.swift
//  Metabolise
//
//  Created by Miraan on 30/01/2016.
//  Copyright © 2016 Miraan. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var hoursLabel: UILabel!
    @IBOutlet weak var mealTextField: UITextField!
    @IBOutlet weak var voiceButton: UIButton!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var energyLevelView: UIView!
    @IBOutlet weak var quantityPickerView: UIPickerView!
    @IBOutlet weak var unitsPickerView: UIPickerView!
    @IBOutlet weak var caloriesLabel: UILabel!
    
    var quantityPickerData: [[String]]!
    var unitsPickerData: [[String]]!
    
    var energyLevel: EnergyLevelView!
    var updateTimer: NSTimer!
    var firstAppear: Bool!
    var queryDisabled: Bool = false
    var queryTimer: NSTimer!
    var unitsSticky: Bool = false
    
    var meal: State.Meal? {
        didSet {
            caloriesLabel.text = "\(meal!.calories * meal!.quantity) cal"
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        firstAppear = true
        
        setup()
    }
    
    func setup() {
        quantityPickerView.delegate = self
        quantityPickerView.dataSource = self
        unitsPickerView.delegate = self
        unitsPickerView.dataSource = self
        
        var quantities: [String] = []
        for i in 1...9 {
            quantities.append("\(i)")
        }
        quantityPickerData = []
        quantityPickerData.append(quantities)
        
        unitsPickerData = []
        unitsPickerData.append(["serving"])
        
        caloriesLabel.text = ""
        
        configureBackButton()
    }
    
    func configureBackButton() {
        navigationItem.hidesBackButton = true
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Back", style: UIBarButtonItemStyle.Plain, target: self, action: "didTapBackButton")
    }
    
    func update() {
        timeLabel.text = Helper.getTime()
        let hoursLabelText = Helper.getTimeLeftInDayText()
        if (hoursLabel.text != hoursLabelText) {
            hoursLabel.text = hoursLabelText
        }
        
        let calories = Helper.getCalories()
        if (energyLevel.calories != calories) {
            energyLevel.calories = calories
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        if State.get() == nil {
            // first run
            performSegueWithIdentifier("HomeToSettingsTable", sender: nil)
            return
        }
        
        if firstAppear == true {
            energyLevel = EnergyLevelView(parent: energyLevelView)
            energyLevelView.addSubview(energyLevel)
            
            updateTimer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: "update", userInfo: nil, repeats: true)
        }
        firstAppear = false
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        if pickerView == quantityPickerView {
            return quantityPickerData.count
        } else {
            return unitsPickerData.count
        }
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == quantityPickerView {
            return quantityPickerData[component].count
        } else {
            return unitsPickerData[component].count
        }
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == quantityPickerView {
            return quantityPickerData[component][row]
        } else {
            return unitsPickerData[component][row]
        }
    }
    
    @IBAction func didChangeMealTextField(sender: AnyObject) {
        if mealTextField.text == nil || mealTextField.text == "" {
            unitsSticky = false
        }
        updateMeal()
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        unitsSticky = true
        updateMeal()
    }
    
    func updateMeal() {
        if (queryDisabled) {
            return
        }
        
        queryDisabled = true
        print("querying disabled")
        queryTimer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: "didFireQueryTimer", userInfo: nil, repeats: false)
        
        query()
    }
    
    func didFireQueryTimer() {
        queryDisabled = false
        print("querying enabled")
        query()
    }

    func query() {
        let text = mealTextField.text!
        let units = unitsPickerData[0][unitsPickerView.selectedRowInComponent(0)]
        let query = "\(text) \(units)"
        let quantity = quantityPickerView.selectedRowInComponent(0) + 1
        
        Backend.query(query) { (success, calories, units, queryError) -> Void in
            if success {
                let meal = State.Meal(mealName: query, quantity: quantity, calories: calories, timeAdded: NSDate())
                self.meal = meal
                self.updateUnits(units!)
                
            } else {
                print("query error: \(queryError)")
            }
        }
    }
    
    func updateUnits(units: String) {
        if unitsSticky {
            return
        }
        
        let currentUnits = unitsPickerData[0][unitsPickerView.selectedRowInComponent(0)]
        if units != currentUnits {
            if !unitsPickerData[0].contains(units) {
                unitsPickerData[0].append(units)
            }
            unitsPickerView.reloadAllComponents()
            
            let row = unitsPickerData[0].indexOf(units)!
            unitsPickerView.selectRow(row, inComponent: 0, animated: true)
            updateMeal()
        }
    }
    
    @IBAction func didTapAddButton(sender: AnyObject) {
        if let meal = self.meal {
            if let state = State.get() {
                state.meals.append(meal)
                state.save()
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

