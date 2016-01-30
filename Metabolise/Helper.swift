//
//  AppState.swift
//  Metabolise
//
//  Created by Miraan on 30/01/2016.
//  Copyright © 2016 Miraan. All rights reserved.
//

import Foundation

class Helper {
    
    class Meal {
        var mealName: String!
        var calories: Int!
        var timeAdded: NSDate!
        
        init(mealName: String!, calories: Int!, timeAdded: NSDate) {
            self.mealName = mealName
            self.calories = calories
            self.timeAdded = timeAdded
        }
    }
    
    class State {
        static let stateKey = "state"
        
        var meals: [Meal]!
        var weight: Int! // in kg
        var height: Int! // in cm
        var age: Int!
        var sex:
        var setupTime: NSDate!
    }
    
    static let secondsPerDay: Int! = 60 * 60 * 24
    static var startOfDayHour: Int! = 8
    static var startOfDayMinute: Int! = 30
    
    class func hasState() -> Bool {
        return getState() != nil
    }
    
    class func saveState() {
        if state == nil {
            print("error saving state: state is nil")
            return
        }
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setObject(state, forKey: stateKey)
    }
    
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
        components.hour = startOfDayHour
        components.minute = startOfDayMinute
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
        return getBasalMetabolicRate() + getExerciseRate()
    }
    
    class func getBasalMetabolicRate() -> Int { // calories burned at rest in one day
        
    }
    
    class func getExerciseRate() -> Int { // calories burned from normal exercise in one day
        
    }
    
    class func getConsumedCalories() -> Int {
        return 0
    }
    
}