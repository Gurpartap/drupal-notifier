//
//  UpdateIntervalSlider.m
//  Drupal Notifier
//
//  Created by Gurpartap Singh on 25/06/09.
//  Copyright 2009 Gurpartap Singh. All rights reserved.
//

#import "UpdateIntervalSlider.h"
#import "WebsitesViewController.h"


@implementation UpdateIntervalSlider

# pragma mark -
# pragma mark Delegate methods

/**
 * Implementation of mouseDown.
 */
- (void)mouseDown:(NSEvent *)event {
  [super mouseDown:event];
  // Mouse up:
  [updateIntervalTime setStringValue:@""];
}

# pragma mark -
# pragma mark Implementation methods

/**
 * Display the amount of time in selection, while sliding.
 */
- (IBAction)updateIntervalChange:(id)sender {
  double range = [sender maxValue] - [sender minValue];
  double tickInterval = range / ([sender numberOfTickMarks] - 1);    
  
  double relativeValue = [sender doubleValue] - [sender minValue];
  
  // Get the distance to the nearest tick.
  int nearestTick = round(relativeValue / tickInterval);
  double distance = relativeValue - nearestTick * tickInterval;
  
  // Change the check here depending on how much resistance you
  // want, or if you don't want it to depend on the tick interval.
  if (fabs(distance) < tickInterval / 4) {
    [sender setIntValue:[sender intValue] - distance];
  }

  if ([sender intValue] < 60) {
    [sender setIntValue:60];
    [updateIntervalTime setStringValue:[self stringForLifetsime:60]];
  }
  else {
    [updateIntervalTime setStringValue:[self stringForLifetsime:[sender intValue]]];
  }
}

/**
 * Return a time formatted as a string with unit names.
 */
- (NSString *)stringForLifetsime:(time_t)lifetime {
  BOOL displaySeconds = NO;
  NSMutableString *string = [NSMutableString string];
  NSString *separator = @" ";
  NSString *key = NULL;
  
  // Break the lifetime up into time units
  time_t days     = (lifetime / 86400);
  time_t hours    = (lifetime / 3600 % 24);
  time_t minutes  = (lifetime / 60 % 60);
  time_t seconds  = (lifetime % 60);
  
  // If we aren't going to display seconds, round up
  if (!displaySeconds) {
    if (seconds >  0) { seconds = 0; minutes++; }
    if (minutes > 59) { minutes = 0; hours++; }
    if (hours   > 23) { hours   = 0; days++; }
  }
  
  if (days > 0) {
    key = (days > 1) ? @"days" : @"day"; 
    [string appendFormat:@"%d %@", days, key];
  }
  
  if (hours > 0) {
    key = (hours > 1) ? @"hours" : @"hour"; 
    if ([string length] > 0) { [string appendString: separator]; }
    [string appendFormat:@"%d %@", hours, key];
  }
  
  if (minutes > 0) {
    key = (minutes > 1) ? @"minutes" : @"minute"; 
    if ([string length] > 0) { [string appendString: separator]; }
    [string appendFormat:@"%d %@", minutes, key];
  }
  
  if (displaySeconds && (seconds > 0)) {
    key = (seconds > 1) ? @"seconds" : @"second"; 
    if ([string length] > 0) { [string appendString: separator]; }
    [string appendFormat:@"%d %@", seconds, key];
  }

  // Return an NSString (non-mutable) from our mutable temporary
  return [NSString stringWithString:string];
}

@end
