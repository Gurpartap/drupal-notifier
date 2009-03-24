//
//  PreferencesWindowController.h
//  Drupal Notifier
//
//  Created by Gurpartap Singh on 24/03/09.
//  Copyright 2009 Gurpartap Singh. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MainController.h"

@interface PreferencesWindowController : NSObject {
  IBOutlet NSTextField *siteAddress;
  IBOutlet NSTextField *siteName;
  IBOutlet NSTextField *sitePassword;
  IBOutlet NSTextField *siteUsername;
  IBOutlet NSWindow *prefWindow;
  IBOutlet NSWindow *websiteSheet;
  IBOutlet NSTextField *errorLabel;
  IBOutlet NSProgressIndicator *progressIndicator;
  IBOutlet NSTextField *addressLabel;
  IBOutlet NSTextField *usernameLabel;
  IBOutlet NSNumber *checkInterval;
}

- (IBAction)showProjectPage:(id)sender;
- (IBAction)showLicense:(id)sender;
- (IBAction)mailMe:(id)sender;
- (IBAction)connectWebsiteDetailsSheet:(id)sender;
- (IBAction)showWebsiteDetailsSheet:(id)sender;
- (IBAction)closeWebsiteDetailsSheet:(id)sender;
- (void)handleTimer:(NSTimer *)timer;

@end
