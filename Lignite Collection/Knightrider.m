//
//  Knightrider.m
//  Lignite
//
//  Created by Edwin Finch on 2015-05-19.
//  Copyright (c) 2015 Edwin Finch. All rights reserved.
//

#import <DRColorPicker/DRColorPicker.h>
#import <PebbleKit/PebbleKit.h>
#import "Knightrider.h"
#import "DataFramework.h"

@interface KnightriderTableViewController ()

@end

@implementation KnightriderTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSMutableDictionary *knightriderSettings = [DataFramework getSettingsDictionaryForAppType:APP_TYPE_KNIGHTRIDER];
    
    NSObject* btdisalert = [knightriderSettings objectForKey:@"kni-btdisalert"];
    if([btdisalert isEqual: @(0)]){
        self.btDisAlertSwitch.on = NO;
    }
    else{
        self.btDisAlertSwitch.on = YES;
    }
    
    NSObject* btrealert = [knightriderSettings objectForKey:@"kni-btrealert"];
    if([btrealert isEqual: @(0)]){
        self.btReAlertSwitch.on = NO;
    }
    else{
        self.btReAlertSwitch.on = YES;
    }
    
    
    NSObject* bootanim = [knightriderSettings objectForKey:@"kni-bootanim"];
    if([bootanim isEqual: @(0)]){
        self.bootAnimationSwitch.on = NO;
    }
    else{
        self.bootAnimationSwitch.on = YES;
    }
    
    NSObject* constant = [knightriderSettings objectForKey:@"kni-constant"];
    if([constant isEqual: @(0)]){
        self.constantAnimSwitch.on = NO;
    }
    else{
        self.constantAnimSwitch.on = YES;
    }
    
    NSObject* dithering = [knightriderSettings objectForKey:@"kni-dithering"];
    if([dithering isEqual: @(0)]){
        self.ditheringSwitch.on = NO;
    }
    else{
        self.ditheringSwitch.on = YES;
    }
    
    NSObject* invert = [knightriderSettings objectForKey:@"kni-invert"];
    if([invert isEqual: @(0)]){
        self.invertSwitch.on = NO;
    }
    else{
        self.invertSwitch.on = YES;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)invertSwitchChanged:(id)sender {
    UISwitch *currentSwitch = sender;
    [DataFramework sendBooleanToPebble:currentSwitch.on :6 :@"kni-invert" :[PebbleInfo getAppUUID:APP_TYPE_KNIGHTRIDER]];
}

- (IBAction)btDisAlertChanged:(id)sender {
    UISwitch *currentSwitch = sender;
    [DataFramework sendBooleanToPebble:currentSwitch.on :0 :@"kni-btdisalert" :[PebbleInfo getAppUUID:APP_TYPE_KNIGHTRIDER]];
}

- (IBAction)btReAlertChanged:(id)sender {
    UISwitch *currentSwitch = sender;
    [DataFramework sendBooleanToPebble:currentSwitch.on :1 :@"kni-btrealert" :[PebbleInfo getAppUUID:APP_TYPE_KNIGHTRIDER]];
}

- (IBAction)bootAnimationChanged:(id)sender {
    UISwitch *currentSwitch = sender;
    [DataFramework sendBooleanToPebble:currentSwitch.on :3 :@"kni-bootanim" :[PebbleInfo getAppUUID:APP_TYPE_KNIGHTRIDER]];
}

- (IBAction)constantChanged:(id)sender {
    UISwitch *currentSwitch = sender;
    [DataFramework sendBooleanToPebble:currentSwitch.on :5 :@"kni-constant" :[PebbleInfo getAppUUID:APP_TYPE_KNIGHTRIDER]];
}

- (IBAction)ditheringChanged:(id)sender {
    UISwitch *currentSwitch = sender;
    [DataFramework sendBooleanToPebble:currentSwitch.on :4 :@"kni-dithering" :[PebbleInfo getAppUUID:APP_TYPE_KNIGHTRIDER]];
}

@end
