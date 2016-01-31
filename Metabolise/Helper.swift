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
    static let themeColor = UIColor(red: 52/255.0, green: 73/255.0, blue: 94/255.0, alpha: 1.0)
    static var themeFont: UIFont!
    
    class func printFonts() {
        let fontFamilyNames = UIFont.familyNames()
        for familyName in fontFamilyNames {
            print("------------------------------")
            print("Font Family Name = [\(familyName)]")
            let names = UIFont.fontNamesForFamilyName(familyName)
            print("Font Names = [\(names)]")
        }
    }
    
    class func getStringFromDate(date: NSDate) -> String {
        let calendar = NSCalendar.currentCalendar()
        let components = calendar.components(NSCalendarUnit.Year.union(NSCalendarUnit.Month).union(NSCalendarUnit.Day).union(NSCalendarUnit.Hour).union(NSCalendarUnit.Minute).union(NSCalendarUnit.Second), fromDate: date)
        return String(format: "%04d-%02d-%02d %02d:%02d:%02d", arguments: [components.year, components.month, components.day, components.hour, components.minute, components.second])
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
        let components = calendar.components(NSCalendarUnit.Year.union(NSCalendarUnit.Month).union(NSCalendarUnit.Day).union(NSCalendarUnit.Hour).union(NSCalendarUnit.Minute), fromDate: now)
        let startOfDayHour = State.get()!.startOfDayHour
        let startOfDayMinute = State.get()!.startOfDayMinute
        if (components.hour < startOfDayHour || (components.hour == startOfDayHour && components.minute < startOfDayMinute)) {
            components.day -= 1
        }
        components.hour = startOfDayHour
        components.minute = startOfDayMinute
        return calendar.dateFromComponents(components)!
    }
    
    class func getComponentsSinceStartOfDay() -> NSDateComponents {
        let now = NSDate()
        let calendar = NSCalendar.currentCalendar()
        let diffComponents = calendar.components(NSCalendarUnit.Hour.union(NSCalendarUnit.Minute), fromDate: getStartOfDay(), toDate: now, options: NSCalendarOptions.MatchFirst)
        return diffComponents
    }
    
    class func getTimeLeftInDayText() -> String {
        let diffComponents = getComponentsSinceStartOfDay()
        let hoursLeft = 23 - diffComponents.hour
        let minutesLeft = 59 - diffComponents.minute
        if (hoursLeft < 1) {
            return "\(minutesLeft) minutes left today"
        } else {
            return "\(hoursLeft) hours left today"
        }
    }
    
    class func todayWithoutTime() -> NSDate {
        let now = NSDate()
        let calendar = NSCalendar.currentCalendar()
        let components = calendar.components(NSCalendarUnit.Year.union(NSCalendarUnit.Month).union(NSCalendarUnit.Day), fromDate: now)
        let today = calendar.dateFromComponents(components)!
        return today
    }
    
    class func getStartOfWeek() -> NSDate {
        let now = NSDate()
        let calendar = NSCalendar.currentCalendar()
        let components = calendar.components(NSCalendarUnit.Weekday, fromDate: now)
        let diff = components.weekday - 1
        
        let addComponents = NSDateComponents()
        addComponents.day = -diff
        let startOfWeek = calendar.dateByAddingComponents(addComponents, toDate: todayWithoutTime(), options: NSCalendarOptions.MatchStrictly)!
        return startOfWeek
    }
    
    class func getComponentsSinceStartOfWeek() -> NSDateComponents {
        let now = NSDate()
        let calendar = NSCalendar.currentCalendar()
        let diffComponents = calendar.components(NSCalendarUnit.Day.union(NSCalendarUnit.Hour).union(NSCalendarUnit.Minute), fromDate: getStartOfWeek(), toDate: now, options: NSCalendarOptions.MatchStrictly)
        return diffComponents
    }
    
    class func getTimeLeftInWeekText() -> String {
        let diffComponents = getComponentsSinceStartOfWeek()
        let daysLeft = 6 - diffComponents.day
        let hoursLeft = 23 - diffComponents.hour
        let minutesLeft = 59 - diffComponents.minute
        if (daysLeft < 1) {
            if (hoursLeft < 1) {
                return "\(minutesLeft) mins left this week"
            } else {
                return "\(hoursLeft) hrs left this week"
            }
        } else {
            return "\(daysLeft) days left this week"
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
    
    class func getDailyCalories() -> Int {
        return getCaloriesConsumedToday() - getCaloriesBurnedToday()
    }
    
    class func getWeeklyCalories() -> Int {
        return getCaloriesConsumedThisWeek() - getCaloriesBurnedThisWeek()
    }
    
    class func getCaloriesBurnedToday() -> Int {
        let startOfDay = getStartOfDay()
        let secondsThroughDay = abs(Int(startOfDay.timeIntervalSinceNow))
        let fractionOfDayComplete = Double(secondsThroughDay) / Double(secondsPerDay)
        let burnedCalories = Int(Double(getBurnedCaloriesPerDay()) * fractionOfDayComplete)
        return burnedCalories
    }
    
    class func getCaloriesBurnedThisWeek() -> Int {
        let startOfWeek = getStartOfWeek()
        let secondsThroughWeek = abs(Int(startOfWeek.timeIntervalSinceNow))
        let fractionOfWeekComplete = Double(secondsThroughWeek) / Double(secondsPerDay * 7)
        let burnedCalories = Int(Double(getBurnedCaloriesPerDay() * 7) * fractionOfWeekComplete)
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
    
    class func getCaloriesConsumedToday() -> Int {
        let state = State.get()!
        let filtered = state.meals.filter() { (meal: State.Meal) -> Bool in
            meal.timeAdded.timeIntervalSince1970 >= Helper.getStartOfDay().timeIntervalSince1970
        }
        var total = 0
        for meal in filtered {
            total += meal.calories * meal.quantity
        }
        return total
    }
    
    class func getCaloriesConsumedThisWeek() -> Int {
        let state = State.get()!
        let filtered = state.meals.filter() { (meal: State.Meal) -> Bool in
            meal.timeAdded.timeIntervalSince1970 >= Helper.getStartOfWeek().timeIntervalSince1970
        }
        var total = 0
        for meal in filtered {
            total += meal.calories * meal.quantity
        }
        return total
    }
    
    class func getLabelSize(width: CGFloat, text: String, font: UIFont) -> CGSize {
        let attributed = NSAttributedString(string: text, attributes: [NSFontAttributeName: font])
        let labelRect = attributed.boundingRectWithSize(CGSizeMake(width, CGFloat.max), options: NSStringDrawingOptions.UsesLineFragmentOrigin, context: nil)
        return labelRect.size
    }
    
    class func delay(delay:Double, closure:()->()) {
        dispatch_after(
            dispatch_time(
                DISPATCH_TIME_NOW,
                Int64(delay * Double(NSEC_PER_SEC))
            ),
            dispatch_get_main_queue(), closure)
    }
    
    static var toasts:[Double -> Void] = []
    
    class func toast(text: String, font: UIFont, duration: Double) {
        let screenRect = UIScreen.mainScreen().bounds
        let screenWidth = screenRect.size.width
        let screenHeight = screenRect.size.height
        
        let toastPadding: CGFloat = 20 // between toast and window edges
        let labelPadding: CGFloat = 15 // between label and toast edges
        let maxLabelWidth = screenWidth - ((labelPadding + toastPadding) * 2)
        
        let labelSize = Helper.getLabelSize(maxLabelWidth, text: text, font: font)
        let toastSize = CGSize(width: labelSize.width + (labelPadding * 2), height: labelSize.height + (labelPadding * 2))
        
        let toastX = (screenWidth - toastSize.width) / 2
        let toastY = (screenHeight - toastSize.height) / 2
        let toastFrame = CGRectMake(toastX, toastY, toastSize.width, toastSize.height)
        
        let toast = UIView(frame: toastFrame)
        toast.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.8)
        toast.roundCorners(5.0, clipsToBounds: true)
        toast.addBorder(0.5, color: Helper.themeColor.CGColor)
        
        let labelFrame = CGRectMake(labelPadding, labelPadding, labelSize.width, labelSize.height)
        let label = UILabel(frame: labelFrame)
        label.font = font
        label.text = text
        label.textColor = UIColor.darkGrayColor()
        label.numberOfLines = 0
        
        toast.addSubview(label)
        toast.alpha = 0
        AppDelegate.window.addSubview(toast)
        
        let animationDuration: Double = 0.4
        
        UIView.animateWithDuration(animationDuration) {
            toast.alpha = 1
        }
        
        let removeToast:Double -> Void = { (duration) in
            UIView.animateWithDuration(duration, animations: {
                toast.alpha = 0
                }, completion: { (finished) in
                    toast.removeFromSuperview()
            })
        }
        
        Helper.toasts += [removeToast]
        
        Helper.delay(animationDuration + duration) {
            removeToast(animationDuration)
        }
    }
    
    class func toast(text: String, duration: Double) {
        Helper.toast(text, font: themeFont, duration: duration)
    }
    
    class func toast(text: String) {
        Helper.toast(text, duration: 1.0)
    }
    
    class func clearToast() {
        for removeToast in Helper.toasts {
            removeToast(0)
        }
    }
    
}