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
        for var y = 0; y < Int(self.frame.size.height); y += 50{
            let lineRect:CGRect = CGRectMake(0.0, CGFloat(y), self.frame.width, 1.0)
            CGContextSetRGBFillColor(context, 1.0, 1.0, 1.0, 0.1)
            CGContextFillRect(context, lineRect)
        }
        
    }
    
    func setup(){
        // setup graphical UI
        self.backgroundColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.02)
        // draw equally spaced lines
        for var i = 0; i < 100; i += 1{
            let frame = CGRectMake(CGFloat(i), CGFloat(i*10), 100.0, 120.0)
            self.addSubview(TimelineItemView(frame : frame))
            
        }
        
    }
    
    override func didAddSubview(subview: UIView) {
        let subviewHeight = subview.frame.height
        if(subview.frame.origin.y + subviewHeight > self.frame.height){
            self.frame.size.height = CGFloat(subview.frame.origin.y + subviewHeight)
        }
    }
    

    
}
