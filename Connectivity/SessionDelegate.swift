//
//  SessionDelegate.swift
//  Connectivity
//
//  Created by Takeo Tsuchida on 2015/07/31.
//  Copyright © 2015年 MUMPK Limited Partnership. All rights reserved.
//

import Foundation
import WatchConnectivity

let dataId = "data"

class SessionDelegate: NSObject, WCSessionDelegate {
    static let sharedSessionDelegate = SessionDelegate()

    //Delegate handlers
    var watchStateDidChangeHandler:((WCSession) -> Void)?
    var reachabilityDidChangeHandler:((WCSession) -> Void)?
    var didReceivedMessageHandler:(([String: AnyObject]) -> Void)?
    var didReceivedMessageDataHandler:((NSData) -> Void)?
    var didReceiveApplicationContextHandler:(([String: AnyObject]) -> Void)?
    var didReceiveUserInfoHandler:(([String: AnyObject]) -> Void)?
    var didReceiveFileHandler:((WCSessionFile) -> Void)?
    
    //Receiver side handlers
    var didFinishUserInfoTransferHandler:((WCSessionUserInfoTransfer, NSError?) -> Void)?
    var didFinishFileTransferHandler:((WCSessionFileTransfer, NSError?) -> Void)?
    
    override init() {
        super.init()
    }

    /** Called when any of the Watch state properties change */
    func sessionWatchStateDidChange(session: WCSession) {
        watchStateDidChangeHandler?(session)
    }
    
    /** ------------------------- Interactive Messaging ------------------------- */
    
    /** Called when the reachable state of the counterpart app changes. The receiver should check the reachable property on receiving this delegate callback. */
    func sessionReachabilityDidChange(session: WCSession) {
        reachabilityDidChangeHandler?(session)
    }
    
    /** Called on the delegate of the receiver. Will be called on startup if the incoming message caused the receiver to launch. */
    func session(session: WCSession, didReceiveMessage message: [String : AnyObject]) {
        didReceivedMessageHandler?(message)
    }
    
    /** Called on the delegate of the receiver when the sender sends a message that expects a reply. Will be called on startup if the incoming message caused the receiver to launch. */
    func session(session: WCSession, didReceiveMessage message: [String : AnyObject], replyHandler: ([String : AnyObject]) -> Void) {
        replyHandler(message)
        didReceivedMessageHandler?(message)
    }
    
    /** Called on the delegate of the receiver. Will be called on startup if the incoming message data caused the receiver to launch. */
    func session(session: WCSession, didReceiveMessageData messageData: NSData) {
        didReceivedMessageDataHandler?(messageData)
    }
    
    /** Called on the delegate of the receiver when the sender sends message data that expects a reply. Will be called on startup if the incoming message data caused the receiver to launch. */
    func session(session: WCSession, didReceiveMessageData messageData: NSData, replyHandler: (NSData) -> Void) {
        replyHandler(messageData)
        didReceivedMessageDataHandler?(messageData)
    }
    
    /** -------------------------- Background Transfers ------------------------- */
    
    /** Called on the delegate of the receiver. Will be called on startup if an applicationContext is available. */
    func session(session: WCSession, didReceiveApplicationContext applicationContext: [String : AnyObject]) {
        didReceiveApplicationContextHandler?(applicationContext)
    }
    
    /** Called on the sending side after the user info transfer has successfully completed or failed with an error. Will be called on next launch if the sender was not running when the user info finished. */
    func session(session: WCSession, didFinishUserInfoTransfer userInfoTransfer: WCSessionUserInfoTransfer, error: NSError?) {
        didFinishUserInfoTransferHandler?(userInfoTransfer, error)
    }
    
    /** Called on the delegate of the receiver. Will be called on startup if the user info finished transferring when the receiver was not running. */
    func session(session: WCSession, didReceiveUserInfo userInfo: [String : AnyObject]) {
        didReceiveUserInfoHandler?(userInfo)
    }
    
    /** Called on the sending side after the file transfer has successfully completed or failed with an error. Will be called on next launch if the sender was not running when the transfer finished. */
    func session(session: WCSession, didFinishFileTransfer fileTransfer: WCSessionFileTransfer, error: NSError?) {
        didFinishFileTransferHandler?(fileTransfer, error)
    }
    
    /** Called on the delegate of the receiver. Will be called on startup if the file finished transferring when the receiver was not running. The incoming file will be located in the Documents/Inbox/ folder when being delivered. The receiver must take ownership of the file by moving it to another location. The system will remove any content that has not been moved when this delegate method returns. */
    func session(session: WCSession, didReceiveFile file: WCSessionFile) {
        didReceiveFileHandler?(file)
    }
    
    static func wcerrorString(errorCode: WCErrorCode) -> String {
        switch errorCode {
        case .GenericError:
            return "GenericError"
        case .SessionNotSupported:
            return "SessionNotSupported"
        case .SessionMissingDelegate:
            return "SessionMissingDelegate"
        case .SessionNotActivated:
            return "SessoionNotActivated"
        case .DeviceNotPaired:
            return "DeviceNotPaired"
        case .WatchAppNotInstalled:
            return "WatchAppNotInstalled"
        case .NotReachable:
            return "NotReachable"
        case .InvalidParameter:
            return "InvalidParameter"
        case .PayloadTooLarge:
            return "PayloadTooLarge"
        case .PayloadUnsupportedTypes:
            return "PayloadUnsupportedTypes"
        case .MessageReplyFailed:
            return "MessageReplyFailed"
        case .MessageReplyTimedOut:
            return "MessageReplyTimeOut"
        case .FileAccessDenied:
            return "FileAccessDenied"
        case .DeliveryFailed:
            return "DeliveryFailed"
        case .InsufficientSpace:
            return "InsufficientSpace"
        }
    }
}
