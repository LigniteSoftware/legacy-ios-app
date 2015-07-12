//
//  SlotMachineTableViewController.m
//  
//
//  Created by Edwin Finch on 2015-07-09.
//
//

#import "SlotMachine.h"
#import "PebbleInfo.h"
#import "DataFramework.h"

@interface SlotMachineTableViewController ()

@end

@implementation SlotMachineTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    NSMutableDictionary *slotMachineSettings = [DataFramework getSettingsDictionaryForAppType:APP_TYPE_SLOT_MACHINE];
    self.btdisalertSwitch.on = ![[slotMachineSettings objectForKey:@"slo-btdisalert"] isEqual:@0];
    self.btrealertSwitch.on = ![[slotMachineSettings objectForKey:@"slo-btrealert"] isEqual:@0];
    self.invertSwitch.on = ![[slotMachineSettings objectForKey:@"slo-invert"] isEqual:@0];
    self.shakeToAnimateSwitch.on = ![[slotMachineSettings objectForKey:@"slo-shake"] isEqual:@0];
    self.secondSwitch.on = ![[slotMachineSettings objectForKey:@"slo-seconds"] isEqual:@0];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)valueSwitchChanged:(id)sender {
    UISwitch *changedSwitch = sender;
    if(changedSwitch == self.btdisalertSwitch){
        [DataFramework sendBooleanToPebble:changedSwitch.on :0 :@"slo-btdisalert" :[PebbleInfo getAppUUID:APP_TYPE_SLOT_MACHINE]];
    }
    else if(changedSwitch == self.btrealertSwitch){
        [DataFramework sendBooleanToPebble:changedSwitch.on :1 :@"slo-btrealert" :[PebbleInfo getAppUUID:APP_TYPE_SLOT_MACHINE]];
    }
    else if(changedSwitch == self.invertSwitch){
        [DataFramework sendBooleanToPebble:changedSwitch.on :3 :@"slo-invert" :[PebbleInfo getAppUUID:APP_TYPE_SLOT_MACHINE]];
    }
    else if(changedSwitch == self.shakeToAnimateSwitch){
        [DataFramework sendBooleanToPebble:changedSwitch.on :4 :@"slo-shake" :[PebbleInfo getAppUUID:APP_TYPE_SLOT_MACHINE]];
    }
    else if(changedSwitch == self.secondSwitch){
        [DataFramework sendBooleanToPebble:changedSwitch.on :5 :@"slo-seconds" :[PebbleInfo getAppUUID:APP_TYPE_SLOT_MACHINE]];
    }
    else{
        NSLog(@"Unrecognized switch %@", changedSwitch);
    }
}

@end
