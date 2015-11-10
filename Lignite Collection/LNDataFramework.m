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
#import "LNPebbleApp.h"
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

+ (void)alertOfError:(NSError*)error withDelegate:(UIViewController*)controller withDictionary:(NSDictionary*)dictionary withWatchApp:(LNPebbleApp*)watchApp isGuard:(BOOL)isGuard  {
    
    NSString *description = [NSString stringWithFormat:NSLocalizedString(@"error_sending_description", nil), [self localizedSendingError:error], (long)[error code]];
    LNAlertView *alert = [[LNAlertView alloc] initWithTitle:isGuard ? NSLocalizedString(@"error_sending_trial", "error sending trial") : NSLocalizedString(@"error_sending_setting", "error sending a setting")
                                                    message:description
                                                   delegate:controller
                                          cancelButtonTitle:NSLocalizedString(@"ignore", nil)
                                          otherButtonTitles:NSLocalizedString(@"manage_alerts", nil), NSLocalizedString(@"retry", nil), nil];
    alert.error = error;
    alert.isGuard = isGuard;
    alert.dictionary = dictionary;
    alert.watchApp = watchApp;

    NSDictionary *settings = [LNDataFramework getSettingsDictionaryForWatchApp:LIGNITE_SETTINGS];
    NSLog(@"Settings: %@", settings);
    
    if([[settings valueForKey:@"alerts-setting"] isEqual:@(1)] && !isGuard && alert.error.code != 10){
        [alert show];
    }
	else{
		NSLog(@"Ignoring, code is %ld", (long)alert.error.code);
	}
    
    if([[settings valueForKey:@"alerts-sound_on_fail"] isEqual:@(1)]){
        AudioServicesPlaySystemSound(1051);
    }
}

+ (void)sendDictionaryToPebble:(NSDictionary*)dictionary forWatchApp:(LNPebbleApp*)watchApp withSettingsController:(UIViewController*)controller {
    PBWatch *currentWatch = [[PBPebbleCentral defaultCentral] lastConnectedWatch];
	
    [currentWatch appMessagesPushUpdate:dictionary onSent:^(PBWatch *watch, NSDictionary *update, NSError *error) {
        if (!error) {
            NSLog(@"Successfully sent.");
        }
        else {
            NSLog(@"Error %ld sending data: %@", (long)[error code], error);
            [self alertOfError:error withDelegate:controller withDictionary:update withWatchApp:watchApp isGuard:false];
        }
    }];

}

+ (UIColor *)colorFromHexString:(NSString *)hexString {
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
}

+ (NSMutableDictionary*)getSettingsDictionaryForWatchApp:(LNPebbleApp*)watchApp {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *key;
	
    if(watchApp == LIGNITE_SETTINGS){
        key = @"alert_settings";
    }
	else {
        key = [NSString stringWithFormat:@"%@", watchApp.appName];
    }
	
    NSMutableDictionary *dict = [defaults objectForKey:key];
    if(!dict){
        return [[NSMutableDictionary alloc]init];
    }
    dict = [dict mutableCopy];
    return dict;
}

+ (void)setSettingsDictionaryForWatchApp:(LNPebbleApp*)watchApp dictionary:(NSMutableDictionary*)dict {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *key;
    if(watchApp == LIGNITE_SETTINGS){
        key = @"alert_settings";
    } else {
        key = [NSString stringWithFormat:@"%@", watchApp.appName];
    }
	 
    if(!dict){
        NSLog(@"Error: dict for LNPebbleApp* %@ is null!", watchApp.appName);
        return;
    }
    [defaults setObject:dict forKey:key];
    BOOL result = [defaults synchronize];
    if(result){
        NSLog(@"Success writing to %@. Dict: %@", key, dict);
    }
}

+ (void)updateStringSetting:(LNPebbleApp*)watchApp string:(NSString*)setting key:(NSString*)key {
    NSMutableDictionary *dict = [self getSettingsDictionaryForWatchApp:watchApp];
    if(!setting){
        NSLog(@"Error: setting for key %@ is null.", key);
        return;
    }
    [dict setObject:setting forKey:key];
    [self setSettingsDictionaryForWatchApp:watchApp dictionary:dict];
}

+ (void)updateBooleanSetting:(LNPebbleApp*)watchApp boolean:(BOOL)setting key:(NSString*)key {
    NSMutableDictionary *dict = [self getSettingsDictionaryForWatchApp:watchApp];
    [dict setValue:@(setting) forKey:key];
    [self setSettingsDictionaryForWatchApp:watchApp dictionary:dict];
}

+ (void)updateNumberSetting:(LNPebbleApp*)watchApp number:(NSNumber*)setting key:(NSString*)key {
    NSMutableDictionary *dict = [self getSettingsDictionaryForWatchApp:watchApp];
    if(!setting){
        NSLog(@"Error: setting for key %@ is null!!!", key);
        return;
    }
    [dict setValue:setting forKey:key];
    [self setSettingsDictionaryForWatchApp:watchApp dictionary:dict];
}

+ (void)sendNumberToPebble:(NSNumber*)number pebbleKey:(NSInteger)pebbleKey storageKey:(NSString*)storageKey forWatchApp:(LNPebbleApp*)watchApp fromController:(UIViewController*)controller {
    [self updateNumberSetting:watchApp number:number key:storageKey];
    
    PBWatch *currentWatch = [[PBPebbleCentral defaultCentral] lastConnectedWatch];
	
	NSLog(@"Current watch %@", currentWatch);
	
	NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:watchApp.uuidString];
	
    
    NSDictionary *update = @{ @(pebbleKey):number };
    [currentWatch appMessagesPushUpdate:update withUUID:uuid onSent:^(PBWatch *watch, NSDictionary *update, NSError *error) {
        if (!error) {
            NSLog(@"Successfully sent number %@", update);
        }
        else {
            NSLog(@"Error sending number: %@", error);
			[self alertOfError:error withDelegate:controller withDictionary:update withWatchApp:watchApp isGuard:false];
        }
        //[self alertOfError:error];
    }];
}

