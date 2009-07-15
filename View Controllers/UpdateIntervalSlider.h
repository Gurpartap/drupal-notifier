//
//  UpdateIntervalSlider.h
//  Drupal Notifier
//
//  Created by Gurpartap Singh on 25/06/09.
//  Copyright 2009 Gurpartap Singh. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface UpdateIntervalSlider : NSSlider {
  IBOutlet NSTextField *updateIntervalTime;
}

- (IBAction)updateIntervalChange:(id)sender;
- (NSString *)stringForLifetsime:(time_t)lifetime;

@end
