//
//  LNPebbleWatch.h
//  Lignite
//
//  Created by Edwin Finch on 11/6/15.
//  Copyright © 2015 Edwin Finch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface LNPebbleWatch : NSObject

enum PebbleModel {
	PEBBLE_MODEL_NOT_FOUND = -1,
	PEBBLE_MODEL_BIANCA_BLACK = 0,
	PEBBLE_MODEL_BIANCA_SILVER,
	PEBBLE_MODEL_TINTIN_BLACK,
	PEBBLE_MODEL_TINTIN_RED,
	PEBBLE_MODEL_TINTIN_WHITE,
	PEBBLE_MODEL_BOBBY_BLACK,
	PEBBLE_MODEL_BOBBY_GOLD,
	PEBBLE_MODEL_BOBBY_SILVER,
	PEBBLE_MODEL_SNOWY_BLACK,
	PEBBLE_MODEL_SNOWY_RED,
	PEBBLE_MODEL_SNOWY_WHITE,
	PEBBLE_MODEL_SPALDING_20MM_SILVER,
	PEBBLE_MODEL_SPALDING_20MM_BLACK,
	PEBBLE_MODEL_SPALDING_14MM_SILVER,
	PEBBLE_MODEL_SPALDING_14MM_ROSE_GOLD,
	PEBBLE_MODEL_SPALDING_14MM_BLACK,
	PEBBLE_MODEL_MAXIMUM
};

enum PebblePlatform {
	PEBBLE_PLATFORM_NOT_FOUND = -1,
	PEBBLE_PLATFORM_APLITE = 0,
	PEBBLE_PLATFORM_BASALT,
	PEBBLE_PLATFORM_CHALK
};

/**
 Whether or not the watch is black and white only.
 */
@property BOOL isBlackAndWhite;

/**
 Whether or not the watch has a round display.
 */
@property BOOL isRoundDisplay;

/**
 The model of the watch.
 */
@property enum PebbleModel model;

/**
 The platform of the watch.
 */
@property enum PebblePlatform platform;

/**
 The internal platform name of the watch.
 */
@property NSString *platformName;

/**
 The internal model name of the watch.
 */
@property NSString *modelName;

/**
 The localized model name of the watch, user-friendly.
 */
@property NSString *localizedModelName;

/**
 The model image as provided by Lignite.
 */
@property UIImage *modelImage;

/**
 Initializes a watch at a certain index.
 
 @param the index of the watch (essentially enum PebbleModel).
 @returns an LNPebbleWatch instance.
 */
- (id)initWithModelIndex:(int)index;

@end
