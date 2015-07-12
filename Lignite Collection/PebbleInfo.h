//
//  PebbleInfo.h
//  Lignite
//
//  Created by Edwin Finch on 2015-05-17.
//  Copyright (c) 2015 Edwin Finch. All rights reserved.
//

#import <Foundation/Foundation.h>
#define APP_COUNT 10

@interface PebbleInfo : NSObject

typedef enum AppTypeCode {
    APP_TYPE_NOTHING = -1,
    APP_TYPE_SPEEDOMETER = 0,
    APP_TYPE_KNIGHTRIDER = 1,
    APP_TYPE_CHUNKY = 2,
    APP_TYPE_LINES = 3,
    APP_TYPE_COLOURS = 4,
    APP_TYPE_TIMEDOCK = 5,
    APP_TYPE_TREE_OF_COLOURS = 6,
    APP_TYPE_TIMEZONES = 7,
    APP_TYPE_SLOT_MACHINE = 8,
    APP_TYPE_PULSE = 9
}AppTypeCode;

+ (NSInteger)uuidEndingKeyForIndex:(AppTypeCode)code;
+ (NSInteger)unlockTokenKeyForIndex:(AppTypeCode)code;
+ (NSArray*)skuArray;
+ (NSArray*)uuidEndingArray;
+ (NSArray*)unlockTokenArray;
+ (NSArray*)uuidArray;
+ (NSArray*)locationArray;
+ (NSString*)getAppUUID:(AppTypeCode)code;
+ (AppTypeCode)getAppTypeCode:(NSString*)UUID;
+ (NSInteger)getSettingsCount:(AppTypeCode)code;
+ (Boolean)settingsEnabled:(AppTypeCode)code;
+ (NSString*)getAppNameFromType:(AppTypeCode)code;
+ (NSString*)getAppDescriptionFromType:(AppTypeCode)code;

@end
