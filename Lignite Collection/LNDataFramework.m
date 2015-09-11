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
#import "AudioToolbox/AudioToolbox.h"
#import "LNDataFramework.h"
#import "LNAppInfo.h"
#import "LNSettingsViewController.h"
#import "LNAlertView.h"

@implementation LNDataFramework

+ (NSString*)localizedSendingError:(NSError*)error {
    switch([error code]){
        case 4:
            return NSLocalizedString(@"timed_out", nil);
        case 9:
            return NSLocalizedString(@"rejected_update", nil);
        case 10:
            return NSLocalizedString(@"failed_to_ack", nil);
        default:
            return [NSString stringWithFormat:NSLocalizedString(@"unknown_error", nil), [error localizedDescription]];
    }
}

+ (void)alertOfError:(NSError*)error withDelegate:(UIViewController*)controller withDictionary:(NSDictionary*)dictionary withAppType:(AppTypeCode)app isGuard:(BOOL)isGuard  {
    
    NSString *description = [NSString stringWithFormat:NSLocalizedString(@"error_sending_description", nil), [self localizedSendingError:error], (long)[error code]];
    LNAlertView *alert = [[LNAlertView alloc] initWithTitle:isGuard ? NSLocalizedString(@"error_sending_trial", "error sending trial") : NSLocalizedString(@"error_sending_setting", "error sending a setting")
                                                    message:description
                                                   delegate:controller
                                          cancelButtonTitle:NSLocalizedString(@"ignore", nil)
                                          otherButtonTitles:NSLocalizedString(@"manage_alerts", nil), NSLocalizedString(@"retry", nil), nil];
    alert.error = error;
    alert.isGuard = isGuard;
    alert.dictionary = dictionary;
    alert.app = app;
    NSDictionary *settings = [LNDataFramework getSettingsDictionaryForAppType:APP_TYPE_NOTHING];
    NSLog(@"Settings: %@", settings);
    if([[settings valueForKey:@"alerts-trial"] isEqual:@(1)] && isGuard){
        [alert show];
    }
    
    if([[settings valueForKey:@"alerts-setting"] isEqual:@(1)] && !isGuard){
        [alert show];
    }
    
    if([[settings valueForKey:@"alerts-sound_on_fail"] isEqual:@(1)]){
        AudioServicesPlaySystemSound(1051);
    }
}

+ (void)sendDictionaryToPebble:(NSDictionary*)dictionary forApp:(AppTypeCode)code withSettingsController:(UIViewController*)controller {
    PBWatch *currentWatch = [[PBPebbleCentral defaultCentral] lastConnectedWatch];
    
    uuid_t myAppUUIDbytes;
    NSUUID *myAppUUID = [[NSUUID alloc] initWithUUIDString:[[LNAppInfo uuidArray] objectAtIndex:code]];
    [myAppUUID getUUIDBytes:myAppUUIDbytes];
    
    [[PBPebbleCentral defaultCentral] setAppUUID:[NSData dataWithBytes:myAppUUIDbytes length:16]];
    [currentWatch appMessagesPushUpdate:dictionary onSent:^(PBWatch *watch, NSDictionary *update, NSError *error) {
        if (!error) {
            NSLog(@"Successfully sent.");
        }
        else {
            NSLog(@"Error %ld sending data: %@", (long)[error code], error);
            [self alertOfError:error withDelegate:controller withDictionary:update withAppType:code isGuard:false];
        }
    }];

}

