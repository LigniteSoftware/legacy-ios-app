//
//  ChunkyViewController.m
//  Lignite
//
//  Created by Edwin Finch on 2015-05-30.
//  Copyright (c) 2015 Edwin Finch. All rights reserved.
//

#import <DRColorPicker/DRColorPicker.h>
#import "Chunky.h"
#import "DataFramework.h"

@interface ChunkyTableViewController () <UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, strong) DRColorPickerColor* color;
@property (nonatomic, weak) DRColorPickerViewController* colorPickerVC;

@end

@implementation ChunkyTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UITapGestureRecognizer *recognizerMinute = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(minuteLabelTapped)];
    UITapGestureRecognizer *recognizerHour = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hourLabelTapped)];
    UITapGestureRecognizer *recognizerBackground = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(backgroundLabelTapped)];
    
    self.minuteColourLabel.userInteractionEnabled = YES;
    self.hourColourLabel.userInteractionEnabled = YES;
    self.backgroundColourLabel.userInteractionEnabled = YES;
    
    [self.minuteColourLabel addGestureRecognizer:recognizerMinute];
    [self.hourColourLabel addGestureRecognizer:recognizerHour];
    [self.backgroundColourLabel addGestureRecognizer:recognizerBackground];
    
    NSMutableDictionary *chunkySettings = [DataFramework getSettingsDictionaryForAppType:APP_TYPE_CHUNKY];
    self.invertSwitch.on = ![[chunkySettings objectForKey:@"chu-invert"] isEqual:@(0)];
    self.btdisalertSwitch.on = ![[chunkySettings objectForKey:@"chu-btdisalert"] isEqual:@(0)];
    self.btrealertSwitch.on = ![[chunkySettings objectForKey:@"chu-btrealert"] isEqual:@(0)];
    self.showBatteryBarSwitch.on = ![[chunkySettings objectForKey:@"chu-batterybar"] isEqual:@(0)];

    self.minuteColourLabel.backgroundColor = [DataFramework colorFromHexString:[chunkySettings objectForKey:@"chu-minute-colour"]];
    self.hourColourLabel.backgroundColor = [DataFramework colorFromHexString:[chunkySettings objectForKey:@"chu-hour-colour"]];
    self.backgroundColourLabel.backgroundColor = [DataFramework colorFromHexString:[chunkySettings objectForKey:@"chu-background-colour"]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)minuteLabelTapped {
    [self setUpColourPicker:6 :@"chu-minute-colour" :APP_TYPE_CHUNKY :self.minuteColourLabel];
}

- (void)hourLabelTapped {
    [self setUpColourPicker:7 :@"chu-hour-colour" :APP_TYPE_CHUNKY :self.hourColourLabel];
}

- (void)backgroundLabelTapped {
    [self setUpColourPicker:8 :@"chu-background-colour" :APP_TYPE_CHUNKY :self.backgroundColourLabel];
}

- (IBAction)invertSwitchChanged:(id)sender {
    UISwitch *currentSwitch = sender;
    [DataFramework sendBooleanToPebble:currentSwitch.on :3 :@"chu-invert" :[PebbleInfo getAppUUID:APP_TYPE_CHUNKY]];
}

- (IBAction)btrealertSwitchChanged:(id)sender {
    UISwitch *currentSwitch = sender;
    [DataFramework sendBooleanToPebble:currentSwitch.on :1 :@"chu-btrealert" :[PebbleInfo getAppUUID:APP_TYPE_CHUNKY]];
}

- (IBAction)batteryBarSwitchChanged:(id)sender {
    UISwitch *currentSwitch = sender;
    [DataFramework sendBooleanToPebble:currentSwitch.on :4 :@"chu-batterybar" :[PebbleInfo getAppUUID:APP_TYPE_CHUNKY]];
}

- (IBAction)btdisalertSwitchChanged:(id)sender {
    UISwitch *currentSwitch = sender;
    [DataFramework sendBooleanToPebble:currentSwitch.on :0 :@"chu-btdisalert" :[PebbleInfo getAppUUID:APP_TYPE_CHUNKY]];
}

#pragma mark - Table view data source

- (void)setUpColourPicker:(NSInteger)key :(NSString*)keyName :(AppTypeCode)code :(UILabel*)label {
    DRColorPickerBackgroundColor = [UIColor colorWithWhite:1.0f alpha:1.0f];
    
    // border color of the color thumbnails
    DRColorPickerBorderColor = [UIColor blackColor];
    
    // font for any labels in the color picker
    DRColorPickerFont = [UIFont systemFontOfSize:16.0f];
    
    // font color for labels in the color picker
    DRColorPickerLabelColor = [UIColor blackColor];
    // END REQUIRED SETUP
    
    // OPTIONAL SETUP....................
    // max number of colors in the recent and favorites - default is 200
    DRColorPickerStoreMaxColors = 200;
    
    // show a saturation bar in the color wheel view - default is NO
    DRColorPickerShowSaturationBar = NO;
    
    // highlight the last hue in the hue view - default is NO
    DRColorPickerHighlightLastHue = YES;

    DRColorPickerUsePNG = NO;
    
    // JPEG2000 quality default is 0.9, which really reduces the file size but still keeps a nice looking image
    // *** WARNING - NEVER CHANGE THIS ONCE YOU RELEASE YOUR APP!!! ***
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
