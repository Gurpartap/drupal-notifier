//
//  PreferencesWindowController.m
//  Drupal Notifier
//
//  Created by Gurpartap Singh on 24/03/09.
//  Copyright 2009 Gurpartap Singh. All rights reserved.
//

#import "PreferencesWindowController.h"

@implementation PreferencesWindowController
-(IBAction)showProjectPage:(id)sender {
  [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://myzonelabs.com/notifier-app"]];
}

-(IBAction)showLicense:(id)sender {
  [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://www.gnu.org/copyleft/gpl.html"]];
}

-(IBAction)mailMe:(id)sender {
  [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"mailto:gurpartap@gmail.com"]];
}

-(IBAction)showWebsiteDetailsSheet:(id)sender {
  NSMutableDictionary *initialPrefs = [NSMutableDictionary dictionary];
  NSMutableDictionary *savedPrefs = [[NSUserDefaultsController sharedUserDefaultsController] values];
  
  if ([savedPrefs valueForKey:@"siteName"]) {
    [initialPrefs setObject:[savedPrefs valueForKey:@"siteName"] forKey:@"siteName"];
  }
  else {
    [initialPrefs setObject:@"" forKey:@"siteName"];
  }
  if ([savedPrefs valueForKey:@"siteAddress"]) {
    [initialPrefs setObject:[savedPrefs valueForKey:@"siteAddress"] forKey:@"siteAddress"];
  }
  else {
    [initialPrefs setObject:@"" forKey:@"siteAddress"];
  }
  if ([savedPrefs valueForKey:@"siteUsername"]) {
    [initialPrefs setObject:[savedPrefs valueForKey:@"siteUsername"] forKey:@"siteUsername"];
  }
  else {
    [initialPrefs setObject:@"" forKey:@"siteUsername"];
  }
  if ([savedPrefs valueForKey:@"sitePassword"]) {
    [initialPrefs setObject:[savedPrefs valueForKey:@"sitePassword"] forKey:@"sitePassword"];
  }
  else {
    [initialPrefs setObject:@"" forKey:@"sitePassword"];
  }
  
  [[NSUserDefaults standardUserDefaults] registerDefaults:initialPrefs];
  [[NSUserDefaultsController sharedUserDefaultsController] setInitialValues:initialPrefs];

  [NSApp beginSheet:websiteSheet
     modalForWindow:prefWindow
      modalDelegate:self
     didEndSelector:@selector(didEndSheet:returnCode:contextInfo:)
        contextInfo:nil];
}

- (void)didEndSheet:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo
{
  [sheet orderOut:self];
}

- (IBAction)closeWebsiteDetailsSheet:(id)sender {
  [[NSUserDefaultsController sharedUserDefaultsController] revertToInitialValues:self];
  [NSApp endSheet:websiteSheet];
  [websiteSheet close];
}

- (IBAction)connectWebsiteDetailsSheet:(id)sender {
  if ([(NSString *)[siteName stringValue] length] == 0
    || [(NSString *)[siteAddress stringValue] length] == 0
    || [(NSString *)[siteUsername stringValue] length] == 0
    || [(NSString *)[sitePassword stringValue] length] == 0) {
    [errorLabel setStringValue:@"Please fill all the fields."];
    return;
  }
  [errorLabel setStringValue:@""];
  [progressIndicator startAnimation:self];
  WSMethodInvocationRef rpcCall;
  NSURL                *rpcURL;
  NSString             *methodName;
  NSMutableDictionary  *params;
  NSArray              *paramsOrder;
  NSDictionary         *result;
  NSString             *username;
  NSString             *password;
	
  //
  //    1. Define the location of the RPC service and method
  //
	
  // Create the URL to the RPC service
	rpcURL = [NSURL URLWithString:(NSString *)[[siteAddress stringValue] stringByAppendingString:@"/xmlrpc.php"]];

  // Assign the method name to call on the RPC service
  methodName = @"desktop_notify.verifyUserDetails";
  
  // Create a method invocation
  // First parameter is the URL to the RPC service
  // Second parameter is the name of the RPC method to call
  // Third parameter is a constant to specify the XML-RPC protocol
  rpcCall = WSMethodInvocationCreate((CFURLRef)rpcURL,(CFStringRef)methodName, kWSXMLRPCProtocol);
	
  //
  //     2. Set up the parameters to be passed to the RPC method
  //
	
  // Get the users choices
  username = [siteUsername stringValue];
  password = [sitePassword stringValue];
	
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
//      NSRunAlertPanel([NSString stringWithFormat:@"Error %@",
//					 [result objectForKey: (NSString*)kWSFaultCode]],
//					[result objectForKey: (NSString*)kWSFaultString],
//					@"OK", @"", @"");
    NSString *errorString = [result objectForKey:(NSString*)kWSFaultString];
    if (errorString == @"CFStreamFault") {
      errorString = @"Incorrect Site Address (expected e.g. http://www.example.com";
    }
    [errorLabel setStringValue:errorString];
    [progressIndicator stopAnimation:self];   
  }
  else {
    NSTimer *timer;
    timer = [NSTimer scheduledTimerWithTimeInterval: 1
      target: self
      selector: @selector(handleTimer:)
      userInfo: nil
      repeats: NO];

    
      // Otherwise, pull the results from the dictionary as an array
      //NSArray *array = [result objectForKey:(NSString*)kWSMethodInvocationResult];
	
      // Display the entire array result from the server
	//description= Returns a string that represents the contents of the receiver, formatted as a property list.
      //[m_result setStringValue: [array description]];
      //int choice = NSRunAlertPanel (@"Confirm",[array description], @"Ok", @"Cancel",nil); 

		//NSLog (@"NSRunAlertPanel returned %d", choice);  
  }
	
  // Release those items that need to be released
  [params release];
  params = nil;
  [paramsOrder release];
  paramsOrder = nil;
  [result release];
  result = nil;
}

- (void)handleTimer: (NSTimer *) timer
{
  [progressIndicator stopAnimation:self];   
  [NSApp endSheet:websiteSheet];
  [websiteSheet close];
}

@end
