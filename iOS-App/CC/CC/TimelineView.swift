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
    
    private var scriptActions = [ScriptAction]()
    private var scaling = 1.0
    private var itemLongPressCallback : ((TimelineItemView)->())?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
        
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override func drawRect(rect: CGRect) {
        super.drawRect(rect)
        let context = UIGraphicsGetCurrentContext()
        CGContextClearRect(context, rect)
        // draw equally spaced lines
        for var y = 0; y < Int(self.frame.size.height); y += Int(50 * scaling) {
            let lineRect:CGRect = CGRectMake(0.0, CGFloat(y), self.frame.width, 1.0)
            //transparent white
            CGContextSetRGBFillColor(context, 1.0, 1.0, 1.0, 0.1)
            CGContextFillRect(context, lineRect)
        }
    }
    
    func onLongPressItem(callback : (TimelineItemView)->()){
        self.itemLongPressCallback = callback
    }
    
    func setup(){
        // setup graphical UI
        self.backgroundColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.02)        
    }
    
    
    override func didAddSubview(subview: UIView) {
        super.didAddSubview(subview)
        recalculateContentHeight(subview)
        
        //add all gestures we need to detect drag and drop
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: Selector("actionGesture:"))
        subview.addGestureRecognizer(longPressRecognizer)
    }
    
    func recalculateContentHeight(subview: UIView){
        let subviewHeight = subview.frame.height
        if(subview.frame.origin.y + subviewHeight > self.frame.height){
            self.frame.size.height = CGFloat(subview.frame.origin.y + subviewHeight)
        }
        
        if let scrollContainer = self.superview as? UIScrollView{
            scrollContainer.contentSize = self.frame.size
        }
        setNeedsLayout()
        setNeedsDisplay()
    }
    
    /****************************
    *   Drag and Drop Handler   *
    *****************************/
    func actionGesture(recognizer: UIGestureRecognizer){
        let item = recognizer.view as! TimelineItemView
        
        //if we end any of the gestures, clear the drag mode and return
        if recognizer.state == UIGestureRecognizerState.Ended{
            if !item.wasDragged{
                if itemLongPressCallback != nil{
                    itemLongPressCallback!(item)
                }
            }
            item.wasDragged = false
            item.isInDragMode = false
            return
        //a long press began
        }else if recognizer.state == UIGestureRecognizerState.Began{
            //set the drag mode when we start dragging
            item.isInDragMode = true
            
            //we need to save the offset of the touch in the view so we can use
            //it in successive actions
            item.dragTouchOffset = recognizer.locationInView(item).y
        }else if recognizer.state == UIGestureRecognizerState.Changed {
            item.wasDragged = true
            //we moved the touch, update the view
            if item.isInDragMode {
                let offsetInView = recognizer.locationInView(self).y
                let offsetInSubview = item.dragTouchOffset
                let newStartPoint = max(offsetInView - offsetInSubview, 0)
                
                if !newStartOverlapsAction(item.scriptAction!, withNewStart: Double(newStartPoint)){
                    item.setStart(newStartPoint)
                    recalculateContentHeight(item)
                }
            }
        }
    }
    
    func newStartOverlapsAction(newAction: ScriptAction, withNewStart newstart: Double) -> Bool{
        for action in self.scriptActions{
            //check if we overlap a action that is already present
            //and not the same action
            if(action !== newAction){
                if(newstart + newAction.length > action.start && action.start + action.length >= newstart){
                    return true
                }
            }
        }
        
        return false
    }

    func addTimelineItem(action: ScriptAction, type: CameraSlider.Direction){
        self.addSubview(TimelineItemView(action: action, scale: 1.0, type: type))
    }
    
    func replaceScriptActionsInView(actions: [ScriptAction]){
        // remove all subviews first
        for subview in self.subviews{
            subview.removeFromSuperview()
        }
        
        self.scriptActions = actions
        for action in self.scriptActions {
            //1 pixel shpuld represent 1 second in the action
            addTimelineItem(action, type: action.direction)
        }
    }
    
    func setScale(scaleFactor: Double){
        self.scaling = scaleFactor
        
        var maxHeight : CGFloat = 0.0
        let superScrollView = self.superview as! UIScrollView
        
        for subview in self.subviews{
            let timelineItem = subview as! TimelineItemView

            timelineItem.setScale(scaleFactor)
            timelineItem.setNeedsDisplay()
            
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

        superScrollView.contentSize = self.frame.size
        print("super size: \(superScrollView.contentSize)")
        self.setNeedsDisplay()
        self.setNeedsLayout()
    }
}
