//
//  WebsitesViewController.m
//  Drupal Notifier
//
//  Created by Gurpartap Singh on 19/06/09.
//  Copyright 2009 Gurpartap Singh. All rights reserved.
//

#import "WebsitesViewController.h"
#import "ImageTextCell.h"
#import "Notification.h"

@implementation WebsitesViewController

# pragma mark -
# pragma mark Initialization

/**
 * Implementation of init.
 */
- (id)init {
  if (![super initWithNibName:@"WebsitesView" bundle:nil]) {
    return nil;
  }
  return self;
}

# pragma mark -
# pragma mark Table column view management

/**
 * Implementation of awakeFromNib.
 */
- (void)awakeFromNib {
  NSTableColumn* column = [[websitesTableView tableColumns] objectAtIndex:0];
	ImageTextCell* cell = [[[ImageTextCell alloc] init] autorelease];
	[column setDataCell:cell];
  [cell setDataDelegate:self];
//  [self buildNotificationsMenu];
  [self buildSoundsMenu];
}

/**
 * Return an array of a Website entity, against given unique attribute.
 */
- (NSArray *)dataEntityForWebsite:(NSString *)attribute {
  NSEntityDescription *entity = [[managedObjectModel entitiesByName] valueForKey:@"Website"];
  NSPredicate *predicate = [NSPredicate predicateWithFormat:@"address == %@", attribute];
  NSFetchRequest *fetch = [[NSFetchRequest alloc] init];
  [fetch setEntity:entity];
  [fetch setPredicate:predicate];

  NSArray *dataArray = [managedObjectContext executeFetchRequest:fetch error:nil];
  [fetch release];

  return dataArray;
}

/**
 * Implementation of dataElementForCell; return a data object to table cell subclass.
 */
- (NSObject *)dataElementForCell:(ImageTextCell *) cell {
  NSString *website = [cell stringValue];
  return [self dataEntityForWebsite:website];
}

/**
 * Implementation of iconForCell.
 */
- (NSImage *)iconForCell:(ImageTextCell *)cell data:(NSObject *)data {
  if ([[data valueForKey:@"icon"] count] > 0) {
    NSImage *icon = [[NSImage alloc] initWithData:(NSData *)[[data valueForKey:@"icon"] objectAtIndex:0]];
    return icon;
  }
  else {
    return [NSImage imageNamed:@"websites"];
  }
}

/**
 * Implementation of primaryTextForCell.
 */
- (NSString *)primaryTextForCell:(ImageTextCell *)cell data:(NSObject *)data {
  if ([[data valueForKey:@"name"] count] > 0) {
    return [[data valueForKey:@"name"] objectAtIndex:0];
  }
  else {
    return @"Example Website";
  }
}

/**
 * Implementation of secondaryTextForCell.
 */
- (NSString *)secondaryTextForCell:(ImageTextCell *)cell data:(NSObject *)data {
  if ([[data valueForKey:@"address"] count] > 0) {
    return [[data valueForKey:@"address"] objectAtIndex:0];
  }
  else {
    return @"example.com";
  }
}

/**
 * Implementation of controlTextDidChange; Delegate method for Site Name textfield.
 */
- (void)controlTextDidChange:(NSNotification *)aNotification {
  [websitesTableView reloadData];
}

# pragma mark -
# pragma mark Core Data object management

/**
 * Method returning managedObjectModel.
 */
- (NSManagedObjectModel *)managedObjectModel {
  if (managedObjectModel) {
    return managedObjectModel;
  }

	NSMutableSet *allBundles = [[NSMutableSet alloc] init];
	[allBundles addObject:[NSBundle mainBundle]];
	[allBundles addObjectsFromArray:[NSBundle allFrameworks]];
  
  managedObjectModel = [[NSManagedObjectModel mergedModelFromBundles:[allBundles allObjects]] retain];
  [allBundles release];

  return managedObjectModel;
}

/**
 * Build path to the application support folder for the app, to store data.
 */
- (NSString *)applicationSupportFolder {
  NSString *applicationSupportFolder = nil;
  FSRef foundRef;
  OSErr err = FSFindFolder(kUserDomain, kApplicationSupportFolderType, kDontCreateFolder, &foundRef);
  if (err != noErr) {
    NSRunAlertPanel(@"Alert", @"Can't find application support folder", @"Quit", nil, nil);
    [[NSApplication sharedApplication] terminate:self];
  }
  else {
    unsigned char path[1024];
    FSRefMakePath(&foundRef, path, sizeof(path));
    applicationSupportFolder = [NSString stringWithUTF8String:(char *)path];
    applicationSupportFolder = [applicationSupportFolder stringByAppendingPathComponent:@"Drupal Notifier"];
  }

  return applicationSupportFolder;
}

/**
 * Method returning managedObjectContext.
 */
