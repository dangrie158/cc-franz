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
    private var start : Double = 0
    private var length : Double = 0
    
    init(start: Double, length: Double, scale: Double, type: CameraSlider.Direction) {
        let frame = CGRectMake(0.0, 0, 0, 0)
        super.init(frame: frame)
        self.scale = scale
        self.start = start
        self.length = length
        setup(type)
    }
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func setup(type: CameraSlider.Direction){
        if type == .LEFT || type == .RIGHT {
            self.backgroundColor = UIColor(red: 0.99215, green: 0.59216, blue: 0.12157, alpha: 0.6)
        }
        else if type == .CW || type == .CCW {
            self.backgroundColor = UIColor(red: 0.65098, green: 0.88627, blue: 0.17254, alpha: 0.6)
        }
        self.layer.cornerRadius = 3
        self.layer.masksToBounds = true
    }
    
    func setScale(scale: Double){
        self.scale = scale
        self.frame = CGRectMake(0.0, CGFloat(start * scale), self.superview!.bounds.width, CGFloat(length * scale))
    }
    
    func getScale() -> Double{
        return self.scale
    }

    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        print("TOUCHED")
    }
    
    override func didMoveToSuperview() {
        print("did")
        print(superview?.frame.width)
        self.frame = CGRectMake(0.0, CGFloat(start * scale), (self.superview?.bounds.width)!, CGFloat(length * scale))
    }
    
    override func drawRect(rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        var r : CGFloat = 0.0
        var g : CGFloat = 0.0
        var b : CGFloat = 0.0
        var a : CGFloat = 0.0
        self.backgroundColor!.getRed(&r, green: &g, blue: &b, alpha: &a)
        // draw left highlight line
        let lineRect:CGRect = CGRectMake(0.0, 0.0, 10, self.frame.height)
        CGContextSetRGBFillColor(context, r, g, b, 1.0)
        CGContextFillRect(context, lineRect)
    }
    

}
