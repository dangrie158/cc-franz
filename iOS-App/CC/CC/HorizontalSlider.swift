//
//  HorizontalSlider.swift
//  CC
//
//  Created by Tobias Schneider on 5/4/15.
//  Copyright (c) 2015 Tobias Schneider. All rights reserved.
//

import Foundation
import UIKit

class HorizontalSlider:UISlider{
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSlider()
    }
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupSlider()
    }
    
    func setupSlider(){
        self.continuous = true
        self.minimumValue = -1.0
        self.maximumValue = 1.0
        self.value = 0.0
        self.minimumTrackTintColor = UIColor.greenColor()
        self.maximumTrackTintColor = UIColor.greenColor()
        self.addTarget(self, action: Selector("stopSliding") , forControlEvents: UIControlEvents.TouchUpInside)
        self.addTarget(self, action: Selector("stopSliding") , forControlEvents: UIControlEvents.TouchUpOutside)
    }
    
    func stopSliding(){
        self.setValue(0.0, animated: true)
        self.sendActionsForControlEvents(UIControlEvents.ValueChanged)
    }
}
