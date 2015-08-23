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
    
    /*******************************
    * instance methods / variables *
    ********************************/
    var currentState:State = .STOPPED
    private var startListener : (() -> Void)? = nil
    private var stopListener : (() -> Void)? = nil
    
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
                drawStop(context, inArea:rect)
            case .STOPPED:
                drawRec(context, inArea:rect)
        }
    }
    
    // basic setup of the recording button
    func setupRecordButton(){
        self.setState(currentState)
        self.setTitle("", forState: UIControlState.Normal)
        self.addTarget(self, action: Selector("click"), forControlEvents: UIControlEvents.TouchUpInside)
    }
    
    func setStartListener(callback:()->Void){
        self.startListener = callback
    }
    
    func setStopListener(callback:()->Void ){
        self.stopListener = callback
    }
    
    // change the record button states
    func setState(state:State){
        currentState = state
        switch(currentState){
        case .RECORDING:
            if(self.startListener != nil){
                self.startListener!()
            }
        case .STOPPED:
            if(self.stopListener != nil){
                self.stopListener!()
            }
        }
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
        let borderRect:CGRect = CGRectMake(0, 0, rect.width, rect.height)
        CGContextSetRGBFillColor(context, 0.960784, 0.149019, 0.290196, 1.0)
        CGContextFillEllipseInRect (context, borderRect)
    }
    
    func drawRec(context:CGContext, inArea rect:CGRect){
        let borderRect:CGRect = CGRectMake((rect.width/3), (rect.width/3), rect.width/3, rect.height/3)
        CGContextSetRGBFillColor(context, 0.1529411, 0.1568627, 0.1333333, 1.0)
        CGContextFillEllipseInRect (context, borderRect)
    }
    
    func drawStop(context:CGContext, inArea rect:CGRect){
        let borderRect:CGRect = CGRectMake((rect.width/3), (rect.width/3), rect.width/3, rect.height/3)
        CGContextSetRGBFillColor(context, 0.1529411, 0.1568627, 0.1333333, 1.0)
        CGContextFillRect(context, borderRect)
    }
}
