//
//  WebsitesViewController.h
//  Drupal Notifier
//
//  Created by Gurpartap Singh on 19/06/09.
//  Copyright 2009 Gurpartap Singh. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface WebsitesViewController : NSViewController {
  IBOutlet NSTableView *websitesTableView;
  IBOutlet NSTextField *websiteAddress;
  IBOutlet NSImageView *websiteIcon;
	IBOutlet NSButton *playSound;
  IBOutlet NSProgressIndicator *updateIndicator;
  IBOutlet NSPopUpButton *notifications;
  IBOutlet NSPopUpButton *sounds;

  NSManagedObjectModel *managedObjectModel;
  NSManagedObjectContext *managedObjectContext;
}

- (void)buildNotificationsMenu;
- (void)buildSoundsMenu;
- (void)playSound:(id)sender;
- (IBAction)switchSound:(id)sender;
- (NSManagedObjectModel *)managedObjectModel;
- (NSManagedObjectContext *)managedObjectContext;
- (NSArray *)dataEntityForWebsite:(NSString *)attribute;
- (IBAction)saveAction:(id)sender;
- (IBAction)resetWebsiteIcon:(id)sender;

@end
