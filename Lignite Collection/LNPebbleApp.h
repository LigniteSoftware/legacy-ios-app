//
//  LNPebbleApp.h
//  Lignite
//
//  Created by Edwin Finch on 11/2/15.
//  Copyright © 2015 Edwin Finch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LNPebbleWatch.h"

@interface LNPebbleApp : NSObject

/**
 The total amount of apps that are available to the user.
 */
#define APP_COUNT 17

/**
 No explanation needed
 */
typedef enum {
	WATCH_APP_NOTHING = -1,
	WATCH_APP_SPEEDOMETER = 0,
	WATCH_APP_KNIGHTRIDER,
	WATCH_APP_CHUNKY,
	WATCH_APP_LINES,
	WATCH_APP_COLOURS,
	WATCH_APP_TIMEDOCK,
	WATCH_APP_TREE_OF_COLOURS,
	WATCH_APP_TIMEZONES,
	WATCH_APP_SLOT_MACHINE,
	WATCH_APP_PULSE,
	WATCH_APP_SIMPLIFIED_ANALOGUE,
	WATCH_APP_PERONSAL,
	WATCH_APP_BEAT,
	WATCH_APP_EQUALIZER,
	WATCH_APP_UPSIDE_DOWN,
	WATCH_APP_PLAIN_WEATHER,
	WATCH_APP_ESSENTIALLY,
	WATCH_APP_NOT_FOUND
} WatchApp;

/**
 The internal name of the watchapp.
 */
@property NSString *appName;

/**
 The human readable name of the watchapp.
 */
@property NSString *localizedName;

/**
 The human readable, localized description of the watchapp.
 */
@property NSString *localizedDescription;

/**
 The in-app purchase SKU.
 */
@property NSString *sku;

/**
 The location of the Pebble app in the Pebble appstore (end of address).
 */
@property NSString *appstoreLocation;

/**
 The UUID associated with the watchapp.
 */
@property NSString *uuidString;

/**
 The platforms that this watchface are available to.
 */
@property NSArray *targetPlatforms;

/**
 The capabilities of this watchapp (see possibilities.json for more info).
 */
@property NSArray *capabilities;

/**
 The tags that this watchapp has associated with it (see possibilities.json for more info).
 */
@property NSDictionary *tags;

/**
 Whether or not Kickstarter backers own it.
 */
@property BOOL isKickstarter;

/**
 The bundles that this watchapp belongs to.
 */
@property NSDictionary *bundles;

/**
 The bundle that the watchapp is associated with.
 */
@property NSString *bundleName;

/**
 The associated WatchApp.
 */
@property WatchApp watchApp;

/**
 Initializes an LNPebbleApp with an appname of any kind. Will pull all data from its associated info JSON.
 
 @param The watchapp's internal identifier (of type WatchApp)
 @see appNameForWatchApp:
 @return An instance of LNPebbleApp.
 */
- (id)initWithAppIndex:(WatchApp)watchApp;

/**
 Returns an NSString containing the internal watchapp name for a specified watchapp.
 
 @param The WatchApp that is to be looked up.
 @see enum WatchApp
 @return The internal watchapp name for the WatchApp requested.
 */
+ (NSString*)appNameForWatchApp:(WatchApp)watchApp;

/**
 Returns a dictionary containing all keys that are part of the watchapp's properties.
 
 @returns an NSDictionary containing all of the keys with @"yes" as a value
 */
- (NSDictionary*)allKeysDictionary;

/**
 Returns whether or not a watchapp is compatible with a certain platform.
 @param the platform to check for.
 @returns a BOOL stating whether or not it's compatible.
 */
- (BOOL)isCompatibleWithPlatform:(enum PebblePlatform)pebblePlatform;

@end
