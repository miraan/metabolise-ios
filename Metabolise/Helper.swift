//
//  AppState.swift
//  Metabolise
//
//  Created by Miraan on 30/01/2016.
//  Copyright © 2016 Miraan. All rights reserved.
//

import UIKit

class Helper {
    
    static let secondsPerDay: Int! = 60 * 60 * 24
    
    class func getTime() -> String {
        let date = NSDate()
        let calendar = NSCalendar.currentCalendar()
        let components = calendar.components(NSCalendarUnit.Hour.union(NSCalendarUnit.Minute).union(NSCalendarUnit.Second), fromDate: date)
        return String(format: "%02d:%02d:%02d", arguments: [components.hour, components.minute, components.second])
    }
    
    class func getStartOfDay() -> NSDate {
        let now = NSDate()
        let calendar = NSCalendar.currentCalendar()
        let components = calendar.components(NSCalendarUnit.Year.union(NSCalendarUnit.Month).union(NSCalendarUnit.Day), fromDate: now)
        components.hour = State.get()!.startOfDayHour
        components.minute = State.get()!.startOfDayMinute
        return calendar.dateFromComponents(components)!
    }
    
    class func getTimeLeftInDay() -> NSDate {
        let now = NSDate()
        let calendar = NSCalendar.currentCalendar()
        let diffComponents = calendar.components(NSCalendarUnit.Hour.union(NSCalendarUnit.Minute), fromDate: getStartOfDay(), toDate: now, options: NSCalendarOptions.MatchFirst)
        return calendar.dateFromComponents(diffComponents)!
    }
    
    class func getTimeLeftInDayText() -> String {
        let calendar = NSCalendar.currentCalendar()
        let diffComponents = calendar.components(NSCalendarUnit.Hour.union(NSCalendarUnit.Minute), fromDate: getTimeLeftInDay())
        let hoursLeft = 24 - diffComponents.hour
        let minutesLeft = 60 - diffComponents.minute
        if (hoursLeft < 1) {
            return "\(minutesLeft) minutes left today"
        } else {
            return "\(hoursLeft) hours left today"
        }
    }
    
    class func dateOfBirthFromAge(age: Int) -> NSDate {
        let calendar = NSCalendar.currentCalendar()
        let components = calendar.components(NSCalendarUnit.Day.union(NSCalendarUnit.Month).union(NSCalendarUnit.Year), fromDate: NSDate())
        components.year -= age
        return calendar.dateFromComponents(components)!
    }
    
    class func displayPopup(text: String, vc: UIViewController) {
        let alertController = UIAlertController(title: text, message: nil, preferredStyle: .Alert)
        let okAction = UIAlertAction(title: "OK", style: .Default) { (action) in
            
        }
        alertController.addAction(okAction)
        vc.presentViewController(alertController, animated: true, completion: nil)
    }
    
    class func getCalories() -> Int {
        return getConsumedCalories() - getBurnedCalories()
    }
    
    class func getBurnedCalories() -> Int {
        let secondsThroughDay = abs(Int(getStartOfDay().timeIntervalSinceNow))
        let fractionOfDayComplete = Double(secondsThroughDay) / Double(secondsPerDay)
        let burnedCalories = Int(Double(getBurnedCaloriesPerDay()) * fractionOfDayComplete)
        return burnedCalories
    }
    
    class func getBurnedCaloriesPerDay() -> Int {
        return Int(getBasalMetabolicRate() * getActivityFactor())
    }
    
    class func getBasalMetabolicRate() -> Double { // calories burned at rest in one day
        let state = State.get()!
        if state.sex == State.Sex.Female {
            let a = 9.6 * Double(state.weight)
            let b = 1.8 * Double(state.height)
            let c = 4.7 * Double(state.age)
            return 655 + a + b - c
            
        } else {
            let a = 13.7 * Double(state.weight)
            let b = 5 * Double(state.height)
            let c = 6.8 * Double(state.age)
            return 66 + a + b - c
            
        }
    }
    
    class func getActivityFactor() -> Double { // factor to multiply BMR by to get TDEE
        return 1.2
    }
    
    class func getConsumedCalories() -> Int {
        let state = State.get()!
        var total = 0
        for meal in state.meals {
            total += meal.calories * meal.quantity
        }
        return total
    }
    
}