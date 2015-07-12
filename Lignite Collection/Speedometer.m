//
//  SettingsViewController.m
//  Lignite
//
//  Created by Edwin Finch on 2015-05-19.
//  Copyright (c) 2015 Edwin Finch. All rights reserved.
//

#import <DRColorPicker/DRColorPicker.h>
#import <PebbleKit/PebbleKit.h>
#import "Speedometer.h"
#import "DataFramework.h"

@interface SpeedometerSettingsViewController () <UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, strong) DRColorPickerColor* color;
@property (nonatomic, weak) DRColorPickerViewController* colorPickerVC;

@end

@implementation SpeedometerSettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSLog(@"Got current type as %d", self.appType);
    
    UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(colourLabelTapped)];
    [self.outerLabel addGestureRecognizer:recognizer];
    
    UITapGestureRecognizer *recognizer1 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(middleColourLabelTapped)];
    [self.middleLabel addGestureRecognizer:recognizer1];
    
    UITapGestureRecognizer *recognizer2 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(innerColourLabelTapped)];
    [self.innerLabel addGestureRecognizer:recognizer2];
    
    NSMutableDictionary *speedometerSettings = [DataFramework getSettingsDictionaryForAppType:APP_TYPE_SPEEDOMETER];
    NSObject* invert = [speedometerSettings objectForKey:@"spe-invert"];
    if([invert isEqual: @(0)]){
        self.invertSwitch.on = NO;
    }
    else{
        self.invertSwitch.on = YES;
    }
    
    NSObject* btdisalert = [speedometerSettings objectForKey:@"spe-btdisalert"];
    if([btdisalert isEqual: @(0)]){
        self.btDisAlertSwitch.on = NO;
    }
    else{
        self.btDisAlertSwitch.on = YES;
    }
    
    NSObject* btrealert = [speedometerSettings objectForKey:@"spe-btrealert"];
    if([btrealert isEqual: @(0)]){
        self.btReAlertSwitch.on = NO;
    }
    else{
        self.btReAlertSwitch.on = YES;
    }
    
    NSObject* bootanim = [speedometerSettings objectForKey:@"spe-bootanim"];
    if([bootanim isEqual: @(0)]){
        self.bootAnimationSwitch.on = NO;
    }
    else{
        self.bootAnimationSwitch.on = YES;
    }
    
    NSObject* bticon = [speedometerSettings objectForKey:@"spe-bticon"];
    if([bticon isEqual: @(0)]){
        self.btIconSwitch.on = NO;
    }
    else{
        self.btIconSwitch.on = YES;
    }
    
    NSObject* dithering = [speedometerSettings objectForKey:@"spe-dithering"];
    if([dithering isEqual: @(0)]){
        self.ditheringSwitch.on = NO;
    }
    else{
        self.ditheringSwitch.on = YES;
    }
    
    UIColor *color = [DataFramework colorFromHexString:[speedometerSettings objectForKey:@"spe-outer-colour"]];
    self.outerLabel.backgroundColor = color;
    
    UIColor *color1 = [DataFramework colorFromHexString:[speedometerSettings objectForKey:@"spe-middle-colour"]];
    self.middleLabel.backgroundColor = color1;
    
    UIColor *color2 = [DataFramework colorFromHexString:[speedometerSettings objectForKey:@"spe-inner-colour"]];
    self.innerLabel.backgroundColor = color2;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)invertSwitchChanged:(id)sender {
    UISwitch *currentSwitch = sender;
    [DataFramework sendBooleanToPebble:currentSwitch.on :0 :@"spe-invert" :[PebbleInfo getAppUUID:APP_TYPE_SPEEDOMETER]];
}

- (IBAction)btDisAlertChanged:(id)sender {
    UISwitch *currentSwitch = sender;
    [DataFramework sendBooleanToPebble:currentSwitch.on :1 :@"spe-btdisalert" :[PebbleInfo getAppUUID:APP_TYPE_SPEEDOMETER]];
}

