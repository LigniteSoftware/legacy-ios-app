//
//  DataFramework.m
//  Lignite
//
//  Created by Edwin Finch on 2015-05-18.
//  Copyright (c) 2015 Edwin Finch. All rights reserved.
//

#import <sys/utsname.h>
#import <PebbleKit/PebbleKit.h>
#import <UICKeyChainStore/UICKeyChainStore.h>
#import "LNCommunicationLayer.h"
#import "LNAppInfo.h"

@implementation DataFramework

+ (void)sendLigniteGuardUnlockToPebble:(AppTypeCode)code {
    NSString *unlockToken = [[PebbleInfo unlockTokenArray]objectAtIndex: code];
    NSInteger unlockTokenKey = [PebbleInfo unlockTokenKeyForIndex:code];
    NSString *endOfUUID = [[PebbleInfo uuidEndingArray]objectAtIndex: code];
    NSInteger endOfUUIDKey = [PebbleInfo uuidEndingKeyForIndex:code];
    
    PBWatch *currentWatch = [[PBPebbleCentral defaultCentral] lastConnectedWatch];
    uuid_t myAppUUIDbytes;
    NSUUID *myAppUUID = [[NSUUID alloc] initWithUUIDString:[[PebbleInfo uuidArray] objectAtIndex:code]];
    [myAppUUID getUUIDBytes:myAppUUIDbytes];
    
    [[PBPebbleCentral defaultCentral] setAppUUID:[NSData dataWithBytes:myAppUUIDbytes length:16]];
    NSDictionary *update = @{ @(unlockTokenKey):unlockToken,
                              @(endOfUUIDKey):endOfUUID      };
    [currentWatch appMessagesPushUpdate:update onSent:^(PBWatch *watch, NSDictionary *update, NSError *error) {
        if (!error) {
            NSLog(@"Successfully sent Lignite Guard unlock data.");
        }
        else {
            NSLog(@"Error sending Lignite Guard unlock data: %@", error);
        }
    }];
}

+ (UIColor *)colorFromHexString:(NSString *)hexString {
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
}

+ (NSMutableDictionary*)getSettingsDictionaryForAppType:(AppTypeCode)type {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *key = [NSString stringWithFormat:@"%@", [PebbleInfo getAppNameFromType:type]];
    NSMutableDictionary *dict = [defaults objectForKey:key];
    if(!dict){
        NSLog(@"Dict for %@ is null, creating new...", [NSString stringWithFormat:@"%@", [PebbleInfo getAppNameFromType:type]]);
        return [[NSMutableDictionary alloc]init];
    }
    dict = [dict mutableCopy];
    return dict;
}

+ (void)setSettingsDictionaryForAppType:(AppTypeCode)type :(NSMutableDictionary*)dict {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *key = [NSString stringWithFormat:@"%@", [PebbleInfo getAppNameFromType:type]];
    if(!dict){
        NSLog(@"Error: dict for AppTypeCode %d is null!!!", type);
        return;
    }
    [defaults setObject:dict forKey:key];
    BOOL result = [defaults synchronize];
    if(result){
        NSLog(@"Success writing to %@. Dict: %@", [PebbleInfo getAppNameFromType:type], dict);
    }
}

+ (void)updateStringSetting:(AppTypeCode)type :(NSString*)setting :(NSString*)key {
    NSMutableDictionary *dict = [self getSettingsDictionaryForAppType:type];
    if(!setting){
        NSLog(@"Error: setting for key %@ is null!!!", key);
        return;
    }
    [dict setObject:setting forKey:key];
    [self setSettingsDictionaryForAppType:type :dict];
}

+ (void)updateBooleanSetting:(AppTypeCode)type :(BOOL)setting :(NSString*)key {
    NSMutableDictionary *dict = [self getSettingsDictionaryForAppType:type];
    [dict setValue:@(setting) forKey:key];
    [self setSettingsDictionaryForAppType:type :dict];
}

