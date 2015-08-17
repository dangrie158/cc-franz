//
//  TimelineItemView.swift
//  CC
//
//  Created by Tobias Schneider on 8/16/15.
//  Copyright © 2015 Tobias Schneider. All rights reserved.
//

import Foundation

class TimelineItemView: UIView {

    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    
    
    func setup(){
        self.backgroundColor = UIColor.redColor()
    }


}
