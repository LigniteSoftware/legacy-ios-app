//
//  TreeOfColoursTableViewController.m
//  Lignite
//
//  Created by Edwin Finch on 2015-06-25.
//  Copyright © 2015 Edwin Finch. All rights reserved.
//

#import <DRColorPicker/DRColorPicker.h>
#import "PebbleInfo.h"
#import "DataFramework.h"
#import "TreeOfColours.h"

@interface TreeOfColoursTableViewController ()

@property (nonatomic, strong) DRColorPickerColor* color;

@end

@implementation TreeOfColoursTableViewController

-(void)updateCustomColours {
    self.custColour1Label.userInteractionEnabled = !self.randomizeSwitch.on;
    self.custColour2Label.userInteractionEnabled = !self.randomizeSwitch.on;
    self.custColour3Label.userInteractionEnabled = !self.randomizeSwitch.on;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UITapGestureRecognizer *custCol1 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(customColourLabel1Tapped)];
    UITapGestureRecognizer *custCol2 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(customColourLabel2Tapped)];
    UITapGestureRecognizer *custCol3 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(customColourLabel3Tapped)];
    UITapGestureRecognizer *circleCol = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(circleColourLabel)];
    UITapGestureRecognizer *timeCol = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(timeColourLabelTapped)];
    
    [self.custColour1Label addGestureRecognizer:custCol1];
    [self.custColour2Label addGestureRecognizer:custCol2];
    [self.custColour3Label addGestureRecognizer:custCol3];
    [self.circleColourLabel addGestureRecognizer:circleCol];
    [self.timeColourLabel addGestureRecognizer:timeCol];
    
    NSMutableDictionary *treeOfColorSettings = [DataFramework getSettingsDictionaryForAppType:APP_TYPE_TREE_OF_COLOURS];
    self.btdisalertSwitch.on = ![[treeOfColorSettings objectForKey:@"tre-btdisalert"] isEqual:@0];
    self.btrealertSwitch.on = ![[treeOfColorSettings objectForKey:@"tre-btrealert"] isEqual:@0];
    self.randomizeSwitch.on = ![[treeOfColorSettings objectForKey:@"tre-randomize"] isEqual:@0];
    
    NSNumber *barWidth = [treeOfColorSettings objectForKey:@"tre-bar-width"];
    self.defaultWidthLabel.text = [NSString stringWithFormat:@"%d", [barWidth intValue]];
    self.defaultWidthSlider.value = [barWidth floatValue];
    
    self.custColour1Label.backgroundColor = [DataFramework colorFromHexString:[treeOfColorSettings objectForKey:@"tre-custom-colour-1"]];
    self.custColour2Label.backgroundColor = [DataFramework colorFromHexString:[treeOfColorSettings objectForKey:@"tre-custom-colour-2"]];
    self.custColour3Label.backgroundColor = [DataFramework colorFromHexString:[treeOfColorSettings objectForKey:@"tre-custom-colour-3"]];
    self.circleColourLabel.backgroundColor = [DataFramework colorFromHexString:[treeOfColorSettings objectForKey:@"tre-circle-colour"]];
    self.timeColourLabel.backgroundColor = [DataFramework colorFromHexString:[treeOfColorSettings objectForKey:@"tre-time-colour"]];
    
    self.circleColourLabel.userInteractionEnabled = YES;
    [self updateCustomColours];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated. 18009592250
}

- (void)customColourLabel1Tapped {
    [self setUpColourPicker:6 :@"tre-custom-colour-1" :APP_TYPE_TREE_OF_COLOURS :self.custColour1Label];
}

- (void)customColourLabel2Tapped {
    [self setUpColourPicker:7 :@"tre-custom-colour-2" :APP_TYPE_TREE_OF_COLOURS :self.custColour2Label];
}

- (void)customColourLabel3Tapped {
    [self setUpColourPicker:8 :@"tre-custom-colour-3" :APP_TYPE_TREE_OF_COLOURS :self.custColour3Label];
}

- (void)circleColourLabelTapped {
    NSLog(@"tapped");
    [self setUpColourPicker:10 :@"tre-circle-colour" :APP_TYPE_TREE_OF_COLOURS :self.circleColourLabel];
}

- (void)timeColourLabelTapped {
    [self setUpColourPicker:11 :@"tre-time-colour" :APP_TYPE_TREE_OF_COLOURS :self.timeColourLabel];
}

- (IBAction)barWidthValueChanged:(id)sender {
    UISlider *slider = (UISlider*)sender;
    int value = floor(slider.value);
    self.defaultWidthLabel.text = [NSString stringWithFormat:@"%d", value];
}

- (IBAction)barWidthValueChangedFinal:(id)sender {
    UISlider *slider = (UISlider*)sender;
    int value = floor(slider.value);
    [DataFramework sendNumberToPebble:[NSNumber numberWithInt:value] :4 :@"tre-bar-width" :[PebbleInfo getAppUUID:APP_TYPE_TREE_OF_COLOURS]];
    self.defaultWidthLabel.text = [NSString stringWithFormat:@"%d", value];
}

- (IBAction)valueSwitchChanged:(id)sender {
    UISwitch *changedSwitch = sender;
    if(changedSwitch == self.btdisalertSwitch){
        [DataFramework sendBooleanToPebble:changedSwitch.on :0 :@"tre-btdisalert" :[PebbleInfo getAppUUID:APP_TYPE_TREE_OF_COLOURS]];
    }
    else if(changedSwitch == self.btrealertSwitch){
        [DataFramework sendBooleanToPebble:changedSwitch.on :1 :@"tre-btrealert" :[PebbleInfo getAppUUID:APP_TYPE_TREE_OF_COLOURS]];
    }
    else if(changedSwitch == self.randomizeSwitch){
        [DataFramework sendBooleanToPebble:changedSwitch.on :3 :@"tre-randomize" :[PebbleInfo getAppUUID:APP_TYPE_TREE_OF_COLOURS]];
        [self updateCustomColours];
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
