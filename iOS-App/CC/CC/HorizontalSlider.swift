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
        self.minimumTrackTintColor = UIColor.greenColor()
        self.maximumTrackTintColor = UIColor.greenColor()
        self.addTarget(self, action: Selector("sliding") , forControlEvents: UIControlEvents.TouchDown)
        self.addTarget(self, action: Selector("stopSliding") , forControlEvents: UIControlEvents.TouchUpInside)
        self.addTarget(self, action: Selector("stopSliding") , forControlEvents: UIControlEvents.TouchUpOutside)
    }
    
    func sliding(){
        
    }
    
    func stopSliding(){
        UIView.animateWithDuration(2.0, animations:{
            self.value = 0
        })
    }
}
