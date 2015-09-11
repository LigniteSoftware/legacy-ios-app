//
//  LNPreviewBuilderController.m
//  Lignite
//
//  Created by Edwin Finch on 8/16/15.
//  Copyright (c) 2015 Edwin Finch. All rights reserved.
//

#import "LNPreviewBuilderController.h"
#import "LNDataFramework.h"
#import "LNAppInfo.h"

@interface LNPreviewBuilderController ()

@property enum PebbleModel model;
@property UIGestureRecognizer *pebbleSwipeLeftRecognizer, *pebbleSwipeRightRecognizer, *screenshotSwipeLeftRecognizer, *screenshotSwipeRightRecognizer;
@property NSMutableArray *basaltImageArray, *apliteImageArray;
@property int basaltLocation, apliteLocation;

//Tutorial shit
@property UIImageView *tutorialBackgroundImageView, *tutorialArrowImageView;
@property UIButton *tutorialButton, *skipButton;
@property UILabel *tutorialLabel;
@property NSInteger tutorialStage;

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
    
    [screenshot drawInRect:CGRectMake(65, 126, 144, 168)];
    
    UIImage *finalImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return finalImage;
}

+ (UIImage*)screenshotForPebble:(NSString*)pebble appType:(AppTypeCode)type index:(int)index {
    UIImage *image;

    NSString *imageName = [NSString stringWithFormat:@"%@-%@-%d.png", [LNAppInfo getAppNameFromType:type], [LNDataFramework pebbleImageIsTime:pebble] ? @"basalt" : @"aplite", index];
    image = [UIImage imageNamed:imageName];
    
    return image;
}

- (UIImage*)currentScreenshotImage {
    NSString *pebbleModel = [[LNPreviewBuilderController pebbleModelArray] objectAtIndex:self.model];
    return [LNPreviewBuilderController screenshotForPebble:pebbleModel appType:self.appType index:[LNDataFramework pebbleImageIsTime:pebbleModel] ? self.basaltLocation : self.apliteLocation];
}

- (UIImage*)currentPreviewImage {
    if(![LNDataFramework defaultPebbleImage] || self.model == -1){
        self.model = PEBBLE_MODEL_SNOWY_BLACK;
        [LNDataFramework setDefaultPebbleImage:@"snowy-black.png"];
    }
    [self.sourceController updatePebblePreview];
    return [LNPreviewBuilderController imageForPebble:[UIImage imageNamed:[[LNPreviewBuilderController pebbleModelArray] objectAtIndex:self.model]] andScreenshot:[self currentScreenshotImage]];
}