+ (void)sendLigniteGuardUnlockToPebble:(AppTypeCode)code settingsController:(UIViewController*)controller {
    NSString *unlockToken = [[LNAppInfo unlockTokenArray]objectAtIndex: code];
    NSInteger unlockTokenKey = [LNAppInfo unlockTokenKeyForIndex:code];
    NSString *endOfUUID = [[LNAppInfo uuidEndingArray]objectAtIndex: code];
    NSInteger endOfUUIDKey = [LNAppInfo uuidEndingKeyForIndex:code];
    
    PBWatch *currentWatch = [[PBPebbleCentral defaultCentral] lastConnectedWatch];
    uuid_t myAppUUIDbytes;
    NSUUID *myAppUUID = [[NSUUID alloc] initWithUUIDString:[[LNAppInfo uuidArray] objectAtIndex:code]];
    [myAppUUID getUUIDBytes:myAppUUIDbytes];
    
    NSLog(@"sending to %@    %d", [[LNAppInfo uuidArray] objectAtIndex:code], code);
    
    [[PBPebbleCentral defaultCentral] setAppUUID:[NSData dataWithBytes:myAppUUIDbytes length:16]];
    NSDictionary *update = @{ @(unlockTokenKey):unlockToken,
                              @(endOfUUIDKey):endOfUUID      };
    [currentWatch appMessagesPushUpdate:update onSent:^(PBWatch *watch, NSDictionary *update, NSError *error) {
        if (!error) {
            NSLog(@"Successfully sent Lignite Guard unlock data.");
        }
        else {
            NSLog(@"Error %ld sending Lignite Guard unlock data: %@", (long)[error code], error);
            [self alertOfError:error withDelegate:controller withDictionary:update withAppType:code isGuard:true];
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
    NSString *key;
    if(type == APP_TYPE_NOTHING){
        key = @"alert_settings";
    } else {
        key = [NSString stringWithFormat:@"%@", [LNAppInfo getAppNameFromType:type]];
    }
    NSMutableDictionary *dict = [defaults objectForKey:key];
    if(!dict){
        NSLog(@"Dict for %@ is null, creating new...", key);
        return [[NSMutableDictionary alloc]init];
    }
    dict = [dict mutableCopy];
    return dict;
}

+ (void)setSettingsDictionaryForAppType:(AppTypeCode)type dictionary:(NSMutableDictionary*)dict {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *key;
    if(type == APP_TYPE_NOTHING){
        key = @"alert_settings";
    } else {
        key = [NSString stringWithFormat:@"%@", [LNAppInfo getAppNameFromType:type]];
    }
    if(!dict){
        NSLog(@"Error: dict for AppTypeCode %d is null!", type);
        return;
    }
    [defaults setObject:dict forKey:key];
    BOOL result = [defaults synchronize];
    if(result){
        NSLog(@"Success writing to %@. Dict: %@", key, dict);
    }
}

+ (void)updateStringSetting:(AppTypeCode)type string:(NSString*)setting key:(NSString*)key {
    NSMutableDictionary *dict = [self getSettingsDictionaryForAppType:type];
    if(!setting){
        NSLog(@"Error: setting for key %@ is null.", key);
        return;
    }
    [dict setObject:setting forKey:key];
    [self setSettingsDictionaryForAppType:type dictionary:dict];
}

+ (void)updateBooleanSetting:(AppTypeCode)type boolean:(BOOL)setting key:(NSString*)key {
    NSMutableDictionary *dict = [self getSettingsDictionaryForAppType:type];
    [dict setValue:@(setting) forKey:key];
    [self setSettingsDictionaryForAppType:type dictionary:dict];
}

+ (void)updateNumberSetting:(AppTypeCode)type number:(NSNumber*)setting key:(NSString*)key {
    NSMutableDictionary *dict = [self getSettingsDictionaryForAppType:type];
    if(!setting){
        NSLog(@"Error: setting for key %@ is null!!!", key);
        return;
    }
    [dict setValue:setting forKey:key];
    [self setSettingsDictionaryForAppType:type dictionary:dict];
}

+ (void)sendNumberToPebble:(NSNumber*)number pebbleKey:(NSInteger)pebbleKey storageKey:(NSString*)storageKey appUUID:(NSString*)appUUID fromController:(UIViewController*)controller {
    [self updateNumberSetting:[LNAppInfo getAppTypeCode:appUUID] number:number key:storageKey];
    
    PBWatch *currentWatch = [[PBPebbleCentral defaultCentral] lastConnectedWatch];
    uuid_t myAppUUIDbytes;
    NSUUID *myAppUUID = [[NSUUID alloc] initWithUUIDString:appUUID];
    [myAppUUID getUUIDBytes:myAppUUIDbytes];
    
    [[PBPebbleCentral defaultCentral] setAppUUID:[NSData dataWithBytes:myAppUUIDbytes length:16]];
    
    NSDictionary *update = @{ @(pebbleKey):number };
    [currentWatch appMessagesPushUpdate:update onSent:^(PBWatch *watch, NSDictionary *update, NSError *error) {
        if (!error) {
            NSLog(@"Successfully sent number %@", update);
        }
        else {
            NSLog(@"Error sending number: %@", error);
            [self alertOfError:error withDelegate:controller withDictionary:update withAppType:[LNAppInfo getAppTypeCode:appUUID] isGuard:false];
        }
        //[self alertOfError:error];
    }];
}

+ (void)sendBooleanToPebble:(BOOL)boolean pebbleKey:(NSInteger)pebbleKey storageKey:(NSString*)storageKey appUUID:(NSString*)appUUID fromController:(UIViewController*)controller {
    [self updateBooleanSetting:[LNAppInfo getAppTypeCode:appUUID] boolean:boolean key:storageKey];
    
    PBWatch *currentWatch = [[PBPebbleCentral defaultCentral] lastConnectedWatch];
    uuid_t myAppUUIDbytes;
    NSUUID *myAppUUID = [[NSUUID alloc] initWithUUIDString:appUUID];
    [myAppUUID getUUIDBytes:myAppUUIDbytes];
    
    if(!currentWatch){
        NSLog(@"no watch rip");
    }
    
    [[PBPebbleCentral defaultCentral] setAppUUID:[NSData dataWithBytes:myAppUUIDbytes length:16]];
    
    NSDictionary *update = @{ @(pebbleKey):[NSNumber numberWithBool:boolean] };
    [currentWatch appMessagesPushUpdate:update onSent:^(PBWatch *watch, NSDictionary *update, NSError *error) {
        if (!error) {
            NSLog(@"Successfully sent boolean.");
        }
        else {
            NSLog(@"Error sending boolean: %@", error);
            [self alertOfError:error withDelegate:controller withDictionary:update withAppType:[LNAppInfo getAppTypeCode:appUUID] isGuard:false];
        }
        //[self alertOfError:error];
    }];
}

+ (void)sendStringToPebble:(NSString*)string pebbleKey:(NSInteger)pebbleKey storageKey:(NSString*)storageKey appUUID:(NSString*)appUUID fromController:(UIViewController*)controller {
    [self updateStringSetting:[LNAppInfo getAppTypeCode:appUUID] string:string key:storageKey];
    
    PBWatch *currentWatch = [[PBPebbleCentral defaultCentral] lastConnectedWatch];
    uuid_t myAppUUIDbytes;
    NSUUID *myAppUUID = [[NSUUID alloc] initWithUUIDString:appUUID];
    [myAppUUID getUUIDBytes:myAppUUIDbytes];
    
    [[PBPebbleCentral defaultCentral] setAppUUID:[NSData dataWithBytes:myAppUUIDbytes length:16]];
    
    NSDictionary *update = @{ @(pebbleKey):string };
    [currentWatch appMessagesPushUpdate:update onSent:^(PBWatch *watch, NSDictionary *update, NSError *error) {
        if (!error) {
            NSLog(@"Successfully sent string (%@).", update);
        }
        else {
            NSLog(@"Error sending string: %@", error);
            [self alertOfError:error withDelegate:controller withDictionary:update withAppType:[LNAppInfo getAppTypeCode:appUUID] isGuard:false];
        }
        //[self alertOfError:error];
    }];
}

+ (AppTypeCode)getPreviousAppType{
    return (AppTypeCode)[[NSUserDefaults standardUserDefaults] integerForKey:@"previous_app_type"];
}

+ (void)setupDefaults {
    //NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    for(int i = -1; i < APP_COUNT; i++){
        // NSString *key = [[LNAppInfo nameArray] objectAtIndex:i];
        NSMutableDictionary *new_settings_dict = [[NSMutableDictionary alloc]init];
        
        NSData *data = [[NSData alloc]initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:i == -1 ? @"lignite_settings" : [LNAppInfo getAppNameFromType:i] ofType:@"json"]];
        NSError *error;
        NSDictionary *settings_dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
        
        NSArray *items = [settings_dict objectForKey:@"items"];
        for(int itemsIndex = 0; itemsIndex < [items count]; itemsIndex++){
            NSDictionary *item = [items objectAtIndex:itemsIndex];
            NSArray *itemItems = [item objectForKey:@"items"];
            for(int itemItemsIndex = 0; itemItemsIndex < [itemItems count]; itemItemsIndex++){
                NSDictionary *finalItem = [itemItems objectAtIndex:itemItemsIndex];
                [new_settings_dict setObject:[finalItem objectForKey:@"default"] forKey:[finalItem objectForKey:@"storage_key"]];
            }
        }
        [LNDataFramework setSettingsDictionaryForAppType:i dictionary:new_settings_dict];
    }
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
