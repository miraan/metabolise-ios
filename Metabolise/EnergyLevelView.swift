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
    
    var dividerLineView: UIImageView!
    
    func setup() {
        originalHeight = self.frame.size.height
        originalWidth = self.frame.size.width
        
        levelView = UIView()
        labelView = UILabel()
        
        calories = 0 // calls update()
        
        addSubview(levelView)
        addSubview(labelView)
        
        dividerLineView = UIImageView(frame: CGRectMake(0, (originalHeight / 2) - 0.5, originalWidth, 1))
        dividerLineView.image = UIImage(named: "DividerLine")!
        addSubview(dividerLineView)
    }
    
    func getPositiveColor(coef: CGFloat) -> UIColor {
        return UIColor(red: (141+100*coef)/255, green: 196/255, blue: 15/255, alpha: 1)
    }
    
    func getNegativeColor(coef: CGFloat) -> UIColor {
        return UIColor(red: 22/255, green: (60 + 100 * coef)/255, blue: 133/255, alpha: 1)
    }
    
    func update() {
        let duration = 1.0
        UIView.animateWithDuration(duration) {
            self.levelView.frame = self.getLevelViewFrame()
            let coef = self.levelView.frame.size.height / self.originalHeight
            self.levelView.backgroundColor = (self.isPositive() ? self.getPositiveColor(coef) : self.getNegativeColor(coef))
            
            self.labelView.frame = self.getLabelFrame()
            self.labelView.font = self.labelViewFont
            self.labelView.textColor = self.labelViewTextColor
            self.labelView.textAlignment = NSTextAlignment.Center
        }
        
        func adjustLabel() {
            var labelCalories = Int(self.labelView.text ?? "0")!
            if labelCalories != self.calories {
                let diff = abs(self.calories - labelCalories)
                if labelCalories < self.calories {
                    labelCalories += (diff+1) / 2
                } else {
                    labelCalories -= (diff+1) / 2
                }
                self.labelView.text = (labelCalories > 0 ? "+" : "") + "\(labelCalories)"
                Helper.delay(0.1) {
                    adjustLabel()
                }
            }
        }
        
        adjustLabel()
    }
    
    func getLevelViewFrame() -> CGRect {
        let levelWidth: CGFloat = originalWidth
        var levelHeight: CGFloat = ((abs(CGFloat(calories)) / CGFloat(maximumCalorieOffset)) * originalHeight / 2)
        let maxLevelHeight = originalHeight / 2
        levelHeight += (maxLevelHeight - levelHeight) / 10
        
        let middleX: CGFloat = 0
        let middleY: CGFloat = originalHeight / 2
        
        levelHeight = min(levelHeight, maxLevelHeight)
        
        let levelX: CGFloat = middleX
        var levelY: CGFloat
        if (!isPositive()) {
            levelY = middleY
        } else {
            levelY = middleY - levelHeight
        }
    
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