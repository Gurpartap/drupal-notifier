//
//  ImageTextCell.m
//  SofaControl
//
//  Adopted by Gurpartap Singh for Drupal Notifier.
//  Originally created by Martin Kahr on 10.10.06.
//  Copyright 2006 CASE Apps. All rights reserved.
//

#import "ImageTextCell.h"

@implementation ImageTextCell

# pragma mark -
# pragma mark Implementation methods

/**
 * Method to set delegate for table cell data.
 */
- (void)setDataDelegate:(NSObject *)aDelegate {
	[aDelegate retain];	
	[delegate autorelease];
	delegate = aDelegate;	
}

/**
 * Implementation of drawWithFrame.
 */
- (void)drawWithFrame:(NSRect)cellFrame inView:(NSView *)controlView {
	[self setTextColor:[NSColor blackColor]];
	
	NSObject* data = [self objectValue];
	
	// give the delegate a chance to set a different data object
	if ([delegate respondsToSelector:@selector(dataElementForCell:)]) {
		data = [delegate dataElementForCell:self];
	}

	BOOL elementDisabled = NO;
	if ([delegate
       respondsToSelector:@selector(disabledForCell:data:)]) {
		elementDisabled = [delegate disabledForCell:self data:data];
	}

	NSColor* primaryColor = [self isHighlighted] ?
  [NSColor alternateSelectedControlTextColor] :
  (elementDisabled? [NSColor disabledControlTextColor] : [NSColor textColor]);
	NSString* primaryText = [delegate primaryTextForCell:self data:data];
	NSMutableDictionary* primaryTextAttributes = [NSMutableDictionary
                                         dictionaryWithObjectsAndKeys:
                                         primaryColor,
                                         NSForegroundColorAttributeName,
                                         [NSFont systemFontOfSize:13],
                                         NSFontAttributeName,
                                         nil];
  if ([self isHighlighted]) {
    NSShadow *shadow = [[[NSShadow alloc] init] autorelease];
    [shadow setShadowOffset:NSMakeSize(0, -1)];
    [shadow setShadowBlurRadius:0.75];
    [shadow setShadowColor:[NSColor darkGrayColor]];

    [primaryTextAttributes setObject:[NSFont boldSystemFontOfSize:13]
                              forKey:NSFontAttributeName];
    [primaryTextAttributes setObject:shadow
                              forKey:NSShadowAttributeName];
  }

	[primaryText drawAtPoint:
   NSMakePoint(cellFrame.origin.x+cellFrame.size.height+10, cellFrame.origin.y)
            withAttributes:primaryTextAttributes];
	
	NSColor* secondaryColor = [self isHighlighted] ?
  [NSColor alternateSelectedControlTextColor] :
  [NSColor disabledControlTextColor];
	NSString* secondaryText = [delegate secondaryTextForCell:self data:data];
	NSDictionary* secondaryTextAttributes = [NSDictionary
                                           dictionaryWithObjectsAndKeys:
                                           secondaryColor,
                                           NSForegroundColorAttributeName,
                                           [NSFont systemFontOfSize:10],
                                           NSFontAttributeName, nil];	
	[secondaryText drawAtPoint:
   NSMakePoint(cellFrame.origin.x+cellFrame.size.height+10,
               cellFrame.origin.y+cellFrame.size.height/2) 
              withAttributes:secondaryTextAttributes];
	
	
	[[NSGraphicsContext currentContext] saveGraphicsState];
	float yOffset = cellFrame.origin.y;
	if ([controlView isFlipped]) {
		NSAffineTransform* xform = [NSAffineTransform transform];
		[xform translateXBy:0.0 yBy:cellFrame.size.height];
		[xform scaleXBy:1.0 yBy:-1.0];
		[xform concat];		
		yOffset = 0-cellFrame.origin.y;
	}	
	NSImage* icon = [delegate iconForCell:self data:data];	
	
	NSImageInterpolation interpolation = [[NSGraphicsContext currentContext]
                                        imageInterpolation];
	[[NSGraphicsContext currentContext]
   setImageInterpolation:NSImageInterpolationHigh];	
	
	[icon drawInRect:NSMakeRect(cellFrame.origin.x+5,
                              yOffset+3,
                              cellFrame.size.height-6,
                              cellFrame.size.height-6)
          fromRect:NSMakeRect(0,0,[icon size].width, [icon size].height)
         operation:NSCompositeSourceOver
          fraction:1.0];
	
	[[NSGraphicsContext currentContext] setImageInterpolation:interpolation];
	[[NSGraphicsContext currentContext] restoreGraphicsState];
}

/**
 * Implementation of copyWithZone.
 */
- copyWithZone:(NSZone *)zone {
	ImageTextCell *cell = (ImageTextCell *)[super copyWithZone:zone];
	cell->delegate = nil;
	[cell setDataDelegate:delegate];
  return cell;
}

# pragma mark -
# pragma mark Cleanup

/**
 * Implementation of dealloc.
 */
- (void)dealloc {
	[self setDataDelegate:nil];
  [super dealloc];
}

@end
