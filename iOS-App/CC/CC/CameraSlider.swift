//
//  ConnectionManager.swift
//  CC
//
//  Created by Daniel Grießhaber on 11/05/15.
//  Copyright (c) 2015 Tobias Schneider. All rights reserved.
//

import UIKit

class CameraSlider: NSObject, SRWebSocketDelegate {
    enum State{
        case DISCONNECTED
        case CONNECTING
        case CONNECTED
    }
    
    enum Direction{
        case RIGHT
        case LEFT
        case CCW
        case CW
    }
    
    var shouldReconnect = true
    var stepCoolDown = false
    
    /***********************
    *** Helper Functions ***
    ***********************/
    func delay(delay:Double, closure:()->()) {
        dispatch_after(
            dispatch_time(
                DISPATCH_TIME_NOW,
                Int64(delay * Double(NSEC_PER_SEC))
            ),
            dispatch_get_main_queue(), closure)
    }
    
    /***********************
    * ConnectionManagement *
    ***********************/
    
    /*****************************
    * static methods / variables *
    ******************************/
    
    //the singleton instance itself
    static let instance = CameraSlider()
    
    //The Singleton instance getter
    static func getInstance() -> CameraSlider {
        return instance;
    }
    
    /*******************************
    * instance methods / variables *
    ********************************/
    private let controlAdress = "192.168.4.1:8080"
    private var currentConnectionState:State = .DISCONNECTED
    
    private var connectedCallback : ((SRWebSocket) -> Void)? = nil;
    private var disconnectedCallback : (() -> Void)? = nil;
    
    private var wsConnection:SRWebSocket?
    
    override init(){
        super.init()
    }

    /***********************
    * ConnectionManagement *
    ***********************/
    func webSocket(webSocket: SRWebSocket!, didReceiveMessage message: AnyObject!) {
        println("Message: \(message)")
    }
    
    func webSocketDidOpen(webSocket: SRWebSocket!) {
        println("connectededed")
        setState(.CONNECTED)
    }
    
    func webSocket(webSocket: SRWebSocket!, didCloseWithCode code: Int, reason: String!, wasClean: Bool) {
        setState(.DISCONNECTED)
        println(reason)
        if shouldReconnect {
            delay(1) {
                self.socketConnect()
            }
        }
    }
    
    func webSocket(webSocket: SRWebSocket!, didFailWithError error: NSError!) {
        setState(.DISCONNECTED)
        println("dis")
        if shouldReconnect {
            delay(1) {
                self.socketConnect()
            }
        }
    }
    
    //start the connection attempt loop
    //if the connection fails,
    //it will automatically re-attempt
    //to connect
    func startConnecting() {
        println("starting")
        socketConnect()
    }
    
    func stopConnecting(){
        self.shouldReconnect = false
        wsConnection!.close()
    }
    
    func socketConnect() {
        setState(.CONNECTING)
        if wsConnection != nil{
            wsConnection!.close()
            wsConnection?.delegate = nil
            wsConnection = nil
        }
        
        wsConnection = SRWebSocket(URL: NSURL(scheme: "ws", host: controlAdress, path: "/"))
        wsConnection!.delegate = self
        wsConnection!.open()
    }
    
    func onConnect( callback:(SRWebSocket)->Void ){
        connectedCallback = callback
    }
    
    func onDisconnect( callback:()->Void ){
        println("ON DISCONNECT")
        disconnectedCallback = callback
    }
    
    private func setState(newState:State){
        let oldState = currentConnectionState
        switch newState {
        case .DISCONNECTED:
            if oldState != State.DISCONNECTED && oldState != State.CONNECTING && disconnectedCallback != nil{
                disconnectedCallback!()
            }
        case .CONNECTING:
            break
        case .CONNECTED:
            if oldState != State.CONNECTED && connectedCallback != nil {
                connectedCallback!(wsConnection!)
            }
        }
        currentConnectionState = newState
    }
    
    /***********************
    *   Hardware Control   *
    ***********************/
    func eStop(){
        //handle eStop
    }
    
    func home(){
        //handle homing
    }
    
    func setSpeed(){
        
    }
    
    func move(direction: Direction, withSpeed speed: Float){
        // the basic string is build as follows: 
        // "AXIS DIRECTION" + "DIRECTION SIGN" + "SPEED"
        // example: "M-10" --> move left with the speed of 10
        
        // define axis as "M" for move or "R" for rotation
        let axis = direction == .LEFT || direction == .RIGHT ? "M" : "R"
        // define direction sign as "+" or "-" depending on LEFT/CCW or RIGHT/CW
        let directionSign = direction == .LEFT || direction == .CCW ? "-" : "+"
        // use 255 different speed values
        let speedValue:Int = Int(speed*255)
        // build message
        let message:String = axis + directionSign + speedValue.description
        // send message
        sendRawMessage(message)
    }
    
    func rotate(direction: Direction, withSpeed speed: Float){
        move(direction, withSpeed: speed)
    }
    
    func sendRawMessage(message: String){
        if(!stepCoolDown){
            wsConnection?.send(message)
            println(message)
            stepCoolDown = true;
            delay(0.1){
                self.stepCoolDown = false
            }
        }
        
    }
    
}