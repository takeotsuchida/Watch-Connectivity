//
//  InterfaceController.swift
//  Connectivity WatchKit Extension
//
//  Created by Takeo Tsuchida on 2015/07/31.
//  Copyright © 2015年 MUMPK Limited Partnership. All rights reserved.
//

import WatchKit
import Foundation
import WatchConnectivity
import ClockKit

class InterfaceController: WKInterfaceController {
    var sessionDelegate: SessionDelegate!
    @IBOutlet var dataLabel: WKInterfaceLabel!
    @IBOutlet var statusLabel: WKInterfaceLabel!
    @IBOutlet var outstandingLabel: WKInterfaceLabel!
    
    @IBOutlet var transferredImage: WKInterfaceImage!
    @IBOutlet var sendButton: WKInterfaceButton!
    @IBOutlet var checkButton: WKInterfaceButton!
    
    
    @IBAction func sendMessageToPhone(sender: AnyObject) {
        let reply = {(messages: [String: AnyObject]) -> Void in
            let value: String
            if let val = messages[dataId] {
                value = String(val)
            } else {
                value = "Nil"
            }
            self.statusLabel.setText("Reply Handler")
            self.dataLabel.setText(value)
        }
        let error = {(error: NSError) -> Void in
            self.statusLabel.setText("Error Handler")
            if let errorCode = WCErrorCode(rawValue: error.code) {
                let errorString = SessionDelegate.wcerrorString(errorCode)
                self.dataLabel.setText("\(errorString)")
            } else {
                self.statusLabel.setText("Error Handler")
                self.dataLabel.setText("\(error.localizedDescription)")
            }
        }
        statusLabel.setText("Sending message")
        WCSession.defaultSession().sendMessage([dataId: "Watch's Message"], replyHandler: reply, errorHandler: error)
    }
    
    @IBAction func transferUserInfo() {
        guard WCSession.defaultSession().reachable else {
            statusLabel.setText("Could Not Send")
            return
        }
        let userInfo = ["name": "I'm Watch"]
        let userInfoTransfer = WCSession.defaultSession().transferUserInfo(userInfo)
        if userInfoTransfer.transferring {
            statusLabel.setText("transferring")
        }
    }

    @IBAction func checkOutstandingUserInfo() {
        let infos = WCSession.defaultSession().outstandingFileTransfers
        outstandingLabel.setText("\(infos.count)")
    }
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        statusLabel.setText("Start")
        dataLabel.setText("NoData")
        // Configure interface objects here.
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        if (WCSession.isSupported()) {
            let session = WCSession.defaultSession()
            sessionDelegate = SessionDelegate()
            sessionDelegate.reachabilityDidChangeHandler = {(session: WCSession) -> Void in
                if session.reachable {
                    self.statusLabel.setText("Reachable")
                } else {
                    self.statusLabel.setText("Not Reachable")
                }
            }
            sessionDelegate.didReceiveUserInfoHandler = {(context: [String: AnyObject]) -> Void in
                // If complications of your app need reload contexts.
                if let userInfo = context as? [String: String], data = userInfo[dataId] {
                    self.dataLabel.setText(String(data))
                }

            }
            sessionDelegate.didReceivedMessageHandler = {(context: [String: AnyObject]) -> Void in
                if let data = context[dataId] {
                    self.dataLabel.setText(String(data))
                } else {
                    self.dataLabel.setText("No Message")
                }
                let server = CLKComplicationServer.sharedInstance()
                for complication in server.activeComplications {
                    server.extendTimelineForComplication(complication)
                }
            }
            sessionDelegate.didReceiveApplicationContextHandler = {(context: [String: AnyObject]) -> Void in
                if let data = context[dataId] {
                    self.dataLabel.setText(String(data))
                } else {
                    self.dataLabel.setText("No Context")
                }
                // If complications of your app need reload contexts.
                /*
                let server = CLKComplicationServer.sharedInstance()
                for complication in server.activeComplications {
                    server.extendTimelineForComplication(complication)
                }
                */
            }
            sessionDelegate.didReceiveFileHandler = {(file: WCSessionFile) -> Void in
                if let metadata = file.metadata {
                    let name = metadata["name"] as! String
                    let ext = metadata["extension"] as! String
                    self.dataLabel.setText(name)
                    if let data = NSData(contentsOfURL: file.fileURL) {
                        let image = UIImage(data: data)
                        self.transferredImage.setImage(image)
                    }
                    do {
                        let toURL = try NSFileManager.defaultManager().URLForDirectory(.DocumentDirectory,
                            inDomain: .UserDomainMask, appropriateForURL: nil,  create: false).URLByAppendingPathComponent(name).URLByAppendingPathExtension(ext)
                        try NSFileManager.defaultManager().moveItemAtURL(file.fileURL, toURL: toURL)
                        self.dataLabel.setText("Move Completed")
                    } catch {
                        self.dataLabel.setText("Move Failed")
                    }
                } else {
                    self.dataLabel.setText("No Meta")
                }
            }
            session.delegate = sessionDelegate
            session.activateSession()
        }
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        let session = WCSession.defaultSession()
        session.delegate = nil
        super.didDeactivate()
    }

}