- (UIColor*)getDefaultColour {
	if([[[LNPreviewBuilderController pebbleModelArray] objectAtIndex:self.model] isEqualToString:[LNDataFramework defaultPebbleImage]]){
		return [UIColor lightGrayColor];
	}
	else{
		return [UIColor grayColor];
	}
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
                      duration:0.3f
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{
                        self.pebbleView.image = toImage;
						self.defaultButton.backgroundColor = [self getDefaultColour];
						self.defaultButton.layer.borderColor = self.defaultButton.backgroundColor.CGColor;
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
    if([LNDataFramework pebbleImageIsTime:[[LNPreviewBuilderController pebbleModelArray] objectAtIndex:self.model]]){
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
                       options:UIViewAnimationOptionTransitionCrossDissolve
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
    if(self.isTutorial){
        self.tutorialStage++;
        [self updateTutorial];
    }
    NSString *newDefault = [[LNPreviewBuilderController pebbleModelArray] objectAtIndex:self.model];
    [LNDataFramework setDefaultPebbleImage:newDefault];
    [self.sourceController updatePebblePreview];
	
	self.defaultButton.backgroundColor = [self getDefaultColour];
	self.defaultButton.layer.borderColor = self.defaultButton.backgroundColor.CGColor;
}

- (void)previewPebbleNextGesture:(UISwipeGestureRecognizer*)recognizer {
    [self switchPebblePreview:[recognizer isEqual:self.pebbleSwipeLeftRecognizer]];
}

- (void)previewScreenshotNextGesture:(UISwipeGestureRecognizer*)recognizer {
    [self switchScreenshotPreview:[recognizer isEqual:self.screenshotSwipeLeftRecognizer]];
}

- (void)updateTutorial {
	
	//[_label setAlpha:1.0f];
	
	//fade out
	[UIView animateWithDuration:0.3f animations:^{
		NSArray *views_array = [NSArray arrayWithObjects:self.screenshotView, self.screenshotLabel, self.screenshotNextButton, self.screenshotPreviousButton,
								self.pebbleView, self.pebbleLabel, self.pebbleNextButton, self.pebblePreviousButton, self.defaultButton,
								self.tutorialLabel, self.tutorialButton, self.skipButton, self.tutorialArrowImageView, nil];
		for(int i = 0; i < [views_array count]; i++){
			UIView *view = [views_array objectAtIndex:i];
			[view setAlpha:0.0f];
		}
		
	} completion:^(BOOL finished) {
		
		//fade in
		[UIView animateWithDuration:0.1f animations:^{
			
			CGRect label_frames[] = {
				CGRectMake(20, 20, self.tutorialBackgroundImageView.frame.size.width-40, self.screenshotView.frame.origin.y),
				CGRectMake(20, self.pebbleView.frame.size.height+self.pebbleView.frame.origin.y-15, self.view.frame.size.width-40, 100),
				CGRectMake(20, self.screenshotLabel.frame.origin.y, self.view.frame.size.width-40, 84),
				CGRectMake(20, self.pebbleView.frame.origin.y+self.pebbleView.frame.size.height/2 - 35, self.view.frame.size.width-40, 74)
			};
			int x_offset = self.view.frame.size.width/2-(self.view.frame.size.width/2 - 50)/2;
			CGRect button_frames[] = {
				CGRectMake(x_offset, self.screenshotView.frame.origin.y, self.view.frame.size.width/2 - 50, 32),
				CGRectMake(x_offset, self.screenshotView.frame.origin.y+self.screenshotView.frame.size.height/2 - 20, self.view.frame.size.width/2 - 50, 32),
				CGRectMake(x_offset, self.screenshotView.frame.origin.y+self.screenshotView.frame.size.height/2 - 20, self.view.frame.size.width/2 - 50, 32),
				CGRectMake(x_offset, self.view.frame.size.height/2 + 20, self.view.frame.size.width/2 - 50, 32)
			};
			CGRect skip_frames[] = {
				CGRectMake(x_offset, self.screenshotView.frame.origin.y + 40, self.view.frame.size.width/2 - 50, 32),
				CGRectMake(x_offset, self.screenshotView.frame.origin.y+self.screenshotView.frame.size.height/2 + 20, self.view.frame.size.width/2 - 50, 32),
				CGRectMake(x_offset, self.screenshotView.frame.origin.y+self.screenshotView.frame.size.height/2 + 20, self.view.frame.size.width/2 - 50, 32),
				CGRectMake(x_offset, self.view.frame.size.height/2 + 60, self.view.frame.size.width/2 - 50, 32),
			};
			CGRect arrow_frames[] = {
				CGRectMake(self.view.frame.size.width + 50, -100, self.view.frame.size.width-20, 100),
				CGRectMake(10, self.pebbleView.frame.origin.y+self.pebbleView.frame.size.height/2 - 20, self.view.frame.size.width - 20, 40),
				CGRectMake(self.pebblePreviousButton.frame.origin.x + 10, self.defaultButton.frame.origin.y-60, 50, 50),
				CGRectMake(10, self.screenshotView.frame.origin.y + self.screenshotView.frame.size.height/2 - 50, self.view.frame.size.width-20, 100),
			};
			NSString *button_keys[] = {
				@"show_me", @"nice", @"awesome", @"alright_thanks"
			};
			NSString *arrow_names[] = {
				@"double_arrows_up.png", @"double_arrows.png", @"arrow_down_thin.png", @"double_arrows.png"
			};
			
			uint8_t fixedIndex = self.tutorialStage == 4 ? 3 : self.tutorialStage;
			
			self.tutorialLabel.frame = label_frames[fixedIndex];
			NSString *key = [NSString stringWithFormat:@"tutorial_preview_%d", fixedIndex];
			self.tutorialLabel.text = NSLocalizedString(key, nil);
			
			self.tutorialButton.frame = button_frames[fixedIndex];
			[self.tutorialButton setTitle:NSLocalizedString(button_keys[fixedIndex], nil) forState:UIControlStateNormal];
			
			self.tutorialArrowImageView.frame = arrow_frames[fixedIndex];
			self.tutorialArrowImageView.image = [UIImage imageNamed:arrow_names[fixedIndex]];
			
			self.skipButton.frame = skip_frames[self.tutorialStage];
			
			self.tutorialBackgroundImageView.userInteractionEnabled = YES;
			//self.sourceController.pageViewController.dataSource = nil;
			if([[self.tutorialBackgroundImageView subviews] containsObject:self.pebbleView] && self.tutorialStage != 1){
				[self.pebbleView removeFromSuperview];
				[self.view addSubview:self.pebbleView];
			}
			if([[self.tutorialBackgroundImageView subviews] containsObject:self.defaultButton] && self.tutorialStage != 2){
				[self.defaultButton removeFromSuperview];
				[self.view addSubview:self.defaultButton];
			}
			if([[self.tutorialBackgroundImageView subviews] containsObject:self.screenshotView] && self.tutorialStage != 3){
				[self.screenshotView removeFromSuperview];
				[self.view addSubview:self.screenshotView];
			}
			
			[self.tutorialBackgroundImageView removeFromSuperview];
			[self.view addSubview:self.tutorialBackgroundImageView];
			
			switch(self.tutorialStage){
				case 2:
					self.defaultButton.enabled = YES;
					[self.tutorialBackgroundImageView addSubview:self.defaultButton];
				case 1:
					[self.tutorialBackgroundImageView addSubview:self.pebbleView];
					break;
				case 3:
					[self.tutorialBackgroundImageView addSubview:self.screenshotView];
					break;
				case 4:
					[self dismissViewControllerAnimated:YES completion:nil];
					break;
			}

			
		} completion:^(BOOL finished) {
			
			//fade in
			[UIView animateWithDuration:0.3f animations:^{
				
				NSArray *views_array = [NSArray arrayWithObjects:self.screenshotView, self.screenshotLabel, self.screenshotNextButton, self.screenshotPreviousButton,
										self.pebbleView, self.pebbleLabel, self.pebbleNextButton, self.pebblePreviousButton, self.defaultButton,
										self.tutorialLabel, self.tutorialButton, self.tutorialArrowImageView, self.skipButton, nil];
				for(int i = 0; i < [views_array count]; i++){
					UIView *view = [views_array objectAtIndex:i];
					[view setAlpha:1.0f];
				}
				
			} completion:nil];
		}];}];
}

- (IBAction)tutorialNext:(id)sender {
    self.tutorialStage++;
    [self updateTutorial];
}

- (IBAction)tutorialEnd:(id)sender {
	self.tutorialStage = 4;
	[self updateTutorial];
	
	[[self sourceController] tutorialEnd:self];
}

- (void)fireTutorial {
    self.tutorialBackgroundImageView = [[UIImageView alloc] initWithFrame:self.view.frame];
    [self.tutorialBackgroundImageView setImage:[UIImage imageNamed:@"tutorial_background.png"]];
    
    self.tutorialArrowImageView = [[UIImageView alloc]initWithFrame:CGRectMake(10, -100, self.view.frame.size.width-20, 100)];
    self.tutorialArrowImageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.tutorialBackgroundImageView addSubview:self.tutorialArrowImageView];
    
    self.tutorialLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, -30, 150, 300)];
    self.tutorialLabel.text = NSLocalizedString(@"tutorial_logout", nil);
    self.tutorialLabel.numberOfLines = 0;
    self.tutorialLabel.lineBreakMode = NSLineBreakByWordWrapping;
	NSLog(@"Height %f", self.view.frame.size.height);
	if(self.view.frame.size.height > 480){
		self.tutorialLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:18.0f];
	}
	else{
		self.tutorialLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:14.0f];
	}
    self.tutorialLabel.textAlignment = NSTextAlignmentCenter;
    [self.tutorialBackgroundImageView addSubview:self.tutorialLabel];
    
    self.tutorialButton = [[UIButton alloc]initWithFrame:CGRectMake(-self.view.frame.size.width, self.view.frame.size.height/1.6-75, 150, 150)];
    [self.tutorialButton setTitle:NSLocalizedString(@"ok_got_it", nil) forState:UIControlStateNormal];
    [self.tutorialButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.tutorialButton addTarget:self action:@selector(tutorialNext:) forControlEvents:UIControlEventTouchUpInside];
	self.tutorialButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:14.0f];
    self.tutorialButton.userInteractionEnabled = YES;
	self.tutorialButton.backgroundColor = [UIColor grayColor];
	self.tutorialButton.titleLabel.textColor = [UIColor whiteColor];
	self.tutorialButton.layer.masksToBounds = YES;
	self.tutorialButton.layer.borderWidth = 1.0;
	self.tutorialButton.layer.borderColor = self.tutorialButton.backgroundColor.CGColor;
	self.tutorialButton.layer.cornerRadius = 5.0;
    [self.tutorialBackgroundImageView addSubview:self.tutorialButton];
	
	self.skipButton = [[UIButton alloc]initWithFrame:CGRectMake(self.view.frame.size.width/2-75, self.view.frame.size.height/1.6-75, 150, 150)];
	[self.skipButton setTitle:NSLocalizedString(@"end_tutorial", nil) forState:UIControlStateNormal];
	[self.skipButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	[self.skipButton setBackgroundColor:[UIColor colorWithRed:0.81 green:0.81 blue:0.81 alpha:1.0]];
	[self.skipButton addTarget:self action:@selector(tutorialEnd:) forControlEvents:UIControlEventTouchUpInside];
	self.skipButton.userInteractionEnabled = YES;
	self.skipButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:14.0f];
	self.skipButton.userInteractionEnabled = YES;
	self.skipButton.layer.masksToBounds = YES;
	self.skipButton.layer.borderWidth = 1.0;
	self.skipButton.layer.borderColor = self.skipButton.backgroundColor.CGColor;
	self.skipButton.layer.cornerRadius = 5.0;
     [self.tutorialBackgroundImageView addSubview:self.skipButton];
    
    self.tutorialBackgroundImageView.userInteractionEnabled = YES;
    
    [self.view addSubview:self.tutorialBackgroundImageView];
    
    [self updateTutorial];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.pebbleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 70, self.view.frame.size.width, 34)];
    self.pebbleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:22.0f];
    self.pebbleLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:self.pebbleLabel];
    
    self.pebbleView = [[UIImageView alloc]initWithFrame:CGRectMake(40, self.pebbleLabel.frame.origin.y+self.pebbleLabel.frame.size.height, self.view.frame.size.width-80, self.view.frame.size.height/2.4)];
    self.pebbleView.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:self.pebbleView];
	
	self.pebbleNextButton = [[UIButton alloc]initWithFrame:CGRectMake(self.view.frame.size.width - 46, self.pebbleView.frame.origin.y + self.pebbleView.frame.size.height/2 - 8, 16, 16)];
	[self.pebbleNextButton setImage:[UIImage imageNamed:@"arrow-active-right.png"] forState:UIControlStateNormal];
	[self.view addSubview:self.pebbleNextButton];
	
	self.pebblePreviousButton = [[UIButton alloc]initWithFrame:CGRectMake(46, self.pebbleView.frame.origin.y + self.pebbleView.frame.size.height/2 - 8, 16, 16)];
	[self.pebblePreviousButton setImage:[UIImage imageNamed:@"arrow-active"] forState:UIControlStateNormal];
	[self.view addSubview:self.pebblePreviousButton];
    
    self.defaultButton = [[UIButton alloc]initWithFrame:CGRectMake(self.view.frame.size.width/2 - 100, self.pebbleView.frame.origin.y+self.pebbleView.frame.size.height, 200, 26)];
    [self.defaultButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.defaultButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:14.0f];
    [self.defaultButton addTarget:self action:@selector(defaultButtonSet:) forControlEvents:UIControlEventTouchUpInside];
	[self.defaultButton setBackgroundColor:[UIColor grayColor]];
	self.defaultButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:14.0f];
	self.defaultButton.userInteractionEnabled = YES;
	self.defaultButton.layer.masksToBounds = YES;
	self.defaultButton.layer.borderWidth = 1.0;
	self.defaultButton.layer.borderColor = self.defaultButton.backgroundColor.CGColor;
	self.defaultButton.layer.cornerRadius = 5.0;
    [self.view addSubview:self.defaultButton];
    
    self.screenshotLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, self.defaultButton.frame.origin.y+self.defaultButton.frame.size.height, self.view.frame.size.width, 34)];
    self.screenshotLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:22.0f];
    self.screenshotLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:self.screenshotLabel];
    
    int yposscreenshot = self.screenshotLabel.frame.origin.y+self.screenshotLabel.frame.size.height+10;
    self.screenshotView = [[UIImageView alloc]initWithFrame:CGRectMake(50, yposscreenshot, self.view.frame.size.width-100, self.view.frame.size.height-yposscreenshot-20)];
    self.screenshotView.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:self.screenshotView];
    
    self.screenshotNextButton = [[UIButton alloc]initWithFrame:CGRectMake(46, self.screenshotView.frame.origin.y+self.screenshotView.frame.size.height/2 - 8, 16, 16)];
    [self.screenshotNextButton setImage:[UIImage imageNamed:@"arrow-active.png"] forState:UIControlStateNormal];
    [self.view addSubview:self.screenshotNextButton];
    
    self.screenshotPreviousButton = [[UIButton alloc]initWithFrame:CGRectMake(self.view.frame.size.width-30-16, self.screenshotView.frame.origin.y+self.screenshotView.frame.size.height/2 - 8, 16, 16)];
    [self.screenshotPreviousButton setImage:[UIImage imageNamed:@"arrow-active-right.png"] forState:UIControlStateNormal];
    [self.view addSubview:self.screenshotPreviousButton];
    
    self.basaltLocation = 1;
    self.apliteLocation = 1;
    
    UISwipeGestureRecognizer *fixedPebbleRecLeft = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(previewPebbleNextGesture:)];
	[fixedPebbleRecLeft setDirection:UISwipeGestureRecognizerDirectionLeft];
	
    self.pebbleSwipeLeftRecognizer = fixedPebbleRecLeft;
    self.pebbleView.userInteractionEnabled = YES;
    [self.pebbleView addGestureRecognizer:self.pebbleSwipeLeftRecognizer];
    
    UISwipeGestureRecognizer *fixedPebbleRecRight = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(previewPebbleNextGesture:)];
    [fixedPebbleRecRight setDirection:UISwipeGestureRecognizerDirectionRight];
    
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
    
    self.model = (int)[[LNPreviewBuilderController pebbleModelArray] indexOfObject:[LNDataFramework defaultPebbleImage]];
	if(self.model > 9 || self.model < 0){
		self.model = PEBBLE_MODEL_SNOWY_BLACK;
	}
	self.defaultButton.backgroundColor = [self getDefaultColour];
	self.defaultButton.layer.borderColor = self.defaultButton.backgroundColor.CGColor;
	
    self.basaltImageArray = [[NSMutableArray alloc]init];
    self.apliteImageArray = [[NSMutableArray alloc]init];
    
    UIImage *basaltimage = [UIImage imageNamed:[NSString stringWithFormat:@"%@-basalt-1.png", [LNAppInfo getAppNameFromType:self.appType]]];
    NSInteger basaltCount = 1;
    
    while(basaltimage){
        if(basaltimage){
            [self.basaltImageArray addObject:basaltimage];
        }
        basaltimage = [UIImage imageNamed:[NSString stringWithFormat:@"%@-basalt-%ld.png", [LNAppInfo getAppNameFromType:self.appType], (long)basaltCount++]];
    }
    
    UIImage *apliteimage = [UIImage imageNamed:[NSString stringWithFormat:@"%@-aplite-1.png", [LNAppInfo getAppNameFromType:self.appType]]];
    NSInteger apliteCount = 1;
    
    while(apliteimage){
        if(apliteimage){
            [self.apliteImageArray addObject:apliteimage];
        }
        apliteimage = [UIImage imageNamed:[NSString stringWithFormat:@"%@-aplite-%ld.png", [LNAppInfo getAppNameFromType:self.appType], (long)apliteCount++]];
    }
    
    
    self.pebbleView.image = [self currentPreviewImage];
    self.pebbleLabel.text = NSLocalizedString([[LNPreviewBuilderController pebbleModelNameArray]objectAtIndex:[[LNPreviewBuilderController pebbleModelArray] indexOfObject:[LNDataFramework defaultPebbleImage]]], nil);
    self.screenshotView.image = [self currentScreenshotImage];
    
    self.title = NSLocalizedString(@"build_a_preview", nil);
    self.screenshotLabel.text = NSLocalizedString(@"screenshot", nil);
    [self.defaultButton setTitle:NSLocalizedString(@"set_as_default_pebble", nil) forState:UIControlStateNormal];
    
    if(self.isTutorial){
        [self fireTutorial];
    }
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
