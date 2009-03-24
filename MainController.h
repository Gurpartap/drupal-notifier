//
//  MainController.h
//  Drupal Notifier
//
//  Created by Gurpartap Singh on 24/03/09.
//  Copyright 2009 Gurpartap Singh. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Growl/Growl.h>

@interface MainController : NSObject <GrowlApplicationBridgeDelegate> {
  NSStatusItem *statusItem;
  NSImage *statusItemImage;
  NSTimer *notificationTimer;
  IBOutlet NSWindow *PreferencesWindow;
  IBOutlet NSWindowController *PreferencesWindowController;
}

- (NSDictionary *)registrationDictionaryForGrowl;
- (IBAction)launchPreferencesWindow:(id)sender;
- (void)notificationTimerCallback:(NSTimer *)notificationTimer;
- (void)putGrowlingTigerOnFire:(id)sender;

@end
