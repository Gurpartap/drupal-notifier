//
//  Notification.h
//  Drupal Notifier
//
//  Created by Gurpartap Singh on 26/06/09.
//  Copyright 2009 Gurpartap Singh. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "Website.h"

@class Website;

@interface Notification :  Website  
{
}

@property (nonatomic, retain) NSNumber * announce;
@property (nonatomic, retain) NSNumber * playSound;
@property (nonatomic, retain) NSNumber * growl;
@property (nonatomic, retain) NSString * appleScriptPath;
@property (nonatomic, retain) NSNumber * announceVolume;
@property (nonatomic, retain) NSNumber * growlSticky;
@property (nonatomic, retain) NSString * notificationName;
@property (nonatomic, retain) NSString * soundPath;
@property (nonatomic, retain) NSNumber * runAppleScript;
@property (nonatomic, retain) Website * website;

@end



