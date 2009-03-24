//
//  MainController.m
//  Drupal Notifier
//
//  Created by Gurpartap Singh on 24/03/09.
//  Copyright 2009 Gurpartap Singh. All rights reserved.
//

#import "MainController.h"

@implementation MainController
- (void)awakeFromNib {
  // Create an NSStatusItem.
  float width = 30.0;
  statusItem = [[[NSStatusBar systemStatusBar] statusItemWithLength:width] retain];

  // Used to detect where our files are.
  NSBundle *bundle = [NSBundle mainBundle];
  statusItemImage = [[NSImage alloc] initWithContentsOfFile:[bundle pathForResource:@"druplicon" ofType:@"png"]];

  // Sets the images in our NSStatusItem.
  [statusItem setImage:statusItemImage];

  // Create a NSMenu for NSStatusItem.
  NSMenu *statusItemMenu;
  statusItemMenu = [[NSMenu alloc] initWithTitle:@""];

  // Sets the menu items for statusItemMenu.
  [statusItemMenu addItemWithTitle:@"Check now" action:@selector(putGrowlingTigerOnFire:) keyEquivalent:@""];
  [statusItemMenu addItem:[NSMenuItem separatorItem]];
  [statusItemMenu addItemWithTitle:@"Preferences..." action:@selector(launchPreferencesWindow:) keyEquivalent:@""];
  [statusItemMenu addItem:[NSMenuItem separatorItem]];
  [statusItemMenu addItemWithTitle:@"About..." action:@selector(orderFrontStandardAboutPanel:) keyEquivalent:@""];
  [statusItemMenu addItemWithTitle:@"Quit Drupal Notifier" action:@selector(terminate:) keyEquivalent:@""];
  [statusItem setMenu:statusItemMenu];
  [statusItemMenu release];
  [NSApp setDelegate:self];
  PreferencesWindowController = [[NSWindowController alloc] initWithWindowNibName:@"PreferencesWindow"]; 
  
  
  [GrowlApplicationBridge setGrowlDelegate:self];
  

  [self putGrowlingTigerOnFire:self];
  
}

- (void)putGrowlingTigerOnFire:(id)sender {
  NSMutableDictionary *savedPrefs = [[NSUserDefaultsController sharedUserDefaultsController] values];
  
  if ([(NSString *)[savedPrefs valueForKey:@"siteName"] length] == 0
    || [(NSString *)[savedPrefs valueForKey:@"siteAddress"] length] == 0
    || [(NSString *)[savedPrefs valueForKey:@"siteUsername"] length] == 0
    || [(NSString *)[savedPrefs valueForKey:@"sitePassword"] length] == 0) {
    return;
  }

  [self notificationTimerCallback:notificationTimer];
  [notificationTimer invalidate];
  notificationTimer = [NSTimer
    scheduledTimerWithTimeInterval:[[savedPrefs valueForKey:@"checkInterval"] intValue]// * 60
    target:self
    selector:@selector(notificationTimerCallback:)
    userInfo:nil
    repeats:YES];
}

- (NSDictionary*) registrationDictionaryForGrowl
{
  // For this application, only one notification is registered
  NSArray* notifications = [NSArray arrayWithObject:@"Drupal Notifier"];

  NSDictionary* growlRegistration = [NSDictionary dictionaryWithObjectsAndKeys: 
    notifications, GROWL_NOTIFICATIONS_DEFAULT,
    notifications, GROWL_NOTIFICATIONS_ALL, nil];

  return (growlRegistration);
}



- (void)notificationTimerCallback:(NSTimer *)notificationTimer {
  NSMutableDictionary *savedPrefs = [[NSUserDefaultsController sharedUserDefaultsController] values];

  WSMethodInvocationRef rpcCall;
  NSURL                *rpcURL;
  NSString             *methodName;
  NSMutableDictionary  *params;
  NSArray              *paramsOrder;
  NSDictionary         *result;
  NSString             *username;
  NSString             *password;
  NSString             *growlString;
	
  //
  //    1. Define the location of the RPC service and method
  //
	
  // Create the URL to the RPC service
  // rpcURL = [NSURL URLWithString:@"http://localhost:8888/cmt/xmlrpc.php"];
	rpcURL = [NSURL URLWithString:(NSString *)[[savedPrefs valueForKey:@"siteAddress"] stringByAppendingString:@"/xmlrpc.php"]];

  // Assign the method name to call on the RPC service
  methodName = @"desktop_notify.getNewCommentsCount";
  
  // Create a method invocation
  // First parameter is the URL to the RPC service
  // Second parameter is the name of the RPC method to call
  // Third parameter is a constant to specify the XML-RPC protocol
  rpcCall = WSMethodInvocationCreate((CFURLRef)rpcURL,(CFStringRef)methodName, kWSXMLRPCProtocol);
	
  //
  //     2. Set up the parameters to be passed to the RPC method
  //
	
  // Get the users choices
  username = [savedPrefs valueForKey:@"siteUsername"];
  password = [savedPrefs valueForKey:@"sitePassword"];
	
  // Add the users choices to the dictionary to be passed as parameters
  params = [NSMutableDictionary dictionaryWithCapacity:2];
  [params setObject:username forKey:username];
  [params setObject:password forKey:password];
	
  // Create the array to specify the order of the parameter values
  paramsOrder = [NSArray arrayWithObjects:username,
			   password, nil];
	
  // Set the method invocation parameters
  // First parameter is the method invocation created above
  // Second parameter is a dictionary containing the parameters themselves
  // Third parameter is an array specifying the order of the parameters
  WSMethodInvocationSetParameters(rpcCall, (CFDictionaryRef)params,(CFArrayRef)paramsOrder);
	
  //
  //    3. Make the call and parse the results!
  //
	
  // Invoke the method which returns a dictionary of results
  result = (NSDictionary*)WSMethodInvocationInvoke(rpcCall);
	
  // If the results are a fault, display an error to the user with the
  // fault code and descriptive string
  if (WSMethodResultIsFault((CFDictionaryRef)result)) {
    growlString = [[result objectForKey:(NSString*)kWSFaultString] description];
  }
  else {
    NSString *count = [result storedValueForKey:(NSString*)kWSMethodInvocationResult];
    if ([count isEqualToString:@"0"]) {
      return;
    }
    if ([count isEqualToString:@"1"]) {
      growlString = [count stringByAppendingString:@" unapproved comment"];
    }
    else {
      growlString = [count stringByAppendingString:@" unapproved comments"];
    }
  }

  NSImage *anImage;
  NSString *imagePath;

  imagePath = [[NSBundle mainBundle] pathForImageResource:@"druplicon.large.png"];
  anImage = [[NSImage alloc] initWithContentsOfFile:imagePath];
  
  [GrowlApplicationBridge
     notifyWithTitle:growlString
         description:[savedPrefs valueForKey:@"siteName"]
    notificationName:@"Drupal Notifier"
            iconData:[NSData dataWithData:[anImage TIFFRepresentation]]
            priority:0
            isSticky:NO
        clickContext:@"clickContext"];

  // Release those items that need to be released
  [params release];
  params = nil;
  [paramsOrder release];
  paramsOrder = nil;
  [result release];
  result = nil;
}

- (void)growlNotificationWasClicked:(id)clickContext {
  NSString *adminURL = (NSString *)[[[NSUserDefaults standardUserDefaults] stringForKey:@"siteAddress"] stringByAppendingString:@"/admin/content/comment/approval"];
  [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:adminURL]];
}

- (IBAction)launchPreferencesWindow:(id)sender {
  [PreferencesWindowController showWindow:self];
}

@end