+ (void)updateNumberSetting:(AppTypeCode)type :(NSNumber*)setting :(NSString*)key {
    NSMutableDictionary *dict = [self getSettingsDictionaryForAppType:type];
    if(!setting){
        NSLog(@"Error: setting for key %@ is null!!!", key);
        return;
    }
    [dict setValue:setting forKey:key];
    [self setSettingsDictionaryForAppType:type :dict];
}

+ (void)sendNumberToPebble:(NSNumber*)number :(NSInteger)pebbleKey :(NSString*)storageKey :(NSString*)appUUID {
    [self updateNumberSetting:[PebbleInfo getAppTypeCode:appUUID] :number :storageKey];
    
    PBWatch *currentWatch = [[PBPebbleCentral defaultCentral] lastConnectedWatch];
    if(!currentWatch){
        NSLog(@"No watch connected, however, the number was saved to storage.");
        return;
    }
    uuid_t myAppUUIDbytes;
    NSUUID *myAppUUID = [[NSUUID alloc] initWithUUIDString:appUUID];
    [myAppUUID getUUIDBytes:myAppUUIDbytes];
    
    [[PBPebbleCentral defaultCentral] setAppUUID:[NSData dataWithBytes:myAppUUIDbytes length:16]];
    
    NSDictionary *update = @{ @(pebbleKey):number };
    [currentWatch appMessagesPushUpdate:update onSent:^(PBWatch *watch, NSDictionary *update, NSError *error) {
        if (!error) {
            NSLog(@"Successfully sent number.");
        }
        else {
            NSLog(@"Error sending number: %@", error);
        }
    }];
}

+ (void)sendBooleanToPebble:(BOOL)boolean :(NSInteger)pebbleKey :(NSString*)storageKey :(NSString*)appUUID {
    [self updateBooleanSetting:[PebbleInfo getAppTypeCode:appUUID] :boolean :storageKey];
    
    PBWatch *currentWatch = [[PBPebbleCentral defaultCentral] lastConnectedWatch];
    if(!currentWatch){
        NSLog(@"No watch connected, however, the boolean was saved to storage.");
        return;
    }
    uuid_t myAppUUIDbytes;
    NSUUID *myAppUUID = [[NSUUID alloc] initWithUUIDString:appUUID];
    [myAppUUID getUUIDBytes:myAppUUIDbytes];
    
    [[PBPebbleCentral defaultCentral] setAppUUID:[NSData dataWithBytes:myAppUUIDbytes length:16]];
    
    NSDictionary *update = @{ @(pebbleKey):[NSNumber numberWithBool:boolean] };
    [currentWatch appMessagesPushUpdate:update onSent:^(PBWatch *watch, NSDictionary *update, NSError *error) {
        if (!error) {
            NSLog(@"Successfully sent boolean.");
        }
        else {
            NSLog(@"Error sending boolean: %@", error);
        }
    }];
}

+ (void)sendColourToPebble:(NSString*)colour :(NSInteger)pebbleKey :(NSString*)storageKey :(NSString*)appUUID {
    [self updateStringSetting:[PebbleInfo getAppTypeCode:appUUID] :colour :storageKey];
    
    NSLog(@"got colour %@", colour);
    
    PBWatch *currentWatch = [[PBPebbleCentral defaultCentral] lastConnectedWatch];
    if(!currentWatch){
        NSLog(@"No watch connected, however, the colour was saved to storage.");
        return;
    }
    uuid_t myAppUUIDbytes;
    NSUUID *myAppUUID = [[NSUUID alloc] initWithUUIDString:appUUID];
    [myAppUUID getUUIDBytes:myAppUUIDbytes];
    
    [[PBPebbleCentral defaultCentral] setAppUUID:[NSData dataWithBytes:myAppUUIDbytes length:16]];
    
    NSDictionary *update = @{ @(pebbleKey):colour };
    [currentWatch appMessagesPushUpdate:update onSent:^(PBWatch *watch, NSDictionary *update, NSError *error) {
        if (!error) {
            NSLog(@"Successfully sent colour (%@).", update);
        }
        else {
            NSLog(@"Error sending colour: %@", error);
        }
    }];
}