- (NSManagedObjectContext *)managedObjectContext {
  if (managedObjectContext) {
    return managedObjectContext;
  }

  NSError *error;
  NSString *applicationSupportFolder = nil;
  NSURL *url;
  NSFileManager *fileManager;
  NSPersistentStoreCoordinator *coordinator;

  fileManager = [NSFileManager defaultManager];
  applicationSupportFolder = [self applicationSupportFolder];
  if (![fileManager fileExistsAtPath:applicationSupportFolder isDirectory:NULL]) {
    [fileManager createDirectoryAtPath:applicationSupportFolder attributes:nil];
  }
  
  url = [NSURL fileURLWithPath:[applicationSupportFolder stringByAppendingPathComponent:@"Drupal Notifier Websites.xml"]];
  coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
  if ([coordinator addPersistentStoreWithType:NSXMLStoreType configuration:nil URL:url options:nil error:&error]){
    managedObjectContext = [[NSManagedObjectContext alloc] init];
    [managedObjectContext setPersistentStoreCoordinator:coordinator];
  }
  else {
    [[NSApplication sharedApplication] presentError:error];
  }    
  [coordinator release];
  
  return managedObjectContext;
}

/**
 * Implementation of applicationShouldTerminate; Confirm losing changes (if any).
 */
- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender {
  NSError *error;
  NSManagedObjectContext *context;
  int reply = NSTerminateNow;
  
  context = [self managedObjectContext];
  if (context != nil) {
    if ([context commitEditing]) {
      if (![context save:&error]) {
				// This default error handling implementation should be changed to
        // make sure the error presented includes application specific error
        // recovery. For now, simply display 2 panels.
        BOOL errorResult = [[NSApplication sharedApplication] presentError:error];
				
				if (errorResult == YES) { // Then the error was handled
					reply = NSTerminateCancel;
				} 
        else {
					// Error handling wasn't implemented.
          // Fall back to displaying a "quit anyway" panel.
					int alertReturn = NSRunAlertPanel(nil, @"Could not save changes while quitting. Quit anyway?", @"Quit anyway", @"Cancel", nil);
					if (alertReturn == NSAlertAlternateReturn) {
						reply = NSTerminateCancel;	
					}
				}
      }
    }
    else {
      reply = NSTerminateCancel;
    }
  }
  return reply;
}

# pragma mark -
# pragma mark Implementation methods

/**
 * Build popup menu items for notifications.
 */
- (void) buildNotificationsMenu {
  // TODO: This should be handled through core data.
	NSMenuItem *menuItem = nil;
	NSEnumerator *enumerator = nil;
	NSMenu *availableEvents = [[[NSMenu alloc] initWithTitle:@""] autorelease];
	NSDictionary *info = nil;
  
	enumerator = [[NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"notifications" ofType:@"plist"]] objectEnumerator];
	while((info = [enumerator nextObject])) {
		if(![info objectForKey:@"separator"]) {
			menuItem = [[[NSMenuItem alloc] initWithTitle:[info objectForKey:@"title"] action:NULL keyEquivalent:@""] autorelease];
			[menuItem setRepresentedObject:[info objectForKey:@"identifier"]];
			[availableEvents addItem:menuItem];
		} else [availableEvents addItem:[NSMenuItem separatorItem]];
	}
  
  // Fake items:
  menuItem = [[[NSMenuItem alloc] initWithTitle:@"New comments" action:NULL keyEquivalent:@""] autorelease];
  [menuItem setRepresentedObject:@"abc"];
  [availableEvents addItem:menuItem];
  
  menuItem = [[[NSMenuItem alloc] initWithTitle:@"New content" action:NULL keyEquivalent:@""] autorelease];
  [menuItem setRepresentedObject:@"abcd"];
  [availableEvents addItem:menuItem];

	[notifications setMenu:availableEvents];
}

/**
 * Look up for available sounds and list them in sounds popup menu.
 */
