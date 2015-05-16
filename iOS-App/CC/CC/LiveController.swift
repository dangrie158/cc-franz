//
//  FirstViewController.swift
//  CC
//
//  Created by Tobias Schneider on 4/28/15.
//  Copyright (c) 2015 Tobias Schneider. All rights reserved.
//

import UIKit

class LiveController: UIViewController{
    
    var timer:NSTimer? = NSTimer()
    var counter:Int = 0
    
    @IBOutlet weak var timeElappsedTextfield: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func sendMessage(){
        counter += 1
        timeElappsedTextfield.text = String(counter)
    }
    
    @IBAction func moveLeftStart(sender: AnyObject) {
        timer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: Selector("sendMessage"), userInfo: nil, repeats: true)
    }
    
    @IBAction func moveLeftStop(sender: AnyObject) {
        if let z = timer?.valid{
            timer!.invalidate()
        }
        timer = nil
    }
    
    @IBOutlet weak var slider: HorizontalSlider!
    @IBAction func sliderValueChanged(sender: AnyObject) {
        println(slider.value)
    }
    
}