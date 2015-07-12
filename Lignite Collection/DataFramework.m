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
#import "DataFramework.h"
#import "PebbleInfo.h"

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
        NSLog(@"dict for %@ is null, creating new dict...", [NSString stringWithFormat:@"%@", [PebbleInfo getAppNameFromType:type]]);
        switch(type){
            case APP_TYPE_SPEEDOMETER:
                dict = [[NSMutableDictionary alloc]initWithObjects:@[@0, @0, @0, @0, @0, @0, @"ffffff", @"ffffff", @"ffffff"] forKeys:@[@"spe-invert", @"spe-btdisalert", @"spe-btrealert", @"spe-bootanim", @"spe-bticon", @"spe-dithering", @"spe-outer-colour", @"spe-middle-colour", @"spe-inner-colour"]];
                break;
            case APP_TYPE_KNIGHTRIDER:
                dict = [[NSMutableDictionary alloc]initWithObjects:@[@0, @0, @0, @0, @0, @0] forKeys:@[@"kni-btdisalert", @"kni-btrealert", @"kni-bootanim", @"kni-constant", @"kni-dithering", @"kni-invert"]];
                break;
            case APP_TYPE_CHUNKY:
                dict = [[NSMutableDictionary alloc]initWithObjects:@[@1, @0, @0, @1, @"ff0000", @"ff0000", @"000000"] forKeys:@[@"chu-btdisalert", @"chu-btrealert", @"chu-invert", @"chu-batterybar", @"chu-minute-colour", @"chu-hour-colour", @"chu-background-colour"]];
                break;
            case APP_TYPE_COLOURS:
                dict = [[NSMutableDictionary alloc]initWithObjects:@[@1, @0, @1, @0, @6, @"ffffff", @"ffffff"] forKeys:@[@"col-btdisalert", @"col-btrealert", @"col-organize", @"col-randomize", @"col-bar-width", @"col-minute-colour", @"col-hour-colour"]];
                break;
            case APP_TYPE_LINES:
                dict = [[NSMutableDictionary alloc]initWithObjects:@[@1, @0, @1, @0, @"ffffff", @"ffffff", @"00ffff"] forKeys:@[@"lin-btdisalert", @"lin-btrealert", @"lin-showdate", @"lin-altdate", @"lin-time-colour", @"lin-date-colour", @"lin-background-colour"]];
                break;
            case APP_TYPE_TREE_OF_COLOURS:
                dict = [[NSMutableDictionary alloc]initWithObjects:@[@1, @0, @1, @2, @"000000", @"000000", @"000000", @"000000", @"000000"] forKeys:@[@"tre-btdisalert", @"tre-btrealert", @"tre-randomize", @"tre-default-width", @"tre-custom-colour-1", @"tre-custom-colour-2", @"tre-custom-colour-3", @"tre-circle-colour", @"tre-time-colour"]];
                break;
            case APP_TYPE_TIMEZONES:
                dict = [[NSMutableDictionary alloc]initWithObjects:@[@1, @0, @"You", @"000000", @1, @"Not set", @0, @"Other", @"000000", @1] forKeys:@[@"tim-btdisalert", @"tim-btrealert", @"tim-name-1", @"tim-colour-1", @"tim-analogue_1", @"tim-timezone", @"tim-subtract-hour", @"tim-name-2", @"tim-colour-2", @"tim-analogue_2"]];
                break;
            case APP_TYPE_SLOT_MACHINE:
                dict = [[NSMutableDictionary alloc]initWithObjects:@[@1, @0, @0, @0, @0] forKeys:@[@"pul-btdisalert", @"pul-btrealert", @"pul-invert", @"pul-shake", @"pul-seconds"]];
                break;
            case APP_TYPE_PULSE:
                dict = [[NSMutableDictionary alloc]initWithObjects:@[@1, @0, @0, @0, @0, @"000000", @"000000"] forKeys:@[@"pul-btdisalert", @"pul-btrealert", @"pul-invert", @"pul-shake", @"pul-constant", @"pul-circle-colour", @"pul-background-colour"]];
                break;
            default:
                break;
        }
    }
    NSLog(@"dict is %@", dict);
    dict = [dict mutableCopy];
    return dict;
}

+ (void)setSettingsDictionaryForAppType:(AppTypeCode)type :(NSMutableDictionary*)dict {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *key = [NSString stringWithFormat:@"%@", [PebbleInfo getAppNameFromType:type]];
    [defaults setObject:dict forKey:key];
    BOOL result = [defaults synchronize];
    if(result){
        NSLog(@"Success writing to %@. Dict: %@", [PebbleInfo getAppNameFromType:type], dict);
    }
}

+ (void)updateStringSetting:(AppTypeCode)type :(NSString*)setting :(NSString*)key {
    NSMutableDictionary *dict = [self getSettingsDictionaryForAppType:type];
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
            NSLog(@"Successfully sent boolean.");
        }
        else {
            NSLog(@"Error sending boolean: %@", error);
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
            NSLog(@"Successfully sent colour.");
        }
        else {
            NSLog(@"Error sending colour: %@", error);
        }
    }];
}

NSString* deviceName(){
    struct utsname systemInfo;
    uname(&systemInfo);
    
    return [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
}

+ (NSString*)getUsername {
    NSString *username = @"NOBODY";
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    username = [defaults objectForKey:@"key-ACCESS_CODE"];
    NSLog(@"Found username of %@", username);
    return username;
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
