//
//  Website.h
//  Drupal Notifier
//
//  Created by Gurpartap Singh on 26/06/09.
//  Copyright 2009 Gurpartap Singh. All rights reserved.
//

#import <CoreData/CoreData.h>

@class Notification;

@interface Website :  NSManagedObject  
{
}

@property (nonatomic, retain) NSString * address;
@property (nonatomic, retain) NSNumber * updateInterval;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * username;
@property (nonatomic, retain) NSString * password;
@property (nonatomic, retain) NSData * icon;
@property (nonatomic, retain) NSSet* notifications;

@end


@interface Website (CoreDataGeneratedAccessors)
- (void)addNotificationsObject:(Notification *)value;
- (void)removeNotificationsObject:(Notification *)value;
- (void)addNotifications:(NSSet *)value;
- (void)removeNotifications:(NSSet *)value;

@end

