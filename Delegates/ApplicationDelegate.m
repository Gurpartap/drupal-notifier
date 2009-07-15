//
//  ApplicationDelegate.m
//  Drupal Notifier
//
//  Created by Gurpartap Singh on 19/06/09.
//  Copyright 2009 Gurpartap Singh. All rights reserved.
//

#import "ApplicationDelegate.h"
#import "PreferencesController.h"
#import "WebsitesViewController.h"


@implementation ApplicationDelegate

# pragma mark -
# pragma mark Status Bar item initialization

/**
 * Implementation of awakeFromNib.
 */
- (void)awakeFromNib {
  statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:29.0f];
  [statusItem retain];
  [statusItem setImage:[NSImage imageNamed:@"DNStatusItem"]];
  [statusItem setAlternateImage:[NSImage imageNamed:@"DNStatusItemAlternate"]];
  [statusItem setMenu:statusMenu];
  [statusItem setHighlightMode:YES];
  [self showPreferencePanel:self];
}

# pragma mark -
# pragma mark Implementation methods

/**
 * Show preferences window.
 */
- (IBAction)showPreferencePanel:(id)sender {
  if (!preferencesController) {
    preferencesController = [[PreferencesController alloc] init];
  }
  [preferencesController showWindow:self];
}

# pragma mark -
# pragma mark Cleanup

/**
 * Implementation of dealloc.
 */
- (void)dealloc {
  [[NSStatusBar systemStatusBar] removeStatusItem:statusItem];
  [super dealloc];
}

@end
