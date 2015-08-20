//
//  PebbleInfo.h
//  Lignite
//
//  Created by Edwin Finch on 2015-05-17.
//  Copyright (c) 2015 Edwin Finch. All rights reserved.
//

#import <Foundation/Foundation.h>
#define APP_COUNT 14

@interface PebbleInfo : NSObject

typedef enum AppTypeCode {
    APP_TYPE_NOTHING = -1,
    APP_TYPE_SPEEDOMETER = 0,
    APP_TYPE_KNIGHTRIDER,
    APP_TYPE_CHUNKY,
    APP_TYPE_LINES,
    APP_TYPE_COLOURS,
    APP_TYPE_TIMEDOCK,
    APP_TYPE_TREE_OF_COLOURS,
    APP_TYPE_TIMEZONES,
    APP_TYPE_SLOT_MACHINE,
    APP_TYPE_PULSE,
    APP_TYPE_SIMPLIFIED_ANALOGUE,
    APP_TYPE_PERONSAL,
    APP_TYPE_BEAT,
    APP_TYPE_EQUALIZER
} AppTypeCode;

+ (NSInteger)uuidEndingKeyForIndex:(AppTypeCode)code;
+ (NSInteger)unlockTokenKeyForIndex:(AppTypeCode)code;
+ (NSArray*)skuArray;
+ (NSArray*)uuidEndingArray;
+ (NSArray*)unlockTokenArray;
+ (NSArray*)uuidArray;
+ (NSArray*)locationArray;
+ (NSArray*)nameArray;
+ (NSString*)getAppUUID:(AppTypeCode)code;
+ (AppTypeCode)getAppTypeCode:(NSString*)UUID;
+ (Boolean)settingsEnabled:(AppTypeCode)code;
+ (NSString*)getAppNameFromType:(AppTypeCode)code;
+ (NSString*)getAppDescriptionFromType:(AppTypeCode)code;

@end