- (IBAction)btReAlertChanged:(id)sender {
    UISwitch *currentSwitch = sender;
    [DataFramework sendBooleanToPebble:currentSwitch.on :2 :@"spe-btrealert" :[PebbleInfo getAppUUID:APP_TYPE_SPEEDOMETER]];
}

- (IBAction)bootAnimationChanged:(id)sender {
    UISwitch *currentSwitch = sender;
    [DataFramework sendBooleanToPebble:currentSwitch.on :4 :@"spe-bootanim" :[PebbleInfo getAppUUID:APP_TYPE_SPEEDOMETER]];
}

- (IBAction)btIconChanged:(id)sender {
    UISwitch *currentSwitch = sender;
    [DataFramework sendBooleanToPebble:currentSwitch.on :5 :@"spe-bticon" :[PebbleInfo getAppUUID:APP_TYPE_SPEEDOMETER]];
}

- (IBAction)ditheringChanged:(id)sender {
    UISwitch *currentSwitch = sender;
    [DataFramework sendBooleanToPebble:currentSwitch.on :6 :@"spe-dithering" :[PebbleInfo getAppUUID:APP_TYPE_SPEEDOMETER]];
}

- (void)colourLabelTapped {
    // Setup the color picker - this only has to be done once, but can be called again and again if the values need to change while the app runs
    //    DRColorPickerThumbnailSizeInPointsPhone = 44.0f; // default is 42
    //    DRColorPickerThumbnailSizeInPointsPad = 44.0f; // default is 54
    
    // REQUIRED SETUP....................
    // background color of each view
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
    
    // use JPEG2000, not PNG which is the default
    // *** WARNING - NEVER CHANGE THIS ONCE YOU RELEASE YOUR APP!!! ***
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
    
    NSInteger theme = 2; // 0 = default, 1 = dark, 2 = light
    
    // in addition to the default images, you can set the images for a light or dark navigation bar / toolbar theme, these are built-in to the color picker bundle
    if (theme == 0)
    {
        // setting these to nil (the default) tells it to use the built-in default images
        vc.rootViewController.addToFavoritesImage = nil;
        vc.rootViewController.favoritesImage = nil;
        vc.rootViewController.hueImage = nil;
        vc.rootViewController.wheelImage = nil;
        vc.rootViewController.importImage = nil;
    }
    else if (theme == 1)
    {
        vc.rootViewController.addToFavoritesImage = DRColorPickerImage(@"images/dark/drcolorpicker-addtofavorites-dark.png");
        vc.rootViewController.favoritesImage = DRColorPickerImage(@"images/dark/drcolorpicker-favorites-dark.png");
        vc.rootViewController.hueImage = DRColorPickerImage(@"images/dark/drcolorpicker-hue-v3-dark.png");
        vc.rootViewController.wheelImage = DRColorPickerImage(@"images/dark/drcolorpicker-wheel-dark.png");
        //vc.rootViewController.importImage = DRColorPickerImage(@"images/dark/drcolorpicker-import-dark.png");
    }
    else if (theme == 2)
    {
        vc.rootViewController.addToFavoritesImage = DRColorPickerImage(@"images/light/drcolorpicker-addtofavorites-light.png");
        vc.rootViewController.favoritesImage = DRColorPickerImage(@"images/light/drcolorpicker-favorites-light.png");
        vc.rootViewController.hueImage = DRColorPickerImage(@"images/light/drcolorpicker-hue-v3-light.png");
        vc.rootViewController.wheelImage = DRColorPickerImage(@"images/light/drcolorpicker-wheel-light.png");
        //vc.rootViewController.importImage = DRColorPickerImage(@"images/light/drcolorpicker-import-light.png");
    }
    
    // assign a weak reference to the color picker, need this for UIImagePickerController delegate
    self.colorPickerVC = vc;
    
    // make an import block, this allows using images as colors, this import block uses the UIImagePickerController,
    // but in You Doodle for iOS, I have a more complex import that allows importing from many different sources
    // *** Leave this as nil to not allowing import of textures ***
    vc.rootViewController.importBlock = ^(UINavigationController* navVC, DRColorPickerHomeViewController* rootVC, NSString* title)
    {
        UIImagePickerController* p = [[UIImagePickerController alloc] init];
        p.delegate = self;
        p.modalPresentationStyle = UIModalPresentationCurrentContext;
        [self.colorPickerVC presentViewController:p animated:YES completion:nil];
    };
    
    // dismiss the color picker
    vc.rootViewController.dismissBlock = ^(BOOL cancel)
    {
        [self dismissViewControllerAnimated:YES completion:nil];
    };
    
    // a color was selected, do something with it, but do NOT dismiss the color picker, that happens in the dismissBlock
    vc.rootViewController.colorSelectedBlock = ^(DRColorPickerColor* color, DRColorPickerBaseViewController* vc)
    {
        self.color = color;
        if (color.rgbColor == nil)
        {
            self.view.backgroundColor = [UIColor colorWithPatternImage:color.image];
        }
        else
        {
            self.outerLabel.backgroundColor = color.rgbColor;
            self.color.alpha = 1.0;
            
            CGFloat floatR,floatG,floatB, a;
            [self.color.rgbColor getRed:&floatR green:&floatG blue: &floatB alpha: &a];
            
            int r = (int)(255.0 * floatR);
            int g = (int)(255.0 * floatG);
            int b = (int)(255.0 * floatB);
            
            NSString *string = [NSString stringWithFormat:@"%02x%02x%02x", r, g, b];
            NSLog(@"String: %@", string);
            [DataFramework sendColourToPebble:string :8 :@"spe-outer-colour" :[PebbleInfo getAppUUID:APP_TYPE_SPEEDOMETER]];
        }
    };
    
    // finally, present the color picker
    [self presentViewController:vc animated:YES completion:nil];
}

