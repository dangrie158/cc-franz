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
    
    func setupRecordButton(){
        self.layer.cornerRadius = 0.5 * self.bounds.size.width
        self.backgroundColor = UIColor.redColor()
        self.setTitle("•", forState: UIControlState.Normal)
        self.setState(currentState)
        self.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
        self.addTarget(self, action: Selector("pressStart") , forControlEvents: UIControlEvents.TouchDown)
        self.addTarget(self, action: Selector("pressStop") , forControlEvents: UIControlEvents.TouchUpInside)
        self.addTarget(self, action: Selector("click"), forControlEvents: UIControlEvents.TouchUpInside)
    }
    
    func pressStop(){
        self.backgroundColor = UIColor(red: 1.0, green: 0, blue: 0, alpha: 1.0)
    }
    
    func pressStart(){
        self.backgroundColor = UIColor(red: 1.0, green: 0, blue: 0, alpha: 0.6)
    }
    
    func setState(state:State){
        switch state{
            case .RECORDING:
                self.setTitle("■", forState: UIControlState.Normal)
                self.titleLabel?.font = UIFont(name: "Arial", size: 100)
        case .STOPPED:
                self.setTitle("•", forState: UIControlState.Normal)
                self.titleLabel?.font = UIFont(name: "Arial", size: 300)
        }
        currentState = state
    }
    
    func click(){
        switch currentState{
        case .RECORDING:
            setState(.STOPPED)
        case .STOPPED:
            setState(.RECORDING)
        }
    }
}
