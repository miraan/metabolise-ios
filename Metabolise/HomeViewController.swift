//
//  ViewController.swift
//  Metabolise
//
//  Created by Miraan on 30/01/2016.
//  Copyright © 2016 Miraan. All rights reserved.
//

import UIKit
import SpeechKit

class HomeViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate, SKTransactionDelegate {
    
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var hoursLabel: UILabel!
    @IBOutlet weak var mealTextField: UITextField!
    @IBOutlet weak var voiceButton: UIButton!
    @IBOutlet weak var energyLevelView: UIView!
    @IBOutlet weak var quantityPickerView: UIPickerView!
    @IBOutlet weak var unitsPickerView: UIPickerView!
    @IBOutlet weak var caloriesLabel: UILabel!
    @IBOutlet weak var mealLogButton: UIButton!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    var micSelected: Bool = false
    
    var quantityPickerData: [[String]]!
    var unitsPickerData: [[String]]!
    
    var energyLevel: EnergyLevelView!
    var updateTimer: NSTimer!
    var firstAppear: Bool!
    var queryDisabled: Bool = false
    var queryTimer: NSTimer!
    var unitsSticky: Bool = false
    
    var skSession: SKSession!
    var skTransaction: SKTransaction?
    let recognitionType = SKTransactionSpeechTypeSearch
    let language = "eng-USA"
    
    var endpointer: SKTransactionEndOfSpeechDetection = UInt(SKTransactionEndOfSpeechDetectionLong)
    
    var meal: State.Meal? {
        didSet {
            if meal != nil {
                caloriesLabel.text = "\(meal!.calories * meal!.quantity) cal"
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        Helper.themeFont = caloriesLabel.font
        
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
        unitsPickerData.append(["serving",
            "slice",
            "sandwich",
            "plating",
            "salad",
            "cup",
            "portion",
            "piece",
            "bowl",
            "large",
            "small",
            "ml",
            "regular",
            "taco",
            "wrap",
            "cookie",
            "burrito",
            "pizza",
            "muffin",
            "bagel",
            "burger",
            "platter",
            "tall cup",
            "biscuit",
            "roll",
            "g",
            "oz",
            "fl oz"])
        
        mealTextField.placeholder = "Meal description"
        mealTextField.delegate = self
        caloriesLabel.text = "0 cal"
        
        let tapper = UITapGestureRecognizer(target: self, action: "handleSingleTap:")
        tapper.cancelsTouchesInView = true
        view.addGestureRecognizer(tapper)
        
        skSession = SKSession(URL: NSURL(string: SpeechRecognition.SKSServerUrl), appToken: SpeechRecognition.SKSAppKey)
        if skSession == nil {
            Helper.displayPopup("Error initialising speech recognition.", vc: self)
        }
    }
    
    func recognize() {
        micSelected = true
        skTransaction = skSession.recognizeWithType(recognitionType, detection: endpointer, language: language, delegate: self)
    }
    
    func stopRecording() {
        if skTransaction == nil {
            print("stoprecording error: no sktransaction")
            return
        }
        skTransaction!.stopRecording()
        micSelected = false
    }
    
    func cancel() {
        if skTransaction == nil {
            return
        }
        skTransaction!.cancel()
    }
    
    func transactionDidBeginRecording(transaction: SKTransaction!) {
        print("transactionDidBeginRecording")
        mealTextField.text = ""
        mealTextField.placeholder = "Listening..."
    }
    
    func transactionDidFinishRecording(transaction: SKTransaction!) {
        print("transactionDidFinishRecording")
        mealTextField.text = ""
        mealTextField.placeholder = "Processing..."
    }
    
    func transaction(transaction: SKTransaction!, didReceiveRecognition recognition: SKRecognition!) {
        print("received recognition: " + recognition.text)
        mealTextField.text = recognition.text
        mealTextField.becomeFirstResponder()
        updateMeal()
    }
    
    func transaction(transaction: SKTransaction!, didReceiveServiceResponse response: [NSObject : AnyObject]!) {
        print("didReceiveServiceResponse: \(response)")
    }
    
    func transaction(transaction: SKTransaction!, didFinishWithSuggestion suggestion: String!) {
        print("didFinishWithSuggestion \(suggestion)")
    }
    
    func transaction(transaction: SKTransaction!, didFailWithError error: NSError!, suggestion: String!) {
        print("transaction didFailWithError: \(error)")
        mealTextField.text = ""
        mealTextField.placeholder = "Meal description"
    }
    
    func handleSingleTap(sender: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        didAddMeal()
        return true
    }
    
    func update() {
        timeLabel.text = Helper.getTime()
        let hoursLabelText = (isInDailyMode() ? Helper.getTimeLeftInDayText() : Helper.getTimeLeftInWeekText())
        if (hoursLabel.text != hoursLabelText) {
            hoursLabel.text = hoursLabelText
        }
        
        let calories = (isInDailyMode() ? Helper.getDailyCalories() : Helper.getWeeklyCalories())
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
    
    override func viewWillAppear(animated: Bool) {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    override func viewWillDisappear(animated: Bool) {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func keyboardWillShow(notification: NSNotification) {
        let keyboardSize = (notification.userInfo![UIKeyboardFrameBeginUserInfoKey]!.CGRectValue).size
        UIView.animateWithDuration(0.3) {
            var f = self.view.frame
            f.origin.y = -keyboardSize.height
            self.view.frame = f
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        UIView.animateWithDuration(0.3) {
            var f = self.view.frame
            f.origin.y = CGFloat(0)
            self.view.frame = f
        }
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
        if text == "" {
            return
        }
        
        let units = unitsPickerData[0][unitsPickerView.selectedRowInComponent(0)]
        let query = "\(text) \(units)"
        let quantity = quantityPickerView.selectedRowInComponent(0) + 1
        
        Backend.query(query) { (success, calories, newUnits, queryError) -> Void in
            if success {
                let meal = State.Meal(mealName: text, units: units, quantity: quantity, calories: calories, timeAdded: NSDate())
                self.meal = meal
                self.updateUnits(newUnits!)
                
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
    
    func didAddMeal() {
        if let meal = self.meal {
            if let state = State.get() {
                state.meals.append(meal)
                state.save()
                
                Helper.toast("Meal Added")
                
                resetForm()
            }
        }
    }
    
    func resetForm() {
        mealTextField.text = ""
        unitsPickerView.selectRow(0, inComponent: 0, animated: true)
        quantityPickerView.selectRow(0, inComponent: 0, animated: true)
        caloriesLabel.text = "0 cal"
        meal = nil
    }
    
    @IBAction func didChangeSegmentedControl(sender: AnyObject) {
        update()
    }
    
    func isInDailyMode() -> Bool {
        return segmentedControl.selectedSegmentIndex == 0
    }
    
    @IBAction func didTapMicrophoneButton(sender: AnyObject) {
        recognize()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