+ (void)sendBooleanToPebble:(BOOL)boolean pebbleKey:(NSInteger)pebbleKey storageKey:(NSString*)storageKey forWatchApp:(LNPebbleApp*)watchApp fromController:(UIViewController*)controller {
    [self updateBooleanSetting:watchApp boolean:boolean key:storageKey];
    
	PBWatch *currentWatch = [[PBPebbleCentral defaultCentral] lastConnectedWatch];
	
	NSLog(@"Current watch %@", currentWatch);
	
	NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:watchApp.uuidString];
	
    if(!currentWatch){
        NSLog(@"no watch rip");
    }
    
    NSDictionary *update = @{ @(pebbleKey):[NSNumber numberWithBool:boolean] };
	[currentWatch appMessagesPushUpdate:update withUUID:uuid onSent:^(PBWatch *watch, NSDictionary *update, NSError *error) {
        if (!error) {
            NSLog(@"Successfully sent boolean.");
        }
        else {
            NSLog(@"Error sending boolean: %@", error);
            [self alertOfError:error withDelegate:controller withDictionary:update withWatchApp:watchApp isGuard:false];
        }
        //[self alertOfError:error];
    }];
}

+ (void)sendStringToPebble:(NSString*)string pebbleKey:(NSInteger)pebbleKey storageKey:(NSString*)storageKey forWatchApp:(LNPebbleApp*)watchApp fromController:(UIViewController*)controller {
    [self updateStringSetting:watchApp string:string key:storageKey];
    
    PBWatch *currentWatch = [[PBPebbleCentral defaultCentral] lastConnectedWatch];
    
    NSDictionary *update = @{ @(pebbleKey):string };
    [currentWatch appMessagesPushUpdate:update withUUID:[[NSUUID alloc] initWithUUIDString:watchApp.uuidString] onSent:^(PBWatch *watch, NSDictionary *update, NSError *error) {
        if (!error) {
            NSLog(@"Successfully sent string (%@).", update);
        }
        else {
            NSLog(@"Error sending string: %@", error);
            [self alertOfError:error withDelegate:controller withDictionary:update withWatchApp:watchApp isGuard:false];
        }
    }];
}

+ (void)setupDefaults {
    for(int i = -1; i < APP_COUNT; i++){
		LNPebbleApp *currentWatchApp = [[LNPebbleApp alloc]initWithAppIndex:i];
        // NSString *key = [[LNAppInfo nameArray] objectAtIndex:i];
        NSMutableDictionary *new_settings_dict = [[NSMutableDictionary alloc]init];
		
		NSString *settingsString = [NSString stringWithFormat:@"%@_settings", (currentWatchApp == nil) ? @"lignite" : currentWatchApp.appName];
		NSLog(@"Loading for %@", settingsString);
        NSData *data = [[NSData alloc]initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:settingsString ofType:@"json"]];
        NSError *error;
        NSDictionary *settings_dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
		
		NSMutableDictionary *dict = [LNDataFramework getSettingsDictionaryForWatchApp:currentWatchApp];
		
		BOOL settingsAreEmpty = ([[dict allKeys] count] == 0);
		//NSLog(@"Got settings dict %d for app %d which already had %@ is empty %@", (int)[settings_dict count], i, dict, settingsAreEmpty ? @"YES" : @"NO");
		
		if(settingsAreEmpty){
			NSArray *items = [settings_dict objectForKey:@"items"];
			for(int itemsIndex = 0; itemsIndex < [items count]; itemsIndex++){
				NSDictionary *item = [items objectAtIndex:itemsIndex];
				NSArray *itemItems = [item objectForKey:@"items"];
				for(int itemItemsIndex = 0; itemItemsIndex < [itemItems count]; itemItemsIndex++){
					NSDictionary *finalItem = [itemItems objectAtIndex:itemItemsIndex];
					[new_settings_dict setObject:[finalItem objectForKey:@"default"] forKey:[finalItem objectForKey:@"storage_key"]];
				}
			}
			[LNDataFramework setSettingsDictionaryForWatchApp:currentWatchApp dictionary:new_settings_dict];
			NSLog(@"Settings WERE empty, loading defaults for %@.", currentWatchApp.appName);
		}
		else{
			NSLog(@"Settings are not empty, not loading defaults for %@.", currentWatchApp.appName);
		}
    }
}

+ (BOOL)pebbleImageIsTime:(NSString *)pebble {
    if([pebble containsString:@"bobby"] || [pebble containsString:@"snowy"]){
        return YES;
    }
    return NO;
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
	NSLog(@"Storing token %@", keychain[@"token"]);
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
    if([accessCode isEqualToString:currentlySetAccessCode] || accessCode == nil){
        [defaults setBool:loggedIn forKey:@"key-LOGGED_IN"];
        //Clear user data
        if(!loggedIn){
			NSLog(@"Wiping user data");
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
	NSLog(@"Setting user as a backer: %d", backer);
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:backer forKey:@"is_backer"];
	[defaults synchronize];
}

+ (NSString*)getCurrentDevice {
    return deviceName();
}

@end