+ (AppTypeCode)getPreviousAppType{
    return [[NSUserDefaults standardUserDefaults] integerForKey:@"previous_app_type"];
}

+ (void)setPreviousAppType:(AppTypeCode)type{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setInteger:type forKey:@"previous_app_type"];
    [defaults synchronize];
}

+ (BOOL)pebbleImageIsTime:(NSString *)pebble {
    if([pebble containsString:@"bobby"] || [pebble containsString:@"snowy"]){
        return YES;
    }
    return NO;
}

+ (NSString*)defaultPebbleImage {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults objectForKey:@"pebbleImage"];
}

+ (void)setDefaultPebbleImage:(NSString*)pebbleImage {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:pebbleImage forKey:@"pebbleImage"];
    [defaults synchronize];
}

NSString* deviceName(){
    struct utsname systemInfo;
    uname(&systemInfo);
    
    return [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
}

+ (BOOL)hasAnsweredBackerQuestion{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSLog(@"returning %d", [defaults boolForKey:@"key-ANSWERED"]);
    return [defaults boolForKey:@"key-ANSWERED"];
}

+ (void)userAnsweredBackerQuestion:(BOOL)response{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:response forKey:@"key-ANSWERED"];
    BOOL success = [defaults synchronize];
    NSLog(@"%d for %d", success, response);
}

+ (NSString*)getUsername {
    NSString *username = @"NOBODY";
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    username = [defaults objectForKey:@"key-ACCESS_CODE"];
    return username;
}

+ (NSString*)getEmail {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults objectForKey:@"key-EMAIL"];
}

+ (void)setEmail:(NSString *)email {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:email forKey:@"key-EMAIL"];
    [defaults synchronize];
}

+ (void)setUsername:(NSString*)newUsername {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:newUsername forKey:@"key-ACCESS_CODE"];
    [defaults synchronize];
}

+ (NSString*)getUserToken {
    UICKeyChainStore *keychain = [UICKeyChainStore keyChainStoreWithService:@"me.lignite.access-token"];
    return keychain[@"token"];
}

+ (void)setUserToken:(NSString*)newToken {
    UICKeyChainStore *keychain = [UICKeyChainStore keyChainStoreWithService:@"me.lignite.access-token"];
    keychain[@"token"] = newToken;
}

+ (NSDictionary*)getUserData {
    NSDictionary *dictionary = nil;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    dictionary = [defaults objectForKey:@"key-USER_DATA"];
    return dictionary;
}

+ (void)setUserData:(NSDictionary*)newDict {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:newDict forKey:@"key-USER_DATA"];
    [defaults synchronize];
}

+ (BOOL)isUserLoggedIn {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return[defaults boolForKey:@"key-LOGGED_IN"];
}

+ (BOOL)setUserLoggedIn:(NSString*)accessCode :(BOOL)loggedIn {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *currentlySetAccessCode = [defaults objectForKey:@"key-ACCESS_CODE"];
    if([accessCode isEqualToString:currentlySetAccessCode]){
        [defaults setBool:loggedIn forKey:@"key-LOGGED_IN"];
        //Clear user data
        if(!loggedIn){
            [defaults removeObjectForKey:@"key-USER_DATA"];
            [defaults removeObjectForKey:@"key-ACCESS_CODE"];
            UICKeyChainStore *keychain = [UICKeyChainStore keyChainStoreWithService:@"me.lignite.access-token"];
            keychain[@"token"] = nil;
        }
        [defaults synchronize];
        return true;
    }
    return false;
}

+ (BOOL)isUserBacker {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults boolForKey:@"is_backer"];
}

+ (void)setUserBacker:(BOOL)backer {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:backer forKey:@"is_backer"];
}

+ (BOOL)hasUserTakenBackerQuestion {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults boolForKey:@"checked_backer"];
}

+ (void)setUserTakenBackerQuestion:(BOOL)taken {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:taken forKey:@"checked_backer"];
}

+ (NSString*)getCurrentDevice {
    return deviceName();
}

@end