- (void)buildSoundsMenu {
	NSMenuItem *menuItem = nil;
	NSEnumerator *enumerator = nil;
	id sound = nil;
	BOOL first = YES;
  
	NSMenu *availableSounds = [[[NSMenu alloc] initWithTitle:@""] autorelease];
  
	enumerator = [[[NSBundle mainBundle] pathsForResourcesOfType:@"aiff" inDirectory:@"Sounds"] objectEnumerator];
	while ((sound = [enumerator nextObject])) {
		menuItem = [[[NSMenuItem alloc] initWithTitle:[[sound lastPathComponent] stringByDeletingPathExtension] action:NULL keyEquivalent:@""] autorelease];
		[menuItem setRepresentedObject:[sound lastPathComponent]];
		[menuItem setImage:[NSImage imageNamed:@"sound"]];
		[availableSounds addItem:menuItem];
	}
  
	NSFileManager *fm = [NSFileManager defaultManager];
	NSString *bundleName = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleName"];
	NSArray *paths = [NSArray arrayWithObjects:
                    [NSString stringWithFormat:@"/Network/Library/Application Support/%@/Sounds", bundleName],
                    [NSString stringWithFormat:@"/Library/Application Support/%@/Sounds", bundleName],
                    [[NSString stringWithFormat:@"~/Library/Application Support/%@/Sounds", bundleName] stringByExpandingTildeInPath],
                    @"-",
                    @"/System/Library/Sounds",
                    [@"~/Library/Sounds" stringByExpandingTildeInPath],
                    nil];
	NSEnumerator *pathEnum = [paths objectEnumerator];
	NSString *aPath = nil;
	while ((aPath = [pathEnum nextObject])) {
		if([aPath isEqualToString:@"-"]) {
			first = YES;
			continue;
		}
		enumerator = [[fm directoryContentsAtPath:aPath] objectEnumerator];
		NSEnumerator *oldEnum = nil;
		NSString *oldPath = nil;
		int indentationLevel = 0;
		while ((sound = [enumerator nextObject]) || oldEnum) {
			if(!sound && oldEnum) {
				enumerator = oldEnum;
				aPath = oldPath;
				oldEnum = nil;
				indentationLevel = 0;
				continue;
			}
			NSString *newPath = [aPath stringByAppendingPathComponent:sound];
			BOOL isDir;
			if (!oldEnum && [fm fileExistsAtPath:newPath isDirectory:&isDir] && isDir) {
				oldEnum = enumerator;
				enumerator = [[fm directoryContentsAtPath:newPath] objectEnumerator];
				oldPath = aPath;
				aPath = newPath;
				if (first) {
          [availableSounds addItem:[NSMenuItem separatorItem]];
        }
				first = NO;
				menuItem = [[[NSMenuItem alloc] initWithTitle:sound action:@selector(aRandomSelector:of:no:consequence:) keyEquivalent:@""] autorelease];
				[menuItem setEnabled:NO];
				[menuItem setImage:[NSImage imageNamed:@"folder"]];
				[availableSounds addItem:menuItem];
				indentationLevel = 1;
				continue;
			}
			if ([[sound pathExtension] isEqualToString:@"aif"] || [[sound pathExtension] isEqualToString:@"aiff"] || [[sound pathExtension] isEqualToString:@"wav"]) {
				if (first) {
          [availableSounds addItem:[NSMenuItem separatorItem]];
        }
				first = NO;
				menuItem = [[[NSMenuItem alloc] initWithTitle:[sound stringByDeletingPathExtension] action:NULL keyEquivalent:@""] autorelease];
				[menuItem setRepresentedObject:newPath];
				[menuItem setImage:[NSImage imageNamed:@"sound"]];
				[menuItem setIndentationLevel:indentationLevel];
				[availableSounds addItem:menuItem];
			}
		}
	}
  
	[sounds setMenu:availableSounds];
}

/**
 * Toggle playing of sound for a notification.
 */
- (void)playSound:(id)sender {
	[sounds setEnabled:(BOOL)[sender state]];
	[self switchSound:sounds];
}

/**
 * Play the sound when selection is changed.
 */
- (IBAction)switchSound:(id)sender {
	NSString *path = [[sounds selectedItem] representedObject];

	if ([playSound state] == NSOnState) {
		if(![path isAbsolutePath]) path = [[NSString stringWithFormat:@"%@/Sounds", [[NSBundle mainBundle] resourcePath]] stringByAppendingPathComponent:path];
		NSSound *sound = [[[NSSound alloc] initWithContentsOfFile:path byReference:YES] autorelease];
		[sound play];
	}
}

/**
 * Manually save data.
 */
- (IBAction)saveAction:(id)sender {
  [updateIndicator startAnimation:sender];
  NSError *error = nil;
  if (![[self managedObjectContext] save:&error]) {
    [[NSApplication sharedApplication] presentError:error];
  }
  [websitesTableView reloadData];
  [updateIndicator stopAnimation:sender];
}

/**
 * Reset the website icon to default.
 */
- (IBAction)resetWebsiteIcon:(id)sender {
  NSEntityDescription *entity = [[managedObjectModel entitiesByName] valueForKey:@"Website"];
  NSPredicate *predicate = [NSPredicate predicateWithFormat:@"address == %@", [websiteAddress stringValue]];
  NSFetchRequest *fetch = [[NSFetchRequest alloc] init];
  [fetch setEntity:entity];
  [fetch setPredicate:predicate];

  NSArray *contextArray = [managedObjectContext executeFetchRequest:fetch error:nil];
  if ([contextArray count] > 0) {
    NSData *defaultImageData = (NSData *)[[NSImage imageNamed:@"websites"] TIFFRepresentation];
    [[contextArray objectAtIndex:0] setValue:defaultImageData forKey:@"icon"];
  }

  [fetch release];
  [websitesTableView reloadData];
}

# pragma mark -
# pragma mark Cleanup

/**
 * Implementation of dealloc; to release the retained variables.
 */
- (void)dealloc {
  [managedObjectContext release], managedObjectContext = nil;
  [managedObjectModel release], managedObjectModel = nil;
  [super dealloc];
}

@end
