//
//  LNPreviewBuilderController.h
//  Lignite
//
//  Created by Edwin Finch on 8/16/15.
//  Copyright (c) 2015 Edwin Finch. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LNPebbleApp.h"
#import "LNPebbleWatch.h"

@interface LNPreviewBuilder : NSObject

/**
 Returns the user-set default Pebble.
 @returns the user-set Pebble in the preinitialized format of LNPebbleWatch*
 */
+ (LNPebbleWatch*)defaultPebble;

/**
 Returns the user-set default Pebble.
 @returns the user-set Pebble in an integer format (matches with the value in the PebbleModel enum).
 */
+ (NSInteger)defaultPebbleWatch;

/**
 Sets the user-set default Pebble
 @param the Pebble to set it to
 */
+ (void)setDefaultPebbleWatch:(LNPebbleWatch*)pebble;

/**
 Returns a compiled image of a screenshot on top of a Pebble, as well as a checkmark indicating whether or not it is purchased.
 @param the Pebble to apply the screenshot to
 @param the screenshot to apply to the provided Pebble
 @param whether or not the watchapp is purchased. If so, it adds a checkmark.
 @returns the combined image
 */
+ (UIImage*)imageForPebble:(LNPebbleWatch*)pebbleWatch andScreenshot:(UIImage*)screenshot markAsPurchased:(BOOL)purchased ;

/**
 Returns a screenshot based on a Pebble model, watchapp, and index of image.
 @param the watch the screenshot is being applied to
 @param the watchapp that is being applied
 @param the index of the watchapp screenshot that is being loaded
 */
+ (UIImage*)screenshotForPebble:(LNPebbleWatch*)pebbleWatch forWatchApp:(LNPebbleApp*)watchApp atIndex:(int)index;

@end
