//
//  State.swift
//  Metabolise
//
//  Created by Miraan on 30/01/2016.
//  Copyright © 2016 Miraan. All rights reserved.
//

import Foundation

class State: NSObject, NSCoding {
    override init() {
        super.init()
    }
    
    static let defaultsKey = "state"
    
    enum Sex: String {
        case Male = "male"
        case Female = "female"
    }
    
    class Meal: NSObject, NSCoding {
        let mealNameKey = "mealName"
        var mealName: String!
        let caloriesKey = "calories"
        var calories: Int!
        let timeAddedKey = "timeAdded"
        var timeAdded: NSDate!
        
        init(mealName: String!, calories: Int!, timeAdded: NSDate) {
            self.mealName = mealName
            self.calories = calories
            self.timeAdded = timeAdded
        }
        
        func encodeWithCoder(aCoder: NSCoder) {
            aCoder.encodeObject(mealName, forKey: mealNameKey)
            aCoder.encodeObject(calories, forKey: caloriesKey)
            aCoder.encodeObject(timeAdded, forKey: timeAddedKey)
        }
        
        required init?(coder aDecoder: NSCoder) {
            mealName = aDecoder.decodeObjectForKey(mealNameKey) as! String
            calories = aDecoder.decodeObjectForKey(caloriesKey) as! Int
            timeAdded = aDecoder.decodeObjectForKey(timeAddedKey) as! NSDate
        }
    }
    
    let mealsKey = "meals"
    var meals: [Meal]!
    let weightKey = "weight"
    var weight: Int! // in kg
    let heightKey = "height"
    var height: Int! // in cm
    let dobKey = "dob"
    var dob: NSDate!
    var age: Int! {
        get {
            let calendar = NSCalendar.currentCalendar()
            let components = calendar.components(NSCalendarUnit.Year, fromDate: dob, toDate: NSDate(), options: NSCalendarOptions.MatchFirst)
            return components.year
        }
    }
    let sexKey = "sex"
    var sex: Sex!
    let setupTimeKey = "setupTime"
    var setupTime: NSDate!
    let startOfDayHourKey = "startOfDayHour"
    var startOfDayHour: Int! = 8
    let startOfDayMinuteKey = "startOfDayMinute"
    var startOfDayMinute: Int! = 30
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(meals, forKey: mealsKey)
        aCoder.encodeObject(weight, forKey: weightKey)
        aCoder.encodeObject(height, forKey: heightKey)
        aCoder.encodeObject(dob, forKey: dobKey)
        aCoder.encodeObject(sex.rawValue, forKey: sexKey)
        aCoder.encodeObject(setupTime, forKey: setupTimeKey)
        aCoder.encodeObject(startOfDayHour, forKey: startOfDayHourKey)
        aCoder.encodeObject(startOfDayMinute, forKey: startOfDayMinuteKey)
    }
    
    required init?(coder aDecoder: NSCoder) {
        meals = aDecoder.decodeObjectForKey(mealsKey) as! [Meal]
        weight = aDecoder.decodeObjectForKey(weightKey) as! Int
        height = aDecoder.decodeObjectForKey(heightKey) as! Int
        dob = aDecoder.decodeObjectForKey(dobKey) as! NSDate
        let sexRawValue = aDecoder.decodeObjectForKey(sexKey) as! String
        sex = Sex(rawValue: sexRawValue)
        setupTime = aDecoder.decodeObjectForKey(setupTimeKey) as! NSDate
        startOfDayHour = aDecoder.decodeObjectForKey(startOfDayHourKey) as! Int
        startOfDayMinute = aDecoder.decodeObjectForKey(startOfDayMinuteKey) as! Int
    }
    
    func save() {
        let defaults = NSUserDefaults.standardUserDefaults()
        let encodedObject = NSKeyedArchiver.archivedDataWithRootObject(self)
        defaults.setObject(encodedObject, forKey: State.defaultsKey)
    }
    
    class func get() -> State? {
        let defaults = NSUserDefaults.standardUserDefaults()
        if let encoded = defaults.objectForKey(State.defaultsKey) as? NSData {
            let state = NSKeyedUnarchiver.unarchiveObjectWithData(encoded) as! State
            return state
        } else {
            return nil
        }
    }
}
