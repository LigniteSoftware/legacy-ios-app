//
//  LinesTableViewController.m
//  Lignite
//
//  Created by Edwin Finch on 2015-06-01.
//  Copyright (c) 2015 Edwin Finch. All rights reserved.
//

#import <DRColorPicker/DRColorPicker.h>
#import "PebbleInfo.h"
#import "DataFramework.h"
#import "Lines.h"

@interface LinesTableViewController () <UIGestureRecognizerDelegate>

@property (nonatomic, strong) DRColorPickerColor* color;

@end

@implementation LinesTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UITapGestureRecognizer *timeRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(timeLabelTapped)];
    UITapGestureRecognizer *dateRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(dateLabelTapped)];
    UITapGestureRecognizer *backgroundRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(backgroundLabelTapped)];
    
    [self.timeColourLabel addGestureRecognizer:timeRecognizer];
    [self.dateColourLabel addGestureRecognizer:dateRecognizer];
    [self.backgroundColourLabel addGestureRecognizer:backgroundRecognizer];
    
    NSMutableDictionary *linesSettings = [DataFramework getSettingsDictionaryForAppType:APP_TYPE_LINES];
    self.btdisalertSwitch.on = ![[linesSettings objectForKey:@"lin-btdisalert"] isEqual:@0];
    self.btrealertSwitch.on = ![[linesSettings objectForKey:@"lin-btrealert"] isEqual:@0];
    self.showDateSwitch.on = ![[linesSettings objectForKey:@"lin-showdate"] isEqual:@0];
    self.altDateFormatSwitch.on = ![[linesSettings objectForKey:@"lin-altdate"] isEqual:@0];
    self.timeColourLabel.backgroundColor = [DataFramework colorFromHexString:[linesSettings objectForKey:@"lin-time-colour"]];
    self.dateColourLabel.backgroundColor = [DataFramework colorFromHexString:[linesSettings objectForKey:@"lin-date-colour"]];
    self.backgroundColourLabel.backgroundColor = [DataFramework colorFromHexString:[linesSettings objectForKey:@"lin-background-colour"]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)timeLabelTapped {
    [self setUpColourPicker:6 :@"lin-time-colour" :APP_TYPE_LINES :self.timeColourLabel];
}

- (void)dateLabelTapped {
    [self setUpColourPicker:7 :@"lin-date-colour" :APP_TYPE_LINES :self.dateColourLabel];
}

- (void)backgroundLabelTapped {
    [self setUpColourPicker:8 :@"lin-background-colour" :APP_TYPE_LINES :self.backgroundColourLabel];
}

- (IBAction)valueSwitchChanged:(id)sender {
    UISwitch *changedSwitch = sender;
    if(changedSwitch == self.btdisalertSwitch){
        [DataFramework sendBooleanToPebble:changedSwitch.on :0 :@"lin-btdisalert" :[PebbleInfo getAppUUID:APP_TYPE_LINES]];
    }
    else if(changedSwitch == self.btrealertSwitch){
        [DataFramework sendBooleanToPebble:changedSwitch.on :1 :@"lin-btrealert" :[PebbleInfo getAppUUID:APP_TYPE_LINES]];
    }
    else if(changedSwitch == self.showDateSwitch){
        [DataFramework sendBooleanToPebble:changedSwitch.on :3 :@"lin-showdate" :[PebbleInfo getAppUUID:APP_TYPE_LINES]];
    }
    else if(changedSwitch == self.altDateFormatSwitch){
        [DataFramework sendBooleanToPebble:changedSwitch.on :4 :@"lin-altdate" :[PebbleInfo getAppUUID:APP_TYPE_LINES]];
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