- (void)middleColourLabelTapped {
    // Setup the color picker - this only has to be done once, but can be called again and again if the values need to change while the app runs
    //    DRColorPickerThumbnailSizeInPointsPhone = 44.0f; // default is 42
    //    DRColorPickerThumbnailSizeInPointsPad = 44.0f; // default is 54
    
    // REQUIRED SETUP....................
    // background color of each view
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
    
    // use JPEG2000, not PNG which is the default
    // *** WARNING - NEVER CHANGE THIS ONCE YOU RELEASE YOUR APP!!! ***
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
    
    NSInteger theme = 2; // 0 = default, 1 = dark, 2 = light
    
    // in addition to the default images, you can set the images for a light or dark navigation bar / toolbar theme, these are built-in to the color picker bundle
    if (theme == 0)
    {
        // setting these to nil (the default) tells it to use the built-in default images
        vc.rootViewController.addToFavoritesImage = nil;
        vc.rootViewController.favoritesImage = nil;
        vc.rootViewController.hueImage = nil;
        vc.rootViewController.wheelImage = nil;
        vc.rootViewController.importImage = nil;
    }
    else if (theme == 1)
    {
        vc.rootViewController.addToFavoritesImage = DRColorPickerImage(@"images/dark/drcolorpicker-addtofavorites-dark.png");
        vc.rootViewController.favoritesImage = DRColorPickerImage(@"images/dark/drcolorpicker-favorites-dark.png");
        vc.rootViewController.hueImage = DRColorPickerImage(@"images/dark/drcolorpicker-hue-v3-dark.png");
        vc.rootViewController.wheelImage = DRColorPickerImage(@"images/dark/drcolorpicker-wheel-dark.png");
        //vc.rootViewController.importImage = DRColorPickerImage(@"images/dark/drcolorpicker-import-dark.png");
    }
    else if (theme == 2)
    {
        vc.rootViewController.addToFavoritesImage = DRColorPickerImage(@"images/light/drcolorpicker-addtofavorites-light.png");
        vc.rootViewController.favoritesImage = DRColorPickerImage(@"images/light/drcolorpicker-favorites-light.png");
        vc.rootViewController.hueImage = DRColorPickerImage(@"images/light/drcolorpicker-hue-v3-light.png");
        vc.rootViewController.wheelImage = DRColorPickerImage(@"images/light/drcolorpicker-wheel-light.png");
        //vc.rootViewController.importImage = DRColorPickerImage(@"images/light/drcolorpicker-import-light.png");
    }
    
    // assign a weak reference to the color picker, need this for UIImagePickerController delegate
    self.colorPickerVC = vc;
    
    // make an import block, this allows using images as colors, this import block uses the UIImagePickerController,
    // but in You Doodle for iOS, I have a more complex import that allows importing from many different sources
    // *** Leave this as nil to not allowing import of textures ***
    vc.rootViewController.importBlock = ^(UINavigationController* navVC, DRColorPickerHomeViewController* rootVC, NSString* title)
    {
        UIImagePickerController* p = [[UIImagePickerController alloc] init];
        p.delegate = self;
        p.modalPresentationStyle = UIModalPresentationCurrentContext;
        [self.colorPickerVC presentViewController:p animated:YES completion:nil];
    };
    
    // dismiss the color picker
    vc.rootViewController.dismissBlock = ^(BOOL cancel)
    {
        [self dismissViewControllerAnimated:YES completion:nil];
    };
    
    // a color was selected, do something with it, but do NOT dismiss the color picker, that happens in the dismissBlock
    vc.rootViewController.colorSelectedBlock = ^(DRColorPickerColor* color, DRColorPickerBaseViewController* vc)
    {
        self.color = color;
        if (color.rgbColor == nil)
        {
            self.view.backgroundColor = [UIColor colorWithPatternImage:color.image];
        }
        else
        {
            self.middleLabel.backgroundColor = color.rgbColor;
            self.color.alpha = 1.0;
            
            CGFloat floatR,floatG,floatB, a;
            [self.color.rgbColor getRed:&floatR green:&floatG blue: &floatB alpha: &a];
            
            int r = (int)(255.0 * floatR);
            int g = (int)(255.0 * floatG);
            int b = (int)(255.0 * floatB);
            
            NSString *string = [NSString stringWithFormat:@"%02x%02x%02x", r, g, b];
            NSLog(@"String: %@", string);
            [DataFramework sendColourToPebble:string :9 :@"spe-middle-colour" :[PebbleInfo getAppUUID:APP_TYPE_SPEEDOMETER]];
        }
    };
    
    // finally, present the color picker
    [self presentViewController:vc animated:YES completion:nil];
}

