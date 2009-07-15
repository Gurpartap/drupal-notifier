//
//  ApplicationDelegate.h
//  Drupal Notifier
//
//  Created by Gurpartap Singh on 19/06/09.
//  Copyright 2009 Gurpartap Singh. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@class PreferencesController;

@interface ApplicationDelegate : NSObject {
  IBOutlet NSMenu *statusMenu;
  NSStatusItem *statusItem;
  PreferencesController *preferencesController;
}

- (IBAction)showPreferencePanel:(id)sender;

@end
