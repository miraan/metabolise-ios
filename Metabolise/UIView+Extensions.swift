import UIKit

extension UIView {
    
    func applyDropShadowWithOffset(offset: CGFloat, opacity: Float, blur: CGFloat) -> UIView {
        // If you want to call this with rounded corners, you must provide clipsToBounds: false
        self.layer.shadowColor = UIColor.blackColor().CGColor
        self.layer.shadowOffset = CGSize(width: 0, height: offset)
        self.layer.shadowOpacity = opacity
        self.layer.shadowRadius = blur
        return self // Chaining!
    }
    
    func makeButton() {
        self.backgroundColor = UIColor(red: 55.0/255, green: 26.0/255, blue: 26.0/255, alpha: 57.0/100)
        self.addBorder(1.0, color: UIColor.whiteColor().CGColor).roundCorners(2.5)
    }
    
    func fadeIn(duration: Double, completionHandler: (() -> Void)?) {
        UIView.animateWithDuration(duration) {
            self.alpha = 1
        }
        if completionHandler != nil {
            Helper.delay(duration) {
                completionHandler!()
            }
        }
    }
    
    func fadeOut(duration: Double, completionHandler: (() -> Void)?) {
        UIView.animateWithDuration(duration) {
            self.alpha = 0
        }
        if completionHandler != nil {
            Helper.delay(duration) {
                completionHandler!()
            }
        }
    }
    
    func roundCorners(radius: CGFloat, clipsToBounds: Bool = true) -> UIView {
        self.autoresizingMask = [UIViewAutoresizing.FlexibleLeftMargin, UIViewAutoresizing.FlexibleRightMargin]
        self.layer.masksToBounds = true
        self.layer.cornerRadius = radius
        self.clipsToBounds = clipsToBounds
        return self // Give us a chance to do some nice chaining
    }
    
    func addBorder(width: CGFloat, color: CGColor) -> UIView {
        self.layer.borderWidth = width
        self.layer.borderColor = color
        return self
    }
    
}