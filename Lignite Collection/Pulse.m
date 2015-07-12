//
//  PulseTableViewController.m
//  
//
//  Created by Edwin Finch on 2015-07-09.
//
//

#import <DRColorPicker/DRColorPicker.h>
#import "Pulse.h"
#import "PebbleInfo.h"
#import "DataFramework.h"

@interface PulseTableViewController ()

@property (nonatomic, strong) DRColorPickerColor* color;

@end

@implementation PulseTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSMutableDictionary *pulseSettings = [DataFramework getSettingsDictionaryForAppType:APP_TYPE_PULSE];
    self.btdisalertSwitch.on = ![[pulseSettings objectForKey:@"pul-btdisalert"] isEqual:@0];
    self.btrealertSwitch.on = ![[pulseSettings objectForKey:@"pul-btrealert"] isEqual:@0];
    self.invertSwitch.on = ![[pulseSettings objectForKey:@"pul-invert"] isEqual:@0];
    self.shakeToAnimateSwitch.on = ![[pulseSettings objectForKey:@"pul-shake"] isEqual:@0];
    self.constAnimSwitch.on = ![[pulseSettings objectForKey:@"pul-constant"] isEqual:@0];
    
    UITapGestureRecognizer *colour1_recognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(circleColourLabel)];
    UITapGestureRecognizer *colour2_recognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(backgroundColourLabel)];
    [self.circleColourLabel addGestureRecognizer:colour1_recognizer];
    [self.backgroundColourLabel addGestureRecognizer:colour2_recognizer];
    
    self.circleColourLabel.backgroundColor = [DataFramework colorFromHexString:[pulseSettings objectForKey:@"pul-circle-colour"]];
    self.backgroundColourLabel.backgroundColor = [DataFramework colorFromHexString:[pulseSettings objectForKey:@"pul-background-colour"]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)circleColourLabelTapped {
    [self setUpColourPicker:7 :@"pul-circle-colour" :APP_TYPE_PULSE :self.circleColourLabel];
}

- (void)backgroundColourLabelTapped {
    [self setUpColourPicker:8 :@"pul-background-colour" :APP_TYPE_PULSE :self.backgroundColourLabel];
}

- (IBAction)valueSwitchChanged:(id)sender {
    UISwitch *changedSwitch = sender;
    if(changedSwitch == self.btdisalertSwitch){
        [DataFramework sendBooleanToPebble:changedSwitch.on :0 :@"pul-btdisalert" :[PebbleInfo getAppUUID:APP_TYPE_PULSE]];
    }
    else if(changedSwitch == self.btrealertSwitch){
        [DataFramework sendBooleanToPebble:changedSwitch.on :1 :@"pul-btrealert" :[PebbleInfo getAppUUID:APP_TYPE_PULSE]];
    }
    else if(changedSwitch == self.invertSwitch){
        [DataFramework sendBooleanToPebble:changedSwitch.on :3 :@"pul-invert" :[PebbleInfo getAppUUID:APP_TYPE_PULSE]];
    }
    else if(changedSwitch == self.shakeToAnimateSwitch){
        [DataFramework sendBooleanToPebble:changedSwitch.on :4 :@"pul-shake" :[PebbleInfo getAppUUID:APP_TYPE_PULSE]];
    }
    else if(changedSwitch == self.constAnimSwitch){
        [DataFramework sendBooleanToPebble:changedSwitch.on :5 :@"pul-constant" :[PebbleInfo getAppUUID:APP_TYPE_PULSE]];
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
