//
//  TimelineItemView.swift
//  CC
//
//  Created by Tobias Schneider on 8/16/15.
//  Copyright © 2015 Tobias Schneider. All rights reserved.
//

import Foundation

class TimelineItemView: UIView {
    
    private var scale : Double = 1.0
    private var dragState = false
    
    var scriptAction : ScriptAction? = nil
    var dragTouchOffset = CGFloat()
    var wasDragged = false
    var isInDragMode : Bool {
        get {return self.dragState}
        set(newState) {
            self.dragState = newState
            
            var r : CGFloat = 0.0
            var g : CGFloat = 0.0
            var b : CGFloat = 0.0
            var a : CGFloat = 0.0
            self.backgroundColor!.getRed(&r, green: &g, blue: &b, alpha: &a)
            
            if newState == true{
                self.backgroundColor = UIColor(red: r, green: g, blue: b, alpha:0.3)
            }else{
                // set transparency of script actions according to the speed and
                // limit transparence from 0.1 to 0.9
                let alpha = min(max(0.1, CGFloat((self.scriptAction?.speed)!)), 0.9)
                self.backgroundColor = UIColor(red: r, green: g, blue: b, alpha: alpha)
            }
            
            self.setNeedsLayout()
        }
    }
    
    init(action: ScriptAction, scale: Double, type: CameraSlider.Direction) {
        let frame = CGRectMake(0.0, 0, 0, 0)
        super.init(frame: frame)
        
        self.scriptAction = action
        self.scale = scale
        setup(type)
    }
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func setup(type: CameraSlider.Direction){
        // set transparency of script actions according to the speed and
        // limit transparence from 0.1 to 0.9
        let alpha = min(max(0.1, CGFloat((self.scriptAction?.speed)!)), 0.9)
        if type == .LEFT || type == .RIGHT {
            self.backgroundColor = UIColor(red: 0.99215, green: 0.59216, blue: 0.12157, alpha: alpha)
        }
        else if type == .CW || type == .CCW {
            self.backgroundColor = UIColor(red: 0.65098, green: 0.88627, blue: 0.17254, alpha: alpha)
        }
        self.layer.cornerRadius = 3
        self.layer.masksToBounds = true
    }
    
    func setScale(scale: Double){
        self.scale = scale
        
        let start: CGFloat = CGFloat(scriptAction!.start)
        let length: CGFloat = CGFloat(scriptAction!.length)
        self.frame = CGRectMake(0.0, start * CGFloat(scale), self.superview!.bounds.width, length * CGFloat(scale))
    }
    
    func getScale() -> Double{
        return self.scale
    }
    
    func setStart(newStart: CGFloat){
        self.frame.origin.y = newStart
        self.scriptAction?.start = Double(newStart)
        self.setNeedsLayout()
    }
    
    override func didMoveToSuperview() {
        if(superview != nil){
            let start: CGFloat = CGFloat(scriptAction!.start)
            let length: CGFloat = CGFloat(scriptAction!.length)
            self.frame = CGRectMake(0.0, start * CGFloat(scale), (self.superview?.bounds.width)!, length * CGFloat(scale))
        }
    }
    
    override func drawRect(rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        var r : CGFloat = 0.0
        var g : CGFloat = 0.0
        var b : CGFloat = 0.0
        var a : CGFloat = 0.0
        self.backgroundColor!.getRed(&r, green: &g, blue: &b, alpha: &a)
        // draw highlight line according to direction
        var lineRect : CGRect? = nil
        if self.scriptAction?.direction == .LEFT || self.scriptAction?.direction == .CCW {
            lineRect = CGRectMake(0.0, 0.0, 10, self.bounds.height)
        }
        else {
            lineRect = CGRectMake(self.bounds.width-10, 0.0, 10, self.bounds.height)
        }
        CGContextSetRGBFillColor(context, r, g, b, 1.0)
        CGContextFillRect(context, lineRect!)
    }
}
