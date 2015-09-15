//
//  GlanceController.swift
//  Connectivity WatchKit Extension
//
//  Created by Takeo Tsuchida on 2015/07/31.
//  Copyright © 2015年 MUMPK Limited Partnership. All rights reserved.
//

import WatchKit
import Foundation
import WatchConnectivity

class GlanceController: WKInterfaceController {


    @IBOutlet var transferredImage: WKInterfaceImage!
    @IBOutlet var contextLabel: WKInterfaceLabel!
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        // Configure interface objects here.
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        
        if let context = WCSession.defaultSession().receivedApplicationContext as? [String:String],
            message = context[dataId] {
            contextLabel.setText(message)
        }
        let url = try! NSFileManager.defaultManager().URLForDirectory(.DocumentDirectory,
            inDomain: .UserDomainMask, appropriateForURL: nil,  create: false)
        let urls = try! NSFileManager.defaultManager().contentsOfDirectoryAtURL(url, includingPropertiesForKeys: nil, options: .SkipsHiddenFiles)
        for url in urls {
            if let data = NSData(contentsOfURL: url), image = UIImage(data: data) {
                self.transferredImage.setImage(image)
                break
            }
        }
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

}
