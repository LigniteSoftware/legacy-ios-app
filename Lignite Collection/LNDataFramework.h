//
//  DataFramework.h
//  Lignite
//
//  Created by Edwin Finch on 2015-05-18.
//  Copyright (c) 2015 Edwin Finch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LNAppInfo.h"
#import "LNSettingsViewController.h"
#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@interface LNDataFramework : NSObject

+ (UIColor *)colorFromHexString:(NSString *)hexString;
+ (void)setupDefaults;

+ (void)sendDictionaryToPebble:(NSDictionary*)dictionary forApp:(AppTypeCode)code withSettingsController:(UIViewController*)controller;
+ (void)sendLigniteGuardUnlockToPebble:(AppTypeCode)code settingsController:(UIViewController*)controller;

+ (NSMutableDictionary*)getSettingsDictionaryForAppType:(AppTypeCode)type;
+ (void)setSettingsDictionaryForAppType:(AppTypeCode)type dictionary:(NSMutableDictionary*)dict;
+ (void)updateStringSetting:(AppTypeCode)type string:(NSString*)setting key:(NSString*)key;
+ (void)updateBooleanSetting:(AppTypeCode)type boolean:(BOOL)setting key:(NSString*)key;
+ (void)updateNumberSetting:(AppTypeCode)type number:(NSNumber*)setting key:(NSString*)key;

+ (void)sendNumberToPebble:(NSNumber*)number pebbleKey:(NSInteger)pebbleKey storageKey:(NSString*)storageKey appUUID:(NSString*)appUUID fromController:(UIViewController*)controller;
+ (void)sendBooleanToPebble:(BOOL)boolean pebbleKey:(NSInteger)pebbleKey storageKey:(NSString*)storageKey appUUID:(NSString*)appUUID fromController:(UIViewController*)controller;
+ (void)sendStringToPebble:(NSString*)colour pebbleKey:(NSInteger)pebbleKey storageKey:(NSString*)storageKey appUUID:(NSString*)appUUID fromController:(UIViewController*)controller;

+ (AppTypeCode)getPreviousAppType;
+ (void)setPreviousAppType:(AppTypeCode)type;
+ (BOOL)pebbleImageIsTime:(NSString*)pebble;
+ (NSString*)defaultPebbleImage;
+ (void)setDefaultPebbleImage:(NSString*)pebbleImage;
+ (BOOL)hasAnsweredBackerQuestion;
+ (void)userAnsweredBackerQuestion:(BOOL)response;
+ (NSString*)getEmail;
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