//
//  DataFramework.h
//  Lignite
//
//  Created by Edwin Finch on 2015-05-18.
//  Copyright (c) 2015 Edwin Finch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LNSettingsViewController.h"
#import "LNPebbleApp.h"

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@interface LNDataFramework : NSObject

/**
 Returns a UIColor from a HEX string.
 
 @param the HEX string to convert.
 @returns the UIColor which coordinates with that string.
 */
+ (UIColor *)colorFromHexString:(NSString *)hexString;

/**
 Sets up the defaults for any watchapp which doesn't have settings for it yet.
 This should be called every launch.
 */
+ (void)setupDefaults;

/**
 Sends a dictionary to Pebble for a certain watchapp.
 
 @param the dictionary to send.
 @param the watchapp to send to.
 @param the settings controller that it came from.
 */
+ (void)sendDictionaryToPebble:(NSDictionary*)dictionary forWatchApp:(LNPebbleApp*)watchApp withSettingsController:(UIViewController*)controller;

/**
 Gets an up to date settings dictionary for a certain watchapp.
 
 @param the watchapp to get the dictionary for.
 */
+ (NSMutableDictionary*)getSettingsDictionaryForWatchApp:(LNPebbleApp*)watchApp;

/**
 Sets the settings dictionary for a certain watchapp.
 @param the watchapp to set into.
 @param the dictionary to set.
 */
+ (void)setSettingsDictionaryForWatchApp:(LNPebbleApp*)watchApp dictionary:(NSMutableDictionary*)dict;

/**
 Updates a number setting and sends it to a certain watchapp.
 
 @param the watchapp to send to.
 @param the number setting to update send.
 @param the key to send to.
 */
+ (void)updateNumberSetting:(LNPebbleApp*)watchApp number:(NSNumber*)setting key:(NSString*)key;

/**
 Sends a number setting to a certain watchapp.
 
 @param the number setting to update send.
 @param the key to send to the watchapp.
 @param the storage key to write to.
 @param the watchapp to send to.
 @param the source view controller.
 */
+ (void)sendNumberToPebble:(NSNumber*)number pebbleKey:(NSInteger)pebbleKey storageKey:(NSString*)storageKey forWatchApp:(LNPebbleApp*)watchApp fromController:(UIViewController*)controller;

/**
 Updates a boolean setting.
 
 @param the watchapp that is being updated.
 @param the boolean to update.
 @param the key to update.
 */
+ (void)updateBooleanSetting:(LNPebbleApp*)watchApp boolean:(BOOL)setting key:(NSString*)key;

/**
 Sends a boolean to Pebble.
 
 @param the boolean to send.
 @param the key to send to the watchapp.
 @param the storage key to write to.
 @param the watchapp to send to.
 @param the source view controller.
 */
+ (void)sendBooleanToPebble:(BOOL)boolean pebbleKey:(NSInteger)pebbleKey storageKey:(NSString*)storageKey forWatchApp:(LNPebbleApp*)watchApp fromController:(UIViewController*)controller;

/**
 Updates a string setting for a certain watchapp.
 
 @param the watchapp being updated.
 @param the string to update.
 @param the key to update.
 */
+ (void)updateStringSetting:(LNPebbleApp*)watchApp string:(NSString*)setting key:(NSString*)key;

/**
 Sends a string to a certain watchapp.
 
 @param the string to send.
 @param the key on Pebble to send to.
 @param the storage key to write to.
 @param the watchapp to send to.
 @param the source view controller.
 */
+ (void)sendStringToPebble:(NSString*)colour pebbleKey:(NSInteger)pebbleKey storageKey:(NSString*)storageKey forWatchApp:(LNPebbleApp*)watchApp fromController:(UIViewController*)controller;

/**
 Returns whether or not the user has answered whether or not they are a backer.
 
 @returns see description.
 */
+ (BOOL)hasAnsweredBackerQuestion;

/**
 Set whether or not the user has answered the backer question.
 
 @param whether or not the user is a backer (their response).
 */
+ (void)userAnsweredBackerQuestion:(BOOL)response;

/**
 Returns the user's email address as stored from their Lignite account.
 
 @returns see description.
 */
+ (NSString*)getEmail;

/**
 Returns the user's account token as stored from their Lignite account.
 
 @returns see description.
 */
+ (NSString*)getUserToken;

/**
 Sets the user's token provided by the server.
 
 @param the new token to save to storage.
 */
+ (void)setUserToken:(NSString*)newToken;

/**
 Returns the user's username (access code).
 
 @returns see description.
 */
+ (NSString*)getUsername;

/**
 Sets the username (access code) for the user.
 
 @param the new username to write to storage.
 */
+ (void)setUsername:(NSString*)newUsername;

/**
 Gets the user data from storage in the form of an NSDictionary.
 
 @returns see description.
 */
+ (NSDictionary*)getUserData;

/**
 Sets the user data.
 
 @param the dictionary of data to write to storage.
 */
+ (void)setUserData:(NSDictionary*)dict;

/**
 Returns whether or not the user is logged in.
 
 @returns see description.
 */
+ (BOOL)isUserLoggedIn;

/**
 Set whether or not the user is logged in.
 
 @param the access code of the user.
 @param whether or not the user is logged in.
 */
+ (BOOL)setUserLoggedIn:(NSString*)accessCode :(BOOL)loggedIn;

/**
 Whether or not the user is a backer.
 
 @returns see description.
 */
+ (BOOL)isUserBacker;

/**
 Sets whether or not the user is a backer.
 
 @param whether or not the user is a backer.
 */
+ (void)setUserBacker:(BOOL)backer;

/**
 Returns the user's current device model name for feedback purposes.
 
 @returns see description.
 */
+ (NSString*)getCurrentDevice;


@end