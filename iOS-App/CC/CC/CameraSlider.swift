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
    
    enum Axis{
        case MOVEMENT
        case ROTATION
    }
    
    enum RecordingError: ErrorType {
        // the recording was already initialized
        case AlreadyRecording
    }
    
    /*******************************
    * instance methods / variables *
    ********************************/
    var shouldReconnect = true
    var stepCoolDown = false
    var lastMessage = "";
    
    private let cooldownTime = 0.2
    // node websocket
    private let controlAdress = "85.214.213.194:8080"
    // physical websocket
//    private let controlAdress = "192.168.4.1:8080"
    private var currentConnectionState:State = .DISCONNECTED
    
    private var connectedCallback : ((SRWebSocket) -> Void)? = nil
    private var disconnectedCallback : (() -> Void)? = nil
    
    private var wsConnection:SRWebSocket?
    private var currentRecording:Recording?
    
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
    
    override init(){
        super.init()
    }

    /***********************
    * ConnectionManagement *
    ***********************/
    func webSocket(webSocket: SRWebSocket!, didReceiveMessage message: AnyObject!) {
        print("Message: \(message)")
    }
    
    func webSocketDidOpen(webSocket: SRWebSocket!) {
        print("connectededed")
        setState(.CONNECTED)
    }
    
    func webSocket(webSocket: SRWebSocket!, didCloseWithCode code: Int, reason: String!, wasClean: Bool) {
        setState(.DISCONNECTED)
        print(reason)
        if shouldReconnect {
            delay(1) {
                self.socketConnect()
            }
        }
    }
    
    func webSocket(webSocket: SRWebSocket!, didFailWithError error: NSError!) {
        setState(.DISCONNECTED)
        print("dis")
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
        print("starting")
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
        print("ON DISCONNECT")
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
    
    /**
    * send a message to start homing of the slider
    */
    func home(axis: Axis){
        let axisParameter = (axis == .MOVEMENT) ? "M" : "R"
        let message = "H" + axisParameter;
        self.sendRawMessage(message);
    }
    
    /**
    * reference a axis with a new zero position
    */
    func setZeroReference(axis: Axis){
        let axisParameter = (axis == .MOVEMENT) ? "M" : "R"
        let message = "Z" + axisParameter;
        self.sendRawMessage(message);
    }
    
    func move(direction: Direction, withSpeed speed: Float){
        // the basic string is build as follows: 
        // "AXIS DIRECTION" + "DIRECTION SIGN" + "SPEED"
        // example: "M-10" --> move left with the speed of 10
        
        // define axis as "M" for move or "R" for rotation
        let axis = direction == .LEFT || direction == .RIGHT ? "M" : "R"
        // define direction sign as "+" or "-" depending on LEFT/CCW or RIGHT/CW
        let directionSign = speed == 0 ? "" : (direction == .LEFT || direction == .CCW ? "-" : "+")
        // use 255 different speed values
        let speedValue:String = String(Int(speed*255), radix: 16)
        // build message
        let message:String = axis + directionSign + speedValue
        // send message
        sendCooledDownMessage(message)
    }
    
    func rotate(direction: Direction, withSpeed speed: Float){
        move(direction, withSpeed: speed)
    }
    
    
    func sendCooledDownMessage(message: String){
        if(!stepCoolDown){
            self.sendRawMessage(message)
            print(message)
            stepCoolDown = true;
            delay(self.cooldownTime){
                self.stepCoolDown = false
                self.sendRawMessage(self.lastMessage)
            }
        }
        else{
            lastMessage = message;
        }
    }
    
    func sendRawMessage(message: String){
        if(self.currentRecording != nil){
            self.currentRecording?.addAction(withStringAction: message)
        }
        wsConnection?.send(message)
    }
    
    
    /***********************
    *  recording handling  *
    ***********************/
    /**
     * start a new recording with a given name
     * you can get the recording after stopping it 
     * with stopRecording
     */
    func startNewRecording(withName name:String) throws{
        try self.startRecording(on: Recording(withName: name))
    }
    
    /**
     * start recording on a already created recording
     */
    func startRecording(on recording: Recording) throws{
        if(self.currentRecording != nil){
            throw RecordingError.AlreadyRecording
        }
        self.currentRecording = recording
    }
    
    /**
     * stop recording and return the finished recording
     */
    func stopRecording() -> Recording{
        let currentRecording = self.currentRecording!
        self.currentRecording = nil
        
        return currentRecording
    }
    
}