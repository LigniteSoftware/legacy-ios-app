//
//  TimezonesTableTableViewController.m
//  
//
//  Created by Edwin Finch on 2015-07-08.
//
//

#import <DRColorPicker/DRColorPicker.h>
#import "Timezones.h"
#import "DataFramework.h"
#import "PebbleInfo.h"
#import "SimpleTableViewController.h"

@interface TimezonesTableTableViewController () <SimpleTableViewControllerDelegate>

@property (nonatomic, strong) DRColorPickerColor* color;

@end

@implementation TimezonesTableTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(timezonesButtonPushed)];
    [self.timezones_label addGestureRecognizer:recognizer];
    
    UITapGestureRecognizer *keyboard_down_recognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(makeKeyboardDisappear:)];
    [self.view addGestureRecognizer:keyboard_down_recognizer];
    
    UITapGestureRecognizer *colour1_recognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(colour1LabelTapped)];
    UITapGestureRecognizer *colour2_recognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(colour2LabelTapped)];
    [self.colour1 addGestureRecognizer:colour1_recognizer];
    [self.colour2 addGestureRecognizer:colour2_recognizer];
    
    NSMutableDictionary *timezonesSettings = [DataFramework getSettingsDictionaryForAppType:APP_TYPE_TIMEZONES];
    self.btdisalert.on = ![[timezonesSettings objectForKey:@"tim-btdisalert"] isEqual:@0];
    self.btrealert.on = ![[timezonesSettings objectForKey:@"tim-btrealert"] isEqual:@0];
    self.analogue_circles_1.on = ![[timezonesSettings objectForKey:@"tim-analogue_1"] isEqual:@0];
    self.analogue_circles_2.on = ![[timezonesSettings objectForKey:@"tim-analogue_2"] isEqual:@0];
    self.subtract_hour.on = ![[timezonesSettings objectForKey:@"tim-subtract_hour"] isEqual:@0];
    
    self.colour1.backgroundColor = [DataFramework colorFromHexString:[timezonesSettings objectForKey:@"tim-colour-1"]];
    self.colour2.backgroundColor = [DataFramework colorFromHexString:[timezonesSettings objectForKey:@"tim-colour-2"]];

    self.name_1.text = [timezonesSettings objectForKey:@"tim-name-1"];
    self.name_2.text = [timezonesSettings objectForKey:@"tim-name-2"];
    
    self.timezones_label.text = [NSString stringWithFormat:@"Timezone: %@", (NSString*)[timezonesSettings objectForKey:@"tim-timezone"]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (IBAction)makeKeyboardDisappear:(id)sender {
    [self textFieldShouldReturn:self.name_1];
    [self textFieldShouldReturn:self.name_2];
}

- (IBAction)nameValueChanged:(id)sender{
    UITextField *senderField = (UITextField*)sender;
    if(senderField == self.name_1){
        [DataFramework sendColourToPebble:senderField.text :3 :@"tim-name-1" :[PebbleInfo getAppUUID:APP_TYPE_TIMEZONES]];
    }
    else{
        [DataFramework sendColourToPebble:senderField.text :9 :@"tim-name-2" :[PebbleInfo getAppUUID:APP_TYPE_TIMEZONES]];
    }
}

- (void)colour1LabelTapped {
    [self setUpColourPicker:4 :@"tim-colour-1" :APP_TYPE_TIMEZONES :self.colour1];
}

- (void)colour2LabelTapped {
    [self setUpColourPicker:10 :@"tim-colour-2" :APP_TYPE_TIMEZONES :self.colour2];
}

- (void)timezonesButtonPushed{
    UINavigationController *navigationController = (UINavigationController *)[self.storyboard instantiateViewControllerWithIdentifier:@"SimpleTableVC"];
    NSLog(@"0.1");
    SimpleTableViewController *tableViewController = (SimpleTableViewController *)[[navigationController viewControllers] objectAtIndex:0];
    NSLog(@"0.3");
    tableViewController.tableData = [NSTimeZone knownTimeZoneNames];
    NSLog(@"0.5");
    tableViewController.navigationItem.title = @"Timezones";
    NSLog(@"1");
    tableViewController.delegate = self;
    NSLog(@"Presenting presentation");
    [self presentViewController:navigationController animated:YES completion:nil];
}

- (void)itemSelectedatRow:(NSInteger)row{
    NSLog(@"row %lu selected", (unsigned long)row);
    NSString *name = [[NSTimeZone knownTimeZoneNames] objectAtIndex:row];
    [self.timezones_label setText:[NSString stringWithFormat:@"Timezone: %@", name]];
    
    NSTimeZone *nba = [NSTimeZone localTimeZone];
    NSTimeZone *inTheZone = [NSTimeZone timeZoneWithName:[[NSTimeZone knownTimeZoneNames] objectAtIndex:row]];
    
    //long timeDifference = nba.getRawOffset() - inTheZone.getRawOffset() + nba.getDSTSavings() - inTheZone.getDSTSavings();
    long difference = nba.secondsFromGMT - inTheZone.secondsFromGMT;
    if(nba.daylightSavingTime)
        difference += nba.daylightSavingTimeOffset;
    if(inTheZone.daylightSavingTime)
        difference -= nba.daylightSavingTimeOffset;
    
    [DataFramework sendNumberToPebble:[NSNumber numberWithLong:difference] :7 :@"tim-timezone" :[PebbleInfo getAppUUID:APP_TYPE_TIMEZONES]];
    
    [DataFramework updateStringSetting:APP_TYPE_TIMEZONES :(NSString*)name :@"tim-timezone"];
}

- (IBAction)valueSwitchChanged:(id)sender {
    UISwitch *changedSwitch = sender;
    if(changedSwitch == self.btdisalert){
        [DataFramework sendBooleanToPebble:changedSwitch.on :0 :@"tim-btdisalert" :[PebbleInfo getAppUUID:APP_TYPE_TIMEZONES]];
    }
    else if(changedSwitch == self.btrealert){
        [DataFramework sendBooleanToPebble:changedSwitch.on :1 :@"tim-btrealert" :[PebbleInfo getAppUUID:APP_TYPE_TIMEZONES]];
    }
    else if(changedSwitch == self.analogue_circles_1){
        [DataFramework sendBooleanToPebble:changedSwitch.on :5 :@"tim-analogue_1" :[PebbleInfo getAppUUID:APP_TYPE_TIMEZONES]];
    }
    else if(changedSwitch == self.analogue_circles_2){
        [DataFramework sendBooleanToPebble:changedSwitch.on :11 :@"tim-analogue_2" :[PebbleInfo getAppUUID:APP_TYPE_TIMEZONES]];
    }
    else if(changedSwitch == self.subtract_hour){
        [DataFramework sendBooleanToPebble:changedSwitch.on :8 :@"tim-subtract_hour" :[PebbleInfo getAppUUID:APP_TYPE_TIMEZONES]];
    }
    else{
        NSLog(@"Unrecognized switch %@", changedSwitch);
    }
}

- (void)setUpColourPicker:(NSInteger)key :(NSString*)keyName :(AppTypeCode)code :(UILabel*)label {
    DRColorPickerBackgroundColor = [UIColor colorWithWhite:1.0f alpha:1.0f];
    
    // border color of the color thumbnails
    DRColorPickerBorderColor = [UIColor blackColor];
    
    // font for any labels in the color picker
    DRColorPickerFont = [UIFont systemFontOfSize:16.0f];
    
    // font color for labels in the color picker
    DRColorPickerLabelColor = [UIColor blackColor];
    // END REQUIRED SETUP
    
    DRColorPickerStoreMaxColors = 200;
    
    // show a saturation bar in the color wheel view - default is NO
    DRColorPickerShowSaturationBar = NO;
    
    // highlight the last hue in the hue view - default is NO
    DRColorPickerHighlightLastHue = YES;
    
    DRColorPickerUsePNG = NO;
    
    DRColorPickerJPEG2000Quality = 0.9f;
    
    // set to your shared app group to use the same color picker settings with multiple apps and extensions
    DRColorPickerSharedAppGroup = nil;
    // END OPTIONAL SETUP
    
    // create the color picker
    DRColorPickerViewController* vc = [DRColorPickerViewController newColorPickerWithColor:self.color];
    vc.modalPresentationStyle = UIModalPresentationFormSheet;
    vc.rootViewController.showAlphaSlider = NO; // default is YES, set to NO to hide the alpha slider
    
    vc.rootViewController.addToFavoritesImage = nil;
    vc.rootViewController.favoritesImage = nil;
    vc.rootViewController.hueImage = nil;
    vc.rootViewController.wheelImage = nil;
    vc.rootViewController.importImage = nil;
    
    vc.rootViewController.importBlock = nil;
    
    vc.rootViewController.dismissBlock = ^(BOOL cancel){
        [self dismissViewControllerAnimated:YES completion:nil];
    };
    
    vc.rootViewController.colorSelectedBlock = ^(DRColorPickerColor* color, DRColorPickerBaseViewController* vc){
        self.color = color;
        
        label.backgroundColor = color.rgbColor;
        
        //self.outerLabel.backgroundColor = color.rgbColor;
        self.color.alpha = 1.0;
        
        CGFloat floatR,floatG,floatB, a;
        [self.color.rgbColor getRed:&floatR green:&floatG blue: &floatB alpha: &a];
        
        int r = (int)(255.0 * floatR);
        int g = (int)(255.0 * floatG);
        int b = (int)(255.0 * floatB);
        
        NSString *string = [NSString stringWithFormat:@"%02x%02x%02x", r, g, b];
        [DataFramework sendColourToPebble:string :key :keyName :[PebbleInfo getAppUUID:code]];
    };
    
    [self presentViewController:vc animated:YES completion:nil];
}


@end
