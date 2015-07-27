//
//  TintedTabBarController.swift
//  CC
//
//  Created by Tobias Schneider on 7/27/15.
//  Copyright © 2015 Tobias Schneider. All rights reserved.
//

import Foundation

class TintedTabBarController: UITabBarController {
    override func viewDidLoad() {
        self.tabBar.tintColor = UIColor.whiteColor()
    }
}
