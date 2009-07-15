//
//  PreferencesController.m
//  Drupal Notifier
//
//  Created by Gurpartap Singh on 19/06/09.
//  Copyright 2009 Gurpartap Singh. All rights reserved.
//

#import "PreferencesController.h"
#import "WebsitesViewController.h"


@implementation PreferencesController

# pragma mark -
# pragma mark Initialization

/**
 * Implementation of init.
 */
- (id)init {
  if (!self = [super initWithWindowNibName:@"Preferences"]) {
    return nil;
  }
  return self;
}

# pragma mark -
# pragma mark Window display management

/**
 * Implementation of awakeFromNib.
 */
- (void)awakeFromNib {
  [self showWebsitesPreferences:self];
  [preferencesToolbar
   setSelectedItemIdentifier:[websiteToolbarItem itemIdentifier]];
}

/**
 * Implementation of showWindow.
 */
- (void)showWindow:(id)sender {
  [NSApp activateIgnoringOtherApps:YES];
  [[self window] center];
  [super showWindow:sender];
}

# pragma mark -
# pragma mark Implementation methods

/**
 * Show websites preferences view.
 */
- (IBAction)showWebsitesPreferences:(id)sender {
  if (!websitesView) {
    WebsitesViewController *websitesVC = [[WebsitesViewController alloc] init];
    [self setValue:[websitesVC valueForKey:@"view"] forKey:@"websitesView"];
  }
  [[self window] setContentView:websitesView];
}

# pragma mark -
# pragma mark Toolbar delegates

/**
 * Implementation of validateToolbarItem.
 */
- (BOOL)validateToolbarItem:(NSToolbarItem *)theItem {
  return YES;
}

/**
 * Implementation of toolbarSelectableItemIdentifiers.
 */
- (NSArray *)toolbarSelectableItemIdentifiers:(NSToolbar *)toolbar {
  NSMutableArray *allIdentifiers = [[NSMutableArray alloc] init];

  for (NSToolbarItem *toolbarItem in [toolbar items]) {
    if ([[toolbarItem label] isEqualToString:@"Websites"])
      [allIdentifiers addObject:[toolbarItem itemIdentifier]];
  }

  return [allIdentifiers autorelease];
}

@end
