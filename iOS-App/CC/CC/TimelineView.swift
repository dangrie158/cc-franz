//
//  TimelineView.swift
//  CC
//
//  Created by Tobias Schneider on 8/16/15.
//  Copyright © 2015 Tobias Schneider and not Daniel Grießhaber LOL. All rights reserved. EVERYTHING RESERVED! FOREVER!
//

import Foundation
import UIKit

class TimelineView: UIView {
    
    var scriptActions = [ScriptAction]()
    var scaling = 1.0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
        
    }
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override func drawRect(rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        // draw equally spaced lines
        for var y = 0; y < Int(self.frame.size.height); y += Int(50 * scaling) {
            let lineRect:CGRect = CGRectMake(0.0, CGFloat(y), self.frame.width, 1.0)
            CGContextSetRGBFillColor(context, 1.0, 1.0, 1.0, 0.1)
            CGContextFillRect(context, lineRect)
        }
        
    }
    
    func setup(){
        // setup graphical UI
        self.backgroundColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.02)        
    }
        
    override func didAddSubview(subview: UIView) {
        let subviewHeight = subview.frame.height
        if(subview.frame.origin.y + subviewHeight > self.frame.height){
            self.frame.size.height = CGFloat(subview.frame.origin.y + subviewHeight)
        }
    }
    
    func addTimelineItem(start: Double, length: Double, type: CameraSlider.Direction){
        self.addSubview(TimelineItemView(start: start, length: length, scale: 1.0, type: type))
    }
    
    func replaceScriptActionsInView(actions: [ScriptAction]){
        // remove all subviews first
        for subview in self.subviews{
            subview.removeFromSuperview()
        }
        
        self.scriptActions = actions
        for action in self.scriptActions {
            addTimelineItem(action.start, length: action.length, type: action.direction)
        }
    }
    
    func setScale(scaleFactor: Double){
        var maxHeight : CGFloat = 0.0
        let superScrollView = self.superview as! UIScrollView
        for subview in self.subviews{
            let timelineItem = subview as! TimelineItemView
            let oldScale = timelineItem.getScale()
            if (oldScale < 10 && oldScale > 0.1) || (oldScale > 10 && scaleFactor < 1) || (oldScale < 0.1 && scaleFactor > 1) {
                timelineItem.setScale(Double(((scaleFactor - 1) * 0.1) + 1 ) * oldScale)
                timelineItem.setNeedsDisplay()
            }
            if maxHeight < subview.frame.maxY{
                maxHeight = subview.frame.maxY
            }
        }
        if maxHeight < superScrollView.frame.size.height{
            self.frame.size.height = superScrollView.frame.size.height
        }
        else {
            self.frame.size.height = maxHeight
        }
        if (self.scaling < 10 && self.scaling > 0.1) || (self.scaling > 10 && scaleFactor < 1) || (self.scaling < 0.1 && scaleFactor > 1){
            self.scaling *= (((scaleFactor - 1) * 0.1) + 1 )
        }
        superScrollView.contentSize = self.frame.size
        self.setNeedsDisplay()
    }
    
}
