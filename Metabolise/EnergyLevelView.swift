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
    let positiveColor = UIColor.redColor()
    let negativeColor = UIColor.blueColor()
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
    
    func update() {
        levelView.frame = getLevelViewFrame()
        levelView.backgroundColor = (isPositive() ? positiveColor : negativeColor)
        
        labelView.frame = getLabelFrame()
        labelView.text = (isPositive() ? "+" : "") + "\(calories)"
        labelView.font = labelViewFont
        labelView.textColor = labelViewTextColor
        labelView.textAlignment = NSTextAlignment.Center
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