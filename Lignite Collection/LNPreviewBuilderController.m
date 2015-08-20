//
//  LNPreviewBuilderController.m
//  Lignite
//
//  Created by Edwin Finch on 8/16/15.
//  Copyright (c) 2015 Edwin Finch. All rights reserved.
//

#import "LNPreviewBuilderController.h"
#import "LNCommunicationLayer.h"
#import "LNAppInfo.h"

@interface LNPreviewBuilderController ()

@property enum PebbleModel model;
@property UIGestureRecognizer *pebbleSwipeLeftRecognizer, *pebbleSwipeRightRecognizer, *screenshotSwipeLeftRecognizer, *screenshotSwipeRightRecognizer;
@property NSMutableArray *basaltImageArray, *apliteImageArray;
@property int basaltLocation, apliteLocation;

@end

@implementation LNPreviewBuilderController

+ (NSArray*)pebbleModelNameArray {
    return [[NSArray alloc]initWithObjects:
            @"bianca-black", @"bianca-silver",
            @"bobby-black", @"bobby-gold", @"bobby-silver",
            @"snowy-black", @"snowy-red", @"snowy-white",
            @"tintin-black", @"tintin-red",@"tintin-white", nil];
}

+ (NSArray*)pebbleModelArray {
    return [[NSArray alloc]initWithObjects:
            @"bianca-black.png", @"bianca-silver.png",
            @"bobby-black.png", @"bobby-gold.png", @"bobby-silver.png",
            @"snowy-black.png", @"snowy-red.png", @"snowy-white.png",
            @"tintin-black.png", @"tintin-red.png", @"tintin-white.png", nil];
}

+ (UIImage*)imageForPebble:(UIImage*)pebble andScreenshot:(UIImage*)screenshot {
    CGSize size = [pebble size];
    UIGraphicsBeginImageContext(size);
    
    [pebble drawInRect:CGRectMake(0, 0, size.width,size.height)];
    
    [screenshot drawInRect:CGRectMake(66, 126, 144, 168)];
    
    UIImage *finalImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return finalImage;
}

+ (UIImage*)screenshotForPebble:(NSString*)pebble appType:(AppTypeCode)type index:(int)index {
    UIImage *image;

    NSString *imageName = [NSString stringWithFormat:@"%@-%@-%d.png", [PebbleInfo getAppNameFromType:type], [DataFramework pebbleImageIsTime:pebble] ? @"basalt" : @"aplite", index];
    image = [UIImage imageNamed:imageName];
    
    return image;
}

- (UIImage*)currentScreenshotImage {
    NSString *pebbleModel = [[LNPreviewBuilderController pebbleModelArray] objectAtIndex:self.model];
    return [LNPreviewBuilderController screenshotForPebble:pebbleModel appType:self.appType index:[DataFramework pebbleImageIsTime:pebbleModel] ? self.basaltLocation : self.apliteLocation];
}

- (UIImage*)currentPreviewImage {
    if(![DataFramework defaultPebbleImage]){
        self.model = PEBBLE_MODEL_SNOWY_BLACK;
        [DataFramework setDefaultPebbleImage:@"snowy-black.png"];
    }
    [self.sourceController updatePebblePreview];
    return [LNPreviewBuilderController imageForPebble:[UIImage imageNamed:[[LNPreviewBuilderController pebbleModelArray] objectAtIndex:self.model]] andScreenshot:[self currentScreenshotImage]];
}

- (void)switchPebblePreview:(BOOL)forward {
    forward ? self.model++ : self.model--;
    
    NSInteger arrayLength = [[LNPreviewBuilderController pebbleModelArray] count];
    if(self.model > arrayLength-1){
        self.model = 0;
    } else if(self.model < 0){
        self.model = (int)arrayLength-1;
    }
    
    UIImage *toImage = [self currentPreviewImage];
    [UIView transitionWithView:self.pebbleView
                      duration:0.4f
                       options:forward ? UIViewAnimationOptionTransitionCurlDown : UIViewAnimationOptionTransitionCurlUp
                    animations:^{
                        self.pebbleView.image = toImage;
                        self.defaultButton.enabled = ![[[LNPreviewBuilderController pebbleModelArray] objectAtIndex:self.model] isEqualToString:[DataFramework defaultPebbleImage]];
                    } completion:nil];
    self.pebbleLabel.text = NSLocalizedString([[LNPreviewBuilderController pebbleModelNameArray] objectAtIndex:self.model], nil);
    
    [UIView transitionWithView:self.screenshotView
                      duration:0.3f
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{
                        self.screenshotView.image = [self currentScreenshotImage];
                    } completion:nil];
}

- (void)switchScreenshotPreview:(BOOL)forward{
    if([DataFramework pebbleImageIsTime:[[LNPreviewBuilderController pebbleModelArray] objectAtIndex:self.model]]){
        forward ? self.basaltLocation++ : self.basaltLocation--;
        NSInteger arrayLength = [self.basaltImageArray count];
        if(self.basaltLocation > (int)arrayLength-1){
            self.basaltLocation = 1;
        } else if(self.basaltLocation < 1){
            self.basaltLocation = (int)arrayLength-1;
        }
    }
    else{
        forward ? self.apliteLocation++ : self.apliteLocation--;
        NSInteger arrayLength = [self.apliteImageArray count];
        if(self.apliteLocation > arrayLength-1){
            self.apliteLocation = 1;
        } else if(self.apliteLocation < 1){
            self.apliteLocation = (int)arrayLength-1;
        }
    }
    
    UIImage *toImage = [self currentPreviewImage];
    [UIView transitionWithView:self.screenshotView
                      duration:0.3f
                       options:forward ? UIViewAnimationOptionTransitionFlipFromRight : UIViewAnimationOptionTransitionFlipFromLeft
                    animations:^{
                        self.screenshotView.image = [self currentScreenshotImage];
                    } completion:nil];
    
    [UIView transitionWithView:self.pebbleView
                      duration:0.3f
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{
                        self.pebbleView.image = toImage;
                    } completion:nil];
}

