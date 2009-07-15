//
//  PreferencesController.h
//  Drupal Notifier
//
//  Created by Gurpartap Singh on 19/06/09.
//  Copyright 2009 Gurpartap Singh. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface PreferencesController : NSWindowController {
  IBOutlet NSToolbar *preferencesToolbar;
  IBOutlet NSToolbarItem *websiteToolbarItem;
  NSView *websitesView;
}

- (IBAction)showWebsitesPreferences:(id)sender;

@end