- (void)innerColourLabelTapped {
    // Setup the color picker - this only has to be done once, but can be called again and again if the values need to change while the app runs
    //    DRColorPickerThumbnailSizeInPointsPhone = 44.0f; // default is 42
    //    DRColorPickerThumbnailSizeInPointsPad = 44.0f; // default is 54
    
    // REQUIRED SETUP....................
    // background color of each view
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
    
    // use JPEG2000, not PNG which is the default
    // *** WARNING - NEVER CHANGE THIS ONCE YOU RELEASE YOUR APP!!! ***
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
    
    NSInteger theme = 0; // 0 = default, 1 = dark, 2 = light
    
    // in addition to the default images, you can set the images for a light or dark navigation bar / toolbar theme, these are built-in to the color picker bundle
    if (theme == 0)
    {
        // setting these to nil (the default) tells it to use the built-in default images
        vc.rootViewController.addToFavoritesImage = nil;
        vc.rootViewController.favoritesImage = nil;
        vc.rootViewController.hueImage = nil;
        vc.rootViewController.wheelImage = nil;
        vc.rootViewController.importImage = nil;
    }
    else if (theme == 1)
    {
        vc.rootViewController.addToFavoritesImage = DRColorPickerImage(@"images/dark/drcolorpicker-addtofavorites-dark.png");
        vc.rootViewController.favoritesImage = DRColorPickerImage(@"images/dark/drcolorpicker-favorites-dark.png");
        vc.rootViewController.hueImage = DRColorPickerImage(@"images/dark/drcolorpicker-hue-v3-dark.png");
        vc.rootViewController.wheelImage = DRColorPickerImage(@"images/dark/drcolorpicker-wheel-dark.png");
        //vc.rootViewController.importImage = DRColorPickerImage(@"images/dark/drcolorpicker-import-dark.png");
    }
    else if (theme == 2)
    {
        vc.rootViewController.addToFavoritesImage = DRColorPickerImage(@"images/light/drcolorpicker-addtofavorites-light.png");
        vc.rootViewController.favoritesImage = DRColorPickerImage(@"images/light/drcolorpicker-favorites-light.png");
        vc.rootViewController.hueImage = DRColorPickerImage(@"images/light/drcolorpicker-hue-v3-light.png");
        vc.rootViewController.wheelImage = DRColorPickerImage(@"images/light/drcolorpicker-wheel-light.png");
        //vc.rootViewController.importImage = DRColorPickerImage(@"images/light/drcolorpicker-import-light.png");
    }
    
    // assign a weak reference to the color picker, need this for UIImagePickerController delegate
    self.colorPickerVC = vc;
    
    // make an import block, this allows using images as colors, this import block uses the UIImagePickerController,
    // but in You Doodle for iOS, I have a more complex import that allows importing from many different sources
    // *** Leave this as nil to not allowing import of textures ***
    vc.rootViewController.importBlock = nil;
    
    // dismiss the color picker
    vc.rootViewController.dismissBlock = ^(BOOL cancel)
    {
        [self dismissViewControllerAnimated:YES completion:nil];
    };
    
    // a color was selected, do something with it, but do NOT dismiss the color picker, that happens in the dismissBlock
    vc.rootViewController.colorSelectedBlock = ^(DRColorPickerColor* color, DRColorPickerBaseViewController* vc)
    {
        self.color = color;
        if (color.rgbColor == nil)
        {
            self.view.backgroundColor = [UIColor colorWithPatternImage:color.image];
        }
        else
        {
            self.innerLabel.backgroundColor = color.rgbColor;
            self.color.alpha = 1.0;
            
            CGFloat floatR,floatG,floatB, a;
            [self.color.rgbColor getRed:&floatR green:&floatG blue: &floatB alpha: &a];
            
            int r = (int)(255.0 * floatR);
            int g = (int)(255.0 * floatG);
            int b = (int)(255.0 * floatB);
            
            NSString *string = [NSString stringWithFormat:@"%02x%02x%02x", r, g, b];
            NSLog(@"String: %@", string);
            [DataFramework sendColourToPebble:string :10 :@"spe-inner-colour" :[PebbleInfo getAppUUID:APP_TYPE_SPEEDOMETER]];
        }
    };
    
    // finally, present the color picker
    [self presentViewController:vc animated:YES completion:nil];
}

- (void) imagePickerController:(UIImagePickerController*)picker didFinishPickingMediaWithInfo:(NSDictionary*)info
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Not supported"
                                                    message:@"This feature is currently not supported, and will be fixed for a beta in the future."
                                                   delegate:nil
                                          cancelButtonTitle:@"Okay"
                                          otherButtonTitles:nil];
    [alert show];
    
    [self.colorPickerVC dismissViewControllerAnimated:YES completion:nil];
}

- (void) imagePickerControllerDidCancel:(UIImagePickerController*)picker
{
    // image picker cancel, just dismiss it
    [self.colorPickerVC dismissViewControllerAnimated:YES completion:nil];
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
