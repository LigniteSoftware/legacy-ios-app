//
//  ColoursTableViewController.m
//  Lignite
//
//  Created by Edwin Finch on 2015-06-01.
//  Copyright (c) 2015 Edwin Finch. All rights reserved.
//

#import <DRColorPicker/DRColorPicker.h>
#import "PebbleInfo.h"
#import "DataFramework.h"
#import "Colours.h"

@interface ColoursTableViewController ()

@property (nonatomic, strong) DRColorPickerColor* color;

@end

@implementation ColoursTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UITapGestureRecognizer *recognizerMinute = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(minuteLabelTapped)];
    UITapGestureRecognizer *recognizerHour = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hourLabelTapped)];

    [self.minuteColourLabel addGestureRecognizer:recognizerMinute];
    [self.hourColourLabel addGestureRecognizer:recognizerHour];
    
    NSMutableDictionary *colourSettings = [DataFramework getSettingsDictionaryForAppType:APP_TYPE_COLOURS];
    
    self.btdisalertSwitch.on = ![[colourSettings objectForKey:@"col-btdisalert"]isEqual:@0];
    self.btrealertSwitch.on = ![[colourSettings objectForKey:@"col-btrealert"]isEqual:@0];
    self.organizeSwitch.on = ![[colourSettings objectForKey:@"col-organize"]isEqual:@0];
    self.randomizeSwitch.on = ![[colourSettings objectForKey:@"col-randomize"]isEqual:@0];
    NSNumber *barWidth = [colourSettings objectForKey:@"col-bar-width"];
    self.barWidthValueLabel.text = [NSString stringWithFormat:@"%d", [barWidth intValue]];
    self.barWidthSlider.value = [barWidth floatValue];
    self.minuteColourLabel.backgroundColor = [DataFramework colorFromHexString:[colourSettings objectForKey:@"col-minute-colour"]];
    self.hourColourLabel.backgroundColor = [DataFramework colorFromHexString:[colourSettings objectForKey:@"col-hour-colour"]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)booleanChanged:(id)sender {
    UISwitch *senderSwitch = sender;
    if(senderSwitch == self.btdisalertSwitch){
        [DataFramework sendBooleanToPebble:senderSwitch.on :0 :@"col-btdisalert" :[PebbleInfo getAppUUID:APP_TYPE_COLOURS]];
    }
    else if(senderSwitch == self.btrealertSwitch){
        [DataFramework sendBooleanToPebble:senderSwitch.on :1 :@"col-btrealert" :[PebbleInfo getAppUUID:APP_TYPE_COLOURS]];
    }
    else if(senderSwitch == self.organizeSwitch){
        [DataFramework sendBooleanToPebble:senderSwitch.on :4 :@"col-organize" :[PebbleInfo getAppUUID:APP_TYPE_COLOURS]];
    }
    else if(senderSwitch == self.randomizeSwitch){
        [DataFramework sendBooleanToPebble:senderSwitch.on :5 :@"col-randomize" :[PebbleInfo getAppUUID:APP_TYPE_COLOURS]];
    }
    else{
        NSLog(@"Error: unrecognized switch: %@.", senderSwitch);
    }
}

- (IBAction)barWidthValueChanged:(id)sender {
    UISlider *slider = (UISlider*)sender;
    int value = floor(slider.value);
    self.barWidthValueLabel.text = [NSString stringWithFormat:@"%d", value];
}

- (IBAction)barWidthValueChangedFinal:(id)sender {
    UISlider *slider = (UISlider*)sender;
    int value = floor(slider.value);
    [DataFramework sendNumberToPebble:[NSNumber numberWithInt:value] :6 :@"col-bar-width" :[PebbleInfo getAppUUID:APP_TYPE_COLOURS]];
    self.barWidthValueLabel.text = [NSString stringWithFormat:@"%d", value];
}

- (void)minuteLabelTapped {
    [self setUpColourPicker:9 :@"col-minute-colour" :APP_TYPE_COLOURS :self.minuteColourLabel];
}

- (void)hourLabelTapped {
    [self setUpColourPicker:8 :@"col-hour-colour" :APP_TYPE_COLOURS :self.hourColourLabel];
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
