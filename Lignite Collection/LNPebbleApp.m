//
//  LNPebbleApp.m
//  Lignite
//
//  Created by Edwin Finch on 11/2/15.
//  Copyright © 2015 Edwin Finch. All rights reserved.
//

#import "LNPebbleApp.h"

@interface LNPebbleApp ()

@end

@implementation LNPebbleApp

/*
 Internal functions
 */

+ (NSDictionary*)readInfoJSONWithAppName:(NSString*)appName {
	NSData *data = [[NSData alloc]initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"%@_info", appName] ofType:@"json"]];
	NSError *error;
	NSDictionary *rawInfoDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
	if(error){
		NSLog(@"Error creating dictionary for LNPebbleApp: %@", [error localizedDescription]);
	}
	return rawInfoDictionary;
}

+ (NSArray*)appNameArray {
	return [[NSArray alloc]initWithObjects:
		   @"speedometer", @"rightnighter",
		   @"chunky", @"lines",
		   @"colours", @"timedock",
		   @"treeofcolours", @"timezones",
		   @"slotmachine", @"pulse",
		   @"simplifiedanalogue", @"personal",
		   @"beat", @"equalizer",
		   @"upsidedown", @"plainweather",
			@"essentially", nil];
}

/*
 External functions
 */

- (id)initWithAppIndex:(WatchApp)watchApp {
	if(watchApp == WATCH_APP_NOTHING){
		return nil;
	}
	self = [super init];
	if(self){
		self.appName = [LNPebbleApp appNameForWatchApp:watchApp];
		
		NSDictionary *rawInfoDictionary = [LNPebbleApp readInfoJSONWithAppName:self.appName];
		self.localizedName = [rawInfoDictionary objectForKey:@"name"];
		NSString *key = [NSString stringWithFormat:@"%@_description", self.appName];
		self.localizedDescription = NSLocalizedString(key, nil);
		self.sku = [rawInfoDictionary objectForKey:@"sku"];
		self.appstoreLocation = [rawInfoDictionary objectForKey:@"appstore_location"];
		self.uuidString = [rawInfoDictionary objectForKey:@"uuid"];
		self.targetPlatforms = [rawInfoDictionary objectForKey:@"target_platforms"];
		self.capabilities = [rawInfoDictionary objectForKey:@"capabilities"];
		self.tags = [rawInfoDictionary objectForKey:@"tags"];
		self.bundles = [rawInfoDictionary objectForKey:@"bundles"];
		for(int i = 0; i < [[self.bundles allKeys] count]; i++){
			NSString *bundleString = [[self.bundles allKeys] objectAtIndex:i];
			BOOL isBundle = [[self.bundles objectForKey:bundleString] isEqualToNumber:@(1)];
			if(isBundle){
				self.bundleName = bundleString;
				//NSLog(@"Watchapp %@ belongs to bundle %@", self.appName, self.bundleName);
				break;
			}
		}
		self.watchApp = watchApp;
		
		self.isKickstarter = [[self.tags objectForKey:@"kickstarter"] isEqualToNumber:@(1)];
		
		//NSLog(@"Created LNPebble app %d:\n self.localizedName: %@\n self.targetPlatforms: %@\n self.tags: %@", watchApp, self.localizedName, self.targetPlatforms, self.tags);
	}
	return self;
}

+ (NSString*)appNameForWatchApp:(WatchApp)watchApp {
	return [[LNPebbleApp appNameArray] objectAtIndex:watchApp];
}

- (NSDictionary*)allKeysDictionary {
	NSMutableDictionary *returnDictionary = [[NSMutableDictionary alloc]init];
	for(int i = 0; i < [self.bundles.allKeys count]; i++){
		NSString *key = [self.bundles.allKeys objectAtIndex:i];
		if([[self.bundles objectForKey:key] isEqual:@(1)]){
			[returnDictionary setObject:@"yes" forKey:key];
		}
		else{
			//NSLog(@"App %@ does not include the %@ bundle.", self.appName, key);
		}
	}
	for(int i = 0; i < [self.tags.allKeys count]; i++){
		NSString *key = [self.tags.allKeys objectAtIndex:i];
		if([[self.tags objectForKey:key] isEqual:@(1)]){
			[returnDictionary setObject:@"yes" forKey:key];
		}
		else{
			//NSLog(@"App %@ does not include the %@ tag.", self.appName, key);
		}
	}
	for(int i = 0; i < [self.targetPlatforms count]; i++){
		[returnDictionary setObject:@"yes" forKey:[self.targetPlatforms objectAtIndex:i]];
	}
	return [[NSDictionary alloc]initWithDictionary:returnDictionary];
}

- (BOOL)isCompatibleWithPlatform:(enum PebblePlatform)pebblePlatform {
	if(pebblePlatform == PEBBLE_PLATFORM_APLITE && ![self.targetPlatforms containsObject:@"aplite"]){
		return NO;
	}
	else if(pebblePlatform == PEBBLE_PLATFORM_BASALT && ![self.targetPlatforms containsObject:@"basalt"]){
		return NO;
	}
	else if(pebblePlatform == PEBBLE_PLATFORM_CHALK && ![self.targetPlatforms containsObject:@"chalk"]){
		return NO;
	}
	return YES;
}

+ (NSString*)getLocalizedAppDescriptionFromType:(WatchApp)watchApp {
	NSString *description = [NSString stringWithFormat: @"%@_description", [LNPebbleApp appNameForWatchApp:watchApp]];
	return NSLocalizedString(description, nil);
}

@end
