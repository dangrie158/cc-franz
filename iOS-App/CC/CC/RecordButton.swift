//
//  recordButton.swift
//  CC
//
//  Created by Tobias Schneider on 4/28/15.
//  Copyright (c) 2015 Tobias Schneider. All rights reserved.
//

import Foundation
import UIKit


class RecordButton:UIButton{
    var currentState:State = .STOPPED
    
    // recording button states
    enum State{
        case RECORDING
        case STOPPED
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupRecordButton()
    }
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupRecordButton()
    }
    
    override func drawRect(rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        drawBackground(context, inArea: rect)
        switch currentState{
            case .RECORDING:
                drawRec(context, inArea:rect)
            case .STOPPED:
                drawStop(context, inArea:rect)
        }
    }
    
    // basic setup of the recording button
    func setupRecordButton(){
        //self.layer.cornerRadius = 0.5 * self.bounds.size.width
        //self.backgroundColor = UIColor.redColor()
        self.setState(currentState)
        //self.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
        //self.addTarget(self, action: Selector("pressStart") , forControlEvents: UIControlEvents.TouchDown)
        //self.addTarget(self, action: Selector("pressStop") , forControlEvents: UIControlEvents.TouchUpInside)
        self.addTarget(self, action: Selector("click"), forControlEvents: UIControlEvents.TouchUpInside)
    }
    
    // stop recording
    func pressStop(){
        
    }
    
    // start recording
    func pressStart(){
        
    }
    
    // change the record button states
    func setState(state:State){
        currentState = state
        self.setNeedsDisplay()
    }
    
    func click(){
        switch currentState{
        case .RECORDING:
            setState(.STOPPED)
        case .STOPPED:
            setState(.RECORDING)
        }
    }
    
    func drawBackground(context:CGContext, inArea rect:CGRect){
        var borderRect:CGRect = CGRectMake(0, 0, rect.width, rect.height);
        CGContextSetRGBFillColor(context, 1.0, 0.0, 0.0, 1.0);
        CGContextFillEllipseInRect (context, borderRect);
    }
    
    func drawRec(context:CGContext, inArea rect:CGRect){
        var borderRect:CGRect = CGRectMake((rect.width/2)-(rect.width/8), (rect.height/2)-(rect.width/8), rect.width/4, rect.height/4);
        CGContextSetRGBFillColor(context, 0.0, 0.0, 0.0, 1.0);
        CGContextFillEllipseInRect (context, borderRect);
    }
    func drawStop(context:CGContext, inArea rect:CGRect){
        var borderRect:CGRect = CGRectMake((rect.width/2)-(rect.width/8), (rect.height/2)-(rect.width/8), rect.width/4, rect.height/4);
        CGContextSetRGBFillColor(context, 0.0, 0.0, 0.0, 1.0);
        CGContextFillRect(context, borderRect);
    }
}
