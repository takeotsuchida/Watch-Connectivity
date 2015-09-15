//
//  ViewController.swift
//  Connectivity
//
//  Created by Takeo Tsuchida on 2015/07/31.
//  Copyright © 2015年 MUMPK Limited Partnership. All rights reserved.
//

import UIKit
import WatchConnectivity

class ViewController: UIViewController {

    var sessionDelegate: SessionDelegate!
    @IBOutlet weak var sendDataButton: UIButton!
    @IBOutlet weak var receivedDataLabel: UILabel!
    @IBOutlet weak var pairedLabel: UILabel!
    @IBOutlet weak var installedLabel: UILabel!
    @IBOutlet weak var reachableLabel: UILabel!
    @IBOutlet weak var progressLabel: UILabel!

    @IBOutlet weak var sendText: UITextField!
    @IBOutlet weak var updateText: UITextField!
    @IBOutlet weak var transferText: UITextField!
    @IBOutlet weak var complicationText: UITextField!
    
    @IBAction func sendMessageToWatch(sender: AnyObject) {
        let reply = {(messages: [String: AnyObject]) -> Void in
            let value: String
            if let val = messages[dataId] {
                value = String(val)
            } else {
                value = "Nil"
            }
            self.progressLabel.text = "Replay Handler"
            self.receivedDataLabel.text = value
        }
        let error = {(error: NSError) -> Void in
            if let errorCode = WCErrorCode(rawValue: error.code) {
                let errorString = SessionDelegate.wcerrorString(errorCode)
                self.progressLabel.text = "Error Handler \(errorString)"
            } else {
                self.progressLabel.text = "Error Handler \(error.localizedDescription)"
            }
        }
        progressLabel.text = "Sending message"
        let messageText: String!
        if let message = sendText.text {
            messageText = message
        } else {
            messageText = "mumpk"
        }
        WCSession.defaultSession().sendMessage([dataId: messageText], replyHandler: reply, errorHandler: error)
    }
 
    @IBAction func updateApplicationContext(sender: AnyObject) {
        do {
            let context: [String: String]!
            if let sendingText = updateText.text {
                context = [dataId:sendingText]
            } else {
                context = [dataId: "mumpk"]
            }
            progressLabel.text = "Updating context"
            try WCSession.defaultSession().updateApplicationContext(context)
        } catch {
            progressLabel.text = "\(error)"
        }
        /*
        } catch let errorCode {
            if let error = errorCode as? WCErrorCode {
                progressLabel.text = SessionDelegate.wcerrorString(error)
            } else {
                progressLabel.text = "CTX \(errorCode)"
            }
        }
        */
    }

    @IBAction func transferUserInfo(sender: AnyObject) {
        let context: [String: String]!
        if let sendingText = transferText.text {
            context = [dataId:sendingText]
        } else {
            context = [dataId: "mumpk"]
        }
        progressLabel.text = "Transfer UserInfo"
        WCSession.defaultSession().transferUserInfo(context)
    }
    
    @IBAction func transferComplication(sender: AnyObject) {
        let context: [String: String]!
        if let sendingText = complicationText.text {
            context = [dataId:sendingText]
        } else {
            context = [dataId: "mumpk"]
        }
        progressLabel.text = "Transfer Complication"
        WCSession.defaultSession().transferCurrentComplicationUserInfo(context)
    }
    
    @IBAction func transferFile(sender: AnyObject) {
        if let url = NSBundle.mainBundle().URLForResource("jellyfish", withExtension: "jpg") {
            let metadata = ["name":"jellyfish", "extension":"jpg", "type":"jpeg"]
            let _ = WCSession.defaultSession().transferFile(url,
                metadata:metadata)
            progressLabel.text = "Transfer JPEG"
        } else {
            progressLabel.text = "No JPEG File"
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if (WCSession.isSupported()) {
            let session = WCSession.defaultSession()
            installedLabel.text = session.watchAppInstalled ? "Installed" : "Not installed"
            sessionDelegate = SessionDelegate()
            sessionDelegate.watchStateDidChangeHandler = {(session: WCSession) -> Void in
                self.reachableLabel.text = session.reachable ? "Reachable" : "Not Reachable"
                self.pairedLabel.text = session.paired ? "Paired" : "Not Paired"
                self.installedLabel.text = session.watchAppInstalled ? "Installed" : "Not installed"
            }
            sessionDelegate.reachabilityDidChangeHandler = {(session: WCSession) -> Void in
                self.reachableLabel.text = session.reachable ? "Reachable" : "Not Reachable"
                self.pairedLabel.text = session.paired ? "Paired" : "Not paired"
                self.installedLabel.text = session.watchAppInstalled ? "Installed" : "Not installed"
            }
            sessionDelegate.didReceiveUserInfoHandler = {(userInfo: [String: AnyObject]) -> Void in
                if let data = userInfo["name"] {
                    self.receivedDataLabel.text = String(data)
                } else {
                    self.receivedDataLabel.text = "NoName"
                }
            }
            sessionDelegate.didReceivedMessageHandler = {(message: [String: AnyObject]) -> Void in
                if let data = message[dataId] {
                    self.receivedDataLabel.text = String(data)
                } else {
                    self.receivedDataLabel.text = "NoName"
                }
                self.progressLabel.text = "Message Received"
            }
            session.delegate = sessionDelegate
            session.activateSession()
        }
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

extension ViewController : UITextFieldDelegate {
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        guard let _ = textField.text else {
            textField.text = "Please Insert Text"
            return true
        }
        return true
    }
}
