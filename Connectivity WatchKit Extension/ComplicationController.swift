//
//  ComplicationController.swift
//  Connectivity WatchKit Extension
//
//  Created by Takeo Tsuchida on 2015/07/31.
//  Copyright © 2015年 MUMPK Limited Partnership. All rights reserved.
//

import ClockKit
import WatchConnectivity

class ComplicationController: NSObject, CLKComplicationDataSource {
    lazy var sessionDelegate:SessionDelegate = {
        let delegate = SessionDelegate()
        return delegate
    }()
    var sessionActivated = false
    var receivedData = "No Entry"
    
    // MARK: - Timeline Configuration
    
    func getSupportedTimeTravelDirectionsForComplication(complication: CLKComplication, withHandler handler: (CLKComplicationTimeTravelDirections) -> Void) {
        if sessionActivated == false {
            let session = WCSession.defaultSession()
            sessionDelegate.didReceiveUserInfoHandler = {(context: [String: AnyObject]) -> Void in
                // If complications of your app need reload contexts.
                if let userInfo = context as? [String: String], data = userInfo[dataId] {
                    self.receivedData = data
                }
                let server = CLKComplicationServer.sharedInstance()
                for complication in server.activeComplications {
                    server.reloadTimelineForComplication(complication)
                }
            }
            session.delegate = sessionDelegate
            session.activateSession()
            sessionActivated = true
        }
        handler([.None])
    }
    
    func getTimelineStartDateForComplication(complication: CLKComplication, withHandler handler: (NSDate?) -> Void) {
        handler(nil)
    }
    
    func getTimelineEndDateForComplication(complication: CLKComplication, withHandler handler: (NSDate?) -> Void) {
        handler(nil)
    }
    
    func getPrivacyBehaviorForComplication(complication: CLKComplication, withHandler handler: (CLKComplicationPrivacyBehavior) -> Void) {
        handler(.ShowOnLockScreen)
    }
    
    // MARK: - Timeline Population
    
    func getCurrentTimelineEntryForComplication(complication: CLKComplication, withHandler handler: ((CLKComplicationTimelineEntry?) -> Void)) {
        // Call the handler with the current timeline entry
        let tmpl = CLKComplicationTemplateModularLargeTallBody()
        tmpl.headerTextProvider = CLKSimpleTextProvider(text: "Received Data")
        let bodyText = CLKSimpleTextProvider(text: receivedData)
        tmpl.bodyTextProvider = bodyText
        let entry = CLKComplicationTimelineEntry(date: NSDate(), complicationTemplate: tmpl)
        handler(entry)
    }
    
    func getTimelineEntriesForComplication(complication: CLKComplication, beforeDate date: NSDate, limit: Int, withHandler handler: (([CLKComplicationTimelineEntry]?) -> Void)) {
        // Call the handler with the timeline entries prior to the given date
        handler(nil)
    }
    
    func getTimelineEntriesForComplication(complication: CLKComplication, afterDate date: NSDate, limit: Int, withHandler handler: (([CLKComplicationTimelineEntry]?) -> Void)) {
        // Call the handler with the timeline entries after to the given date
        handler(nil)
    }
    
    // MARK: - Update Scheduling
    
    func getNextRequestedUpdateDateWithHandler(handler: (NSDate?) -> Void) {
        // Call the handler with the date when you would next like to be given the opportunity to update your complication content
        handler(nil);
    }
    
    // MARK: - Placeholder Templates
    
    func getPlaceholderTemplateForComplication(complication: CLKComplication, withHandler handler: (CLKComplicationTemplate?) -> Void) {
        // This method will be called once per supported complication, and the results will be cached
        let tmpl = CLKComplicationTemplateModularLargeTallBody()
        tmpl.headerTextProvider = CLKSimpleTextProvider(text: "Received Data")
        tmpl.bodyTextProvider = CLKSimpleTextProvider(text: "Data String")
        handler(tmpl)
    }
    
}
