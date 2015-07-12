//
//  DataFramework.h
//  Lignite
//
//  Created by Edwin Finch on 2015-05-18.
//  Copyright (c) 2015 Edwin Finch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PebbleInfo.h"
#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@interface DataFramework : NSObject

+ (UIColor *)colorFromHexString:(NSString *)hexString;

+ (void)sendLigniteGuardUnlockToPebble:(AppTypeCode)code;

+ (NSMutableDictionary*)getSettingsDictionaryForAppType:(AppTypeCode)type;
+ (void)setSettingsDictionaryForAppType:(AppTypeCode)type :(NSMutableDictionary*)dict;
+ (void)updateStringSetting:(AppTypeCode)type :(NSString*)setting :(NSString*)key;
+ (void)updateBooleanSetting:(AppTypeCode)type :(BOOL)setting :(NSString*)key;

+ (void)sendNumberToPebble:(NSNumber*)number :(NSInteger)pebbleKey :(NSString*)storageKey :(NSString*)appUUID;
+ (void)sendBooleanToPebble:(BOOL)boolean :(NSInteger)pebbleKey :(NSString*)storageKey :(NSString*)appUUID;
+ (void)sendColourToPebble:(NSString*)colour :(NSInteger)pebbleKey :(NSString*)storageKey :(NSString*)appUUID;

+ (NSString*)getUserToken;
+ (void)setUserToken:(NSString*)newToken;
+ (NSString*)getUsername;
+ (void)setUsername:(NSString*)newUsername;
+ (NSDictionary*)getUserData;
+ (void)setUserData:(NSDictionary*)dict;
+ (BOOL)isUserLoggedIn;
+ (BOOL)setUserLoggedIn:(NSString*)accessCode :(BOOL)loggedIn;
+ (BOOL)isUserBacker;
+ (void)setUserBacker:(BOOL)backer;
+ (BOOL)hasUserTakenBackerQuestion;
+ (void)setUserTakenBackerQuestion:(BOOL)taken;
+ (NSString*)getCurrentDevice;

@end