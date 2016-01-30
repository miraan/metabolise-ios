//
//  ViewController.swift
//  Metabolise
//
//  Created by Miraan on 30/01/2016.
//  Copyright © 2016 Miraan. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {
    
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var hoursLabel: UILabel!
    @IBOutlet weak var mealTextField: UITextField!
    @IBOutlet weak var voiceButton: UIButton!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var energyLevelView: UIView!
    
    var energyLevel: EnergyLevelView!
    var updateTimer: NSTimer!
    var firstAppear: Bool!

    override func viewDidLoad() {
        super.viewDidLoad()
        firstAppear = true
        
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

