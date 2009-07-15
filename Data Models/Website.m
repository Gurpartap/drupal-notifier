// 
//  Website.m
//  Drupal Notifier
//
//  Created by Gurpartap Singh on 26/06/09.
//  Copyright 2009 Gurpartap Singh. All rights reserved.
//

#import "Website.h"

#import "Notification.h"

@implementation Website 

@dynamic address;
@dynamic updateInterval;
@dynamic name;
@dynamic username;
@dynamic password;
@dynamic icon;
@dynamic notifications;

/**
 * Implementation of awakeFromInsert.
 */
- (void)awakeFromInsert {
  [super awakeFromInsert];
  NSData *defaultImageData = (NSData *)[[NSImage imageNamed:@"websites"]
                                        TIFFRepresentation];
  [self setValue:defaultImageData forKey:@"icon"];
}

/**
 * Implementation of validateAddress; validation for address attribute.
 */
- (BOOL)validateAddress:(NSString **)address error:(NSError **)error {
  NSString *val = *address;
  
  if (val == nil || [val length] == 0) {
    return NO;
  }
  
  NSURL *url = [NSURL URLWithString:val];
  
  // TODO: Validate the URL here.
  if (url == nil) {
    NSDictionary *userInfoDict = [NSDictionary
                                  dictionaryWithObject:@"Not a value address."
                                  forKey:NSLocalizedDescriptionKey];
    *error = [[[NSError alloc] initWithDomain:NSCocoaErrorDomain
                                         code:-1
                                     userInfo:userInfoDict]
              autorelease];
    return NO;
  }
  
  return YES;
}
/*
- (void)addNotificationsObject:(Notification *)value {
  NSLog(@"adding notification object");
  NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];
  
  [self willChangeValueForKey:@"notifications"
              withSetMutation:NSKeyValueUnionSetMutation
                 usingObjects:changedObjects];
  [[self primitiveNotifications] addObject:value];
  [self didChangeValueForKey:@"notifications"
             withSetMutation:NSKeyValueUnionSetMutation
                usingObjects:changedObjects];
  
  [changedObjects release];
}

- (void)removeNotificationsObject:(Notification *)value {
  NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];
  
  [self willChangeValueForKey:@"notifications"
              withSetMutation:NSKeyValueMinusSetMutation
                 usingObjects:changedObjects];
  [[self primitiveNotifications] removeObject:value];
  [self didChangeValueForKey:@"notifications"
             withSetMutation:NSKeyValueMinusSetMutation
                usingObjects:changedObjects];
  
  [changedObjects release];
}

- (void)addNotifications:(NSSet *)value {
  [self willChangeValueForKey:@"notifications"
              withSetMutation:NSKeyValueUnionSetMutation
                 usingObjects:value];
  [[self primitiveNotifications] unionSet:value];
  [self didChangeValueForKey:@"notifications"
             withSetMutation:NSKeyValueUnionSetMutation
                usingObjects:value];
}

- (void)removeNotifications:(NSSet *)value {
  [self willChangeValueForKey:@"notifications"
              withSetMutation:NSKeyValueMinusSetMutation
                 usingObjects:value];
  [[self primitiveNotifications] minusSet:value];
  [self didChangeValueForKey:@"notifications"
             withSetMutation:NSKeyValueMinusSetMutation
                usingObjects:value];
}
*/
@end