- (IBAction)previewPebbleNext:(id)sender {
    UIButton *view = (UIButton*)sender;
    [self switchPebblePreview:(view == self.pebbleNextButton)];
}

- (IBAction)screenshotPreviewNext:(id)sender {
    UIButton *view = (UIButton*)sender;
    [self switchScreenshotPreview:(view == self.screenshotNextButton)];
}

- (IBAction)defaultButtonSet:(id)sender {
    self.defaultButton.enabled = NO;
    NSString *newDefault = [[LNPreviewBuilderController pebbleModelArray] objectAtIndex:self.model];
    [DataFramework setDefaultPebbleImage:newDefault];
    [self.sourceController updatePebblePreview];
}

- (void)previewPebbleNextGesture:(UISwipeGestureRecognizer*)recognizer {
    [self switchPebblePreview:[recognizer isEqual:self.pebbleSwipeLeftRecognizer]];
}

- (void)previewScreenshotNextGesture:(UISwipeGestureRecognizer*)recognizer {
    [self switchScreenshotPreview:[recognizer isEqual:self.screenshotSwipeLeftRecognizer]];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.basaltLocation = 1;
    self.apliteLocation = 1;
    
    UISwipeGestureRecognizer *fixedPebbleRecLeft = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(previewPebbleNextGesture:)];
    [fixedPebbleRecLeft setDirection:UISwipeGestureRecognizerDirectionDown];
    
    self.pebbleSwipeLeftRecognizer = fixedPebbleRecLeft;
    self.pebbleView.userInteractionEnabled = YES;
    [self.pebbleView addGestureRecognizer:self.pebbleSwipeLeftRecognizer];
    
    UISwipeGestureRecognizer *fixedPebbleRecRight = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(previewPebbleNextGesture:)];
    [fixedPebbleRecRight setDirection:UISwipeGestureRecognizerDirectionUp];
    
    self.pebbleSwipeRightRecognizer = fixedPebbleRecRight;
    [self.pebbleView addGestureRecognizer:self.pebbleSwipeRightRecognizer];
    
    UISwipeGestureRecognizer *fixedScreenshotRecLeft = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(previewScreenshotNextGesture:)];
    [fixedScreenshotRecLeft setDirection:UISwipeGestureRecognizerDirectionLeft];
    
    self.screenshotSwipeLeftRecognizer = fixedScreenshotRecLeft;
    self.screenshotView.userInteractionEnabled = YES;
    [self.screenshotView addGestureRecognizer:self.screenshotSwipeLeftRecognizer];
    
    UISwipeGestureRecognizer *fixedScreenshotRecRight = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(previewScreenshotNextGesture:)];
    [fixedScreenshotRecRight setDirection:UISwipeGestureRecognizerDirectionRight];
    
    self.screenshotSwipeRightRecognizer = fixedScreenshotRecRight;
    [self.screenshotView addGestureRecognizer:self.screenshotSwipeRightRecognizer];
    
    self.model = (int)[[LNPreviewBuilderController pebbleModelArray] indexOfObject:[DataFramework defaultPebbleImage]];
    self.defaultButton.enabled = NO;
    
    self.basaltImageArray = [[NSMutableArray alloc]init];
    self.apliteImageArray = [[NSMutableArray alloc]init];
    
    UIImage *basaltimage = [UIImage imageNamed:[NSString stringWithFormat:@"%@-basalt-1.png", [PebbleInfo getAppNameFromType:self.appType]]];
    NSInteger basaltCount = 1;
    
    while(basaltimage){
        if(basaltimage){
            [self.basaltImageArray addObject:basaltimage];
        }
        basaltimage = [UIImage imageNamed:[NSString stringWithFormat:@"%@-basalt-%ld.png", [PebbleInfo getAppNameFromType:self.appType], (long)basaltCount++]];
    }
    
    UIImage *apliteimage = [UIImage imageNamed:[NSString stringWithFormat:@"%@-aplite-1.png", [PebbleInfo getAppNameFromType:self.appType]]];
    NSInteger apliteCount = 1;
    
    while(apliteimage){
        if(apliteimage){
            [self.apliteImageArray addObject:apliteimage];
        }
        apliteimage = [UIImage imageNamed:[NSString stringWithFormat:@"%@-aplite-%ld.png", [PebbleInfo getAppNameFromType:self.appType], (long)apliteCount++]];
    }
    
    
    self.pebbleView.image = [self currentPreviewImage];
    self.pebbleLabel.text = NSLocalizedString([[LNPreviewBuilderController pebbleModelNameArray]objectAtIndex:[[LNPreviewBuilderController pebbleModelArray] indexOfObject:[DataFramework defaultPebbleImage]]], nil);
    self.screenshotView.image = [self currentScreenshotImage];
    
    self.title = NSLocalizedString(@"build_a_preview", nil);
    self.screenshotLabel.text = NSLocalizedString(@"screenshot", nil);
    [self.defaultButton setTitle:NSLocalizedString(@"set_as_default_pebble", nil) forState:UIControlStateNormal];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    NSLog(@"Got a fucking memory warning");
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
