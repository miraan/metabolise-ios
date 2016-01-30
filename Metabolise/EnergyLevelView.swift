//
//  EnergyLevelView.swift
//  Metabolise
//
//  Created by Miraan on 30/01/2016.
//  Copyright © 2016 Miraan. All rights reserved.
//

import UIKit

class EnergyLevelView: UIView {
    convenience init(parent: UIView) {
        self.init(frame: parent.bounds)
        self.parent = parent
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setup()
    }
    
    var calories: Int! { // default value
        didSet {
            update()
        }
    }
    
    var parent: UIView?
    
    let maximumCalorieOffset: Int! = 1500
    var levelView: UIView!
    var labelView: UILabel!
    let labelViewFont = UIFont(name: "Helvetica-Neue", size: 18.0)
    let labelViewTextColor = UIColor.whiteColor()
    
    var originalHeight: CGFloat!
    var originalWidth: CGFloat!
    
    func setup() {
        originalHeight = self.frame.size.height
        originalWidth = self.frame.size.width
        
        levelView = UIView()
        labelView = UILabel()
        
        calories = 0 // calls update()
        
        addSubview(levelView)
        addSubview(labelView)
    }
    
    func getPositiveColor(coef: CGFloat) -> UIColor {
        return UIColor(red: (141+100*coef)/255, green: 196/255, blue: 15/255, alpha: 1)
    }
    
    func getNegativeColor(coef: CGFloat) -> UIColor {
        return UIColor(red: 22/255, green: (60 + 100 * coef)/255, blue: 133/255, alpha: 1)
    }
    
    func update() {
        UIView.animateWithDuration(1.0) {
            self.levelView.frame = self.getLevelViewFrame()
            self.levelView.backgroundColor = (self.isPositive() ? self.positiveColor : self.negativeColor)
            
            self.labelView.frame = self.getLabelFrame()
            self.labelView.text = (self.isPositive() ? "+" : "") + "\(self.calories)"
            self.labelView.font = self.labelViewFont
            self.labelView.textColor = self.labelViewTextColor
            self.labelView.textAlignment = NSTextAlignment.Center
        }
    }
    
    func getLevelViewFrame() -> CGRect {
        let levelWidth: CGFloat = originalWidth
        var levelHeight: CGFloat = ((abs(CGFloat(calories)) / CGFloat(maximumCalorieOffset)) * originalHeight / 2)
        let maxLevelHeight = originalHeight / 2
        levelHeight += (maxLevelHeight - levelHeight) / 10
        
        let middleX: CGFloat = 0
        let middleY: CGFloat = self.frame.size.height / 2
        
        let levelX: CGFloat = middleX
        var levelY: CGFloat
        if (!isPositive()) {
            levelY = middleY
        } else {
            levelY = middleY - levelHeight
        }
        levelHeight = min(levelHeight, maxLevelHeight)
        return CGRectMake(levelX, levelY, levelWidth, levelHeight)
    }
    
    func getLabelFrame() -> CGRect {
        let levelViewFrame = getLevelViewFrame()
        let labelHeight: CGFloat = 30
        let x: CGFloat = 0
        let y = levelViewFrame.origin.y + ((levelViewFrame.size.height - labelHeight) / 2)
        let labelWidth = self.frame.size.width
        return CGRectMake(x, y, labelWidth, labelHeight)
    }
    
    func isPositive() -> Bool {
        return calories >= 0
    }
}