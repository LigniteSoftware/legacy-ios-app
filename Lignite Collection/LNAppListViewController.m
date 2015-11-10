//
//  LNAppListViewController.m
//  Lignite
//
//  Created by Edwin Finch on 8/18/15.
//  Copyright (c) 2015 Edwin Finch. All rights reserved.
//

#import "LNAppListViewController.h"
#import <PebbleKit/PebbleKit.h>
#import "NSUserDefaults+MPSecureUserDefaults.h"
#import "LoginViewController.h"
#import "UIView+Toast.h"
#import "LNDataFramework.h"
#import "CreditsViewController.h"
#import "FeedbackViewController.h"
#import "LNSettingsViewController.h"
#import "LNPreviewBuilder.h"
#import "LNColourPicker.h"
#import "SimpleTableViewController.h"
#import "LNPebbleViewController.h"

@interface LNAppListViewController () <SimpleTableViewControllerDelegate, PBPebbleCentralDelegate>

@property UIButton *button;
@property UIAlertView *watchAppAlertView;
@property (strong) UIDocumentInteractionController *uidocumentInteractionController;
@property NSArray* appArray;
@property NSData *response1;
@property UITapGestureRecognizer *imageTapRecognizer;
@property BOOL usingTimeImage;
@property NSURLConnection *logoutConnection, *verifyConnection;
@property PBWatch *currentWatch;

@property UIAlertView *backerAlert;

@property NSMutableArray *screenshotItems;
@property int currentScreenshotLocation;

@end

@implementation LNAppListViewController

//#define BUILD 64

- (IBAction)installApp:(id)sender {
	NSDictionary *settings = [LNDataFramework getSettingsDictionaryForWatchApp:LIGNITE_SETTINGS];
	
	if([[settings objectForKey:@"general-pebble_app_to_open"] integerValue] == 0){
		self.watchAppAlertView = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"what_pebble_app", nil)
														   message:NSLocalizedString(@"what_pebble_app_description", nil)
														   delegate:self
												           cancelButtonTitle:NSLocalizedString(@"cancel", nil)
												           otherButtonTitles:NSLocalizedString(@"manage_settings", nil),
																			 NSLocalizedString(@"pebble_app_original", nil),
																			 NSLocalizedString(@"pebble_app_time", nil), nil];
		[self.watchAppAlertView show];
	}
	else{
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@://appstore/%@", [[settings objectForKey:@"general-pebble_app_to_open"] integerValue] == 1 ? @"pebble-2" : @"pebble-3", self.watchApp.appstoreLocation]]];
	}
	
    /*
     * RIP in pepperoni 1.2.1 feature u will b missed <3 ;(((
     *
     NSURL *pbwUrl = [[NSBundle mainBundle] URLForResource:[PebbleInfo getAppNameFromType:self.watchApp] withExtension:@"pbw"];
     self.uidocumentInteractionController = [UIDocumentInteractionController interactionControllerWithURL:pbwUrl];
     self.uidocumentInteractionController.UTI = @"com.getpebble.bundle.watchface";
     self.uidocumentInteractionController.delegate = self;
     
     // presentOptionsMenu works all the time
     //[self.uidocumentInteractionController presentOptionsMenuFromRect:self.view.frame inView:self.view animated:YES];
     
     // presentOpenInMenu is better (only shows compatible apps) but only works
     // if the Pebble app is installed (so not in the simulator)
     [self.uidocumentInteractionController presentOpenInMenuFromRect:self.view.frame inView:self.view animated:YES];
     */
}

- (IBAction)logoutButtonPushed:(id)sender {
    if([LNDataFramework isUserBacker]){
        [self.view makeToast:NSLocalizedString(@"logging_out", "logging the user out...")];
        
        
        NSString *post = [NSString stringWithFormat:@"username=%@&currentDevice=%@&accessToken=%@", [LNDataFramework getUsername], [LNDataFramework getCurrentDevice], [LNDataFramework getUserToken]];
        
        NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
        
        NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[postData length]];
        
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
        [request setURL:[NSURL URLWithString:@"https://api.lignite.me/v2/logout/index.php"]];
        [request setHTTPMethod:@"POST"];
        [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
        [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
        [request setHTTPBody:postData];
        
        self.logoutConnection = [[NSURLConnection alloc]initWithRequest:request delegate:self];
        [self.logoutConnection start];
    }
    else{
        [self.view makeToast:NSLocalizedString(@"restoring_purchases", "for restoring purchases")];
        [(LNAppListController*)self.sourceViewController restorePurchases];
    }
}

- (IBAction)settingsButtonPushed:(id)sender {
    if(!self.owns_app){
		[(LNAppListController*)self.sourceViewController purchaseApp:self.watchApp];
		return;
    }
	if(!self.connectedWatch){
		NSLog(@"No connected watch, hoping to find and use the last connected watch.");
		self.connectedWatch = [PBPebbleCentral defaultCentral].lastConnectedWatch;
	}
		NSUUID *uuid = [[NSUUID alloc]initWithUUIDString:self.watchApp.uuidString];
		//[[PBPebbleCentral defaultCentral] setAppUUID:uuid];
		
		[self.connectedWatch appMessagesLaunch:^(PBWatch *watch, NSError *error) {
		  if (!error) {
			  NSLog(@"Successfully launched app %@", uuid);
		  } else {
			  NSLog(@"Error launching app - Error: %@", error);
		  }
		} withUUID:uuid];
	/*
	}
	else{
		NSLog(@"No connected watch!");
	}
	 */
	LNSettingsViewController *view_controller = [[LNSettingsViewController alloc]initWithStyle:UITableViewStyleGrouped forWatchApp:self.watchApp];
	[self showViewController:view_controller sender:self];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    if(connection == self.logoutConnection){
        NSLog(@"Error %@", [error localizedDescription]);
        NSString *failedDescription = [[NSString alloc]initWithFormat:NSLocalizedString(@"failed_to_logout", nil), [error localizedDescription]];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"failed", nil)
                                                        message:failedDescription
                                                       delegate:nil
                                              cancelButtonTitle:NSLocalizedString(@"okay", nil)
                                              otherButtonTitles:nil];
        [alert show];
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
    NSError *error;
    NSDictionary *jsonResult = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
    NSNumber *status = [jsonResult objectForKey:@"status"];
    if(connection == self.logoutConnection){
        if([status isEqual:@200] || [status isEqual:@404]){
			[LNDataFramework setUserBacker:NO];
			[LNDataFramework setUserLoggedIn:nil :NO];
            LoginViewController *loginScreen = [self.storyboard instantiateViewControllerWithIdentifier:@"LoginScreen"];
            [self presentViewController:loginScreen animated:YES completion:nil];
        }
        else{
            NSString *localizedError = [jsonResult objectForKey:@"localized_message"];
            NSString *failedDescription = [[NSString alloc]initWithFormat:NSLocalizedString(@"failed_to_logout", nil), localizedError];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"failed", nil)
                                                            message:failedDescription
                                                           delegate:nil
                                                  cancelButtonTitle:NSLocalizedString(@"okay", nil)
                                                  otherButtonTitles:nil];
            [alert show];
        }
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
	if(alertView == self.watchAppAlertView){
		switch(buttonIndex){
			case 2:
				[[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"pebble-2://appstore/%@", self.watchApp.appstoreLocation]]];
				break;
			case 3:
				[[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"pebble-3://appstore/%@", self.watchApp.appstoreLocation]]];
				break;
			case 1:;
				LNSettingsViewController *alertsController = [[LNSettingsViewController alloc]initWithStyle:UITableViewStyleGrouped];
				[alertsController setAsAlertSettings];
				[self showViewController:alertsController sender:self];
				break;
		}
	}
	/*
	else if(alertView == self.tutorialAlert){
		if(0 == buttonIndex){ //cancel button
			[alertView dismissWithClickedButtonIndex:buttonIndex animated:YES];
			NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
			BOOL answeredResult = [defaults boolForKey:@"key-ANSWERED"];
			
			if(!answeredResult){
				self.backerAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"hello_there", nil)
															  message:NSLocalizedString(@"are_you_a_backer", nil)
															 delegate:self
													cancelButtonTitle:NSLocalizedString(@"no", nil)
													otherButtonTitles:NSLocalizedString(@"yes", nil), nil];
				//[self.backerAlert show];
				[LNDataFramework userAnsweredBackerQuestion:YES];
				[LNDataFramework setupDefaults];
			}
		}
		else if (1 == buttonIndex){
			[self safeFireTutorial];
		}
	}
	 */
	else{
		if(0 == buttonIndex){ //cancel button
			[alertView dismissWithClickedButtonIndex:buttonIndex animated:YES];
		}
		else if (1 == buttonIndex){
			LoginViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"LoginScreen"];
			[self presentViewController:controller animated:YES completion:nil];
		}
	}
}

- (void)itemSelectedatRow:(NSInteger)row {
    self.watchApp.watchApp = (WatchApp)row;
    [self updateContentBasedOnType];
}

- (void)setScrollingEnabled:(BOOL)scrolling {
	for (UIScrollView *view in self.sourcePageViewController.view.subviews) {
		if ([view isKindOfClass:[UIScrollView class]]) {
			view.scrollEnabled = scrolling;
		}
	}
}

-(BOOL)prefersStatusBarHidden{
	return NO;
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewDidAppear:animated];
}

- (void)updateScreenshot:(BOOL)forward {
	!forward ? self.currentScreenshotLocation++ : self.currentScreenshotLocation--;
	if(self.currentScreenshotLocation > [self.screenshotItems count]){
		self.currentScreenshotLocation = 1;
	}
	else if(self.currentScreenshotLocation < 1){
		self.currentScreenshotLocation = (int)[self.screenshotItems count];
	}
	NSLog(@"Current screenshot loc %d", self.currentScreenshotLocation);
	
	[UIView transitionWithView:self.imageView
					  duration:0.4f
					   options:UIViewAnimationOptionTransitionCrossDissolve
					animations:^{
						self.imageView.image = [LNPreviewBuilder imageForPebble:[LNPreviewBuilder defaultPebble] andScreenshot:[self.screenshotItems objectAtIndex:self.currentScreenshotLocation-1] markAsPurchased:NO];
					} completion:nil];
}

- (void)screenshotSwipeLeft {
	[self updateScreenshot:NO];
}

- (void)screenshotSwipeRight {
	[self updateScreenshot:YES];
}

//Load the view
- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.view.layer.masksToBounds = YES;
	self.view.layer.cornerRadius = 8.0f;
	
	self.screenshotItems = [[NSMutableArray alloc]init];
	
	UIImage *screenshotImage = [UIImage imageNamed:[NSString stringWithFormat:@"%@-%@-1.png", self.watchApp.appName, [LNPreviewBuilder defaultPebble].platformName]];
	NSInteger screenshotCount = 1;
	
	while(screenshotImage){
		if(screenshotImage){
			NSLog(@"Found.");
			[self.screenshotItems addObject:screenshotImage];
		}
		screenshotCount++;
		NSString *imageName = [NSString stringWithFormat:@"%@-%@-%ld.png", self.watchApp.appName, [LNPreviewBuilder defaultPebble].platformName, (long)screenshotCount];
		NSLog(@"Searching for imagename %@", imageName);
		screenshotImage = [UIImage imageNamed:imageName];
	}
	NSLog(@"Found %ld screenshots for app %@", (long)[self.screenshotItems count], self.watchApp.appName);
	
	self.currentScreenshotLocation = 1;
	
	//[PBPebbleCentral setLogLevel:PBPebbleKitLogLevelAll];
	
	int viewFrameXAdjust = 30;
	self.view.frame = CGRectMake(viewFrameXAdjust, 0, self.view.frame.size.width-(viewFrameXAdjust*2), self.view.frame.size.height-80);
	
	srand((uint32_t)time(NULL));
	
    CGRect viewFrame = self.view.frame;
	
	self.imageView = [[UIImageView alloc]initWithFrame:CGRectMake(60, 10, viewFrame.size.width-120, (viewFrame.size.height/4)*2.3 - 80)];
	self.imageView.contentMode = UIViewContentModeScaleAspectFit;
	self.imageView.userInteractionEnabled = YES;
	[self.view addSubview:self.imageView];
	
	UISwipeGestureRecognizer *screenshotSwipeLeftRecognizer = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(screenshotSwipeLeft)];
	[screenshotSwipeLeftRecognizer setDirection:UISwipeGestureRecognizerDirectionLeft];
	UISwipeGestureRecognizer *screenshotSwipeRightRecognizer = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(screenshotSwipeRight)];
	[screenshotSwipeRightRecognizer setDirection:UISwipeGestureRecognizerDirectionRight];
	[self.imageView addGestureRecognizer:screenshotSwipeLeftRecognizer];
	[self.imageView addGestureRecognizer:screenshotSwipeRightRecognizer];
	
    self.appTitleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, self.imageView.frame.origin.y+self.imageView.frame.size.height, viewFrame.size.width, 40)];
    self.appTitleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:28.0f];
    self.appTitleLabel.text = @"App Title";
    self.appTitleLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:self.appTitleLabel];
	
    self.installButton = [[UIButton alloc]initWithFrame:CGRectMake(viewFrame.size.width/2 - 54, viewFrame.size.height - 136, 52, 52)];
    [self.installButton setImage:[UIImage imageNamed:@"install-button.png"] forState:UIControlStateNormal];
    [self.installButton addTarget:self action:@selector(installApp:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.installButton];
    
    self.settingsButton = [[UIButton alloc]initWithFrame:CGRectMake(viewFrame.size.width/2 + 6, viewFrame.size.height - 136, 52, 52)];
    [self.settingsButton setImage:[UIImage imageNamed:@"settings-button.png"] forState:UIControlStateNormal];
    [self.settingsButton addTarget:self action:@selector(settingsButtonPushed:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.settingsButton];

	int appDescriptionOriginY = self.appTitleLabel.frame.origin.y+self.appTitleLabel.frame.size.height+10;
	self.appDescriptionLabel = [[UITextView alloc]initWithFrame:CGRectMake(20, appDescriptionOriginY, viewFrame.size.width-40, self.settingsButton.frame.origin.y-appDescriptionOriginY-10)];
	self.appDescriptionLabel.editable = NO;
	self.appDescriptionLabel.backgroundColor = [UIColor clearColor];
	self.appDescriptionLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:18.0f];
	[self.view addSubview:self.appDescriptionLabel];
    
    [NSUserDefaults setSecret:@"XqcOyp_yl2U"];
    
    if([LNDataFramework getUsername].length != 6 || ![LNDataFramework getUsername]){
        [LNDataFramework setUserBacker:NO];
    }
    

	
	self.owns_app = [LNAppListController userOwnsApp:self.watchApp];
	NSLog(@"Owns %@: %@", self.watchApp.appName, self.owns_app ? @"yes" : @"no");
	if(self.owns_app){
		[self.settingsButton setImage:[UIImage imageNamed:@"settings-button.png"] forState:UIControlStateNormal];
	}
	
#ifdef BUILD
    if(![LNDataFramework isUserLoggedIn]){
		self.owns_app = true;
		NSLog(@"Skipping purchases (%d)", self.watchApp.watchApp);
        UILabel *skipping = [[UILabel alloc]initWithFrame:CGRectMake(20, 0, self.view.frame.size.width-40, 200)];
        skipping.textAlignment = NSTextAlignmentCenter;
        skipping.numberOfLines = 0;
        skipping.text = [NSString stringWithFormat:@"Build %d %p", BUILD, skipping];
        skipping.textColor = [UIColor colorWithRed:255 green:0 blue:0 alpha:50];
        [self.view addSubview:skipping];
    }
#endif
	/*
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	
	BOOL tutorialResult = [defaults boolForKey:@"key-TUTORIAL"];
	if(!tutorialResult){
		self.tutorialAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"tutorial", nil)
														message:NSLocalizedString(@"would_you_like_tutorial", nil)
													   delegate:self
											  cancelButtonTitle:NSLocalizedString(@"no", nil)
											  otherButtonTitles:NSLocalizedString(@"yes", nil), nil];
		//[self.tutorialAlert show];
		[defaults setBool:YES forKey:@"key-TUTORIAL"];
		[defaults synchronize];
	}
	 */
	
    self.leftArrow = [[UIImageView alloc]initWithFrame:CGRectMake(24, self.imageView.frame.origin.y+self.imageView.frame.size.height/2.2, 10, 10)];
	[self.leftArrow setImage:[UIImage imageNamed:@"arrow-active.png"]];
	if([self.screenshotItems count] < 2){
		[self.leftArrow setImage:[UIImage imageNamed:@"arrow-inactive.png"]];
	}
    [self.view addSubview:self.leftArrow];
    
    self.rightArrow = [[UIImageView alloc]initWithFrame:CGRectMake(self.view.frame.size.width - 40, self.imageView.frame.origin.y+self.imageView.frame.size.height/2.2, 10, 10)];
	[self.rightArrow setImage:[UIImage imageNamed:@"arrow-active-right.png"]];
	if([self.screenshotItems count] < 2){
		[self.rightArrow setImage:[UIImage imageNamed:@"arrow-inactive-right.png"]];
	}
    [self.view addSubview:self.rightArrow];
    
    
    /*
     LNSettingsViewController *view_controller = [[LNSettingsViewController alloc]initWithStyle:UITableViewStyleGrouped];
     [view_controller setwatchApp:APP_TYPE_SPEEDOMETER];
     [self showViewController:view_controller sender:self];
     
     LNColourPicker *colour_picker = [[LNColourPicker alloc]init];
     [self showViewController:colour_picker sender:self];
     
    self.navigationController.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(actionButtonPushed:)];
    self.navigationController.title = @"Lignite";
    self.navigationController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"Hello" style:UIBarButtonItemStyleDone target:self action:@selector(actionButtonPushed:)];
    */
    
    if(self.watchApp.watchApp == WATCH_APP_TIMEDOCK){
        self.owns_app = YES;
    }
    
    [self updateContentBasedOnType];
	
	UIDevice *device = [UIDevice currentDevice];
	[device setBatteryMonitoringEnabled:YES];
	//NSLog(@"Battery level: %f", [device batteryLevel]*100);
}

- (void)updatePebblePreview {
	LNPebbleWatch *pebbleWatch = [[LNPebbleWatch alloc] initWithModelIndex:(int)[LNPreviewBuilder defaultPebbleWatch]];
	UIImage *toImage = [LNPreviewBuilder imageForPebble:pebbleWatch andScreenshot:[UIImage imageNamed:[NSString stringWithFormat:@"%@-%@-1.png", self.watchApp.appName, pebbleWatch.platformName]] markAsPurchased:NO];
	if(toImage == nil){
		NSLog(@"is nil mate");
		toImage = [LNPreviewBuilder imageForPebble:[[LNPebbleWatch alloc] initWithModelIndex:PEBBLE_MODEL_SNOWY_BLACK] andScreenshot:[UIImage imageNamed:[NSString stringWithFormat:@"%@-%@-1.png", self.watchApp.appName, pebbleWatch.platformName]] markAsPurchased:NO];
		[LNPreviewBuilder setDefaultPebbleWatch:[[LNPebbleWatch alloc]initWithModelIndex:PEBBLE_MODEL_SNOWY_BLACK]];
		[self updatePebblePreview];
		return;
	}
    self.imageView.image = toImage;
}

- (IBAction)fireTimer:(id)sender {
    NSLog(@"Response of %@", self.response1);
}

- (void)updateContentBasedOnType {
    self.appTitleLabel.text = self.watchApp.localizedName;
    [self updatePebblePreview];
    self.appDescriptionLabel.text = self.watchApp.localizedDescription;
    self.appDescriptionLabel.font = [UIFont fontWithName:@"helvetica neue" size:14.0];
    if(!self.owns_app){
        [self.settingsButton setImage:[UIImage imageNamed:@"purchase-button.png"] forState:UIControlStateNormal];
    }
    else{
        [self.settingsButton setImage:[UIImage imageNamed:@"settings-button.png"] forState:UIControlStateNormal];
    }
}

/*
- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    NSLog(@"got key path %@", keyPath);
    if ([keyPath isEqual:@"tutorialStage"]) {
        NSLog(@"updating tutorial");
        [self updateTutorial];
    }
}


- (IBAction)leftButtonPush:(id)sender {
    [self swipeRight];
}

- (IBAction)rightButtonPush:(id)sender {
    [self swipeLeft];
}

- (void)swipeRightRecognizer:(UIGestureRecognizer*)rec {
    [self swipeRight];
}

- (void)swipeLeftRecognizer:(UIGestureRecognizer*)rec {
    [self swipeLeft];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

/**
 * Lol
 * New low
 *
 
 - (void)fireBigList:(UISwipeGestureRecognizer*)recognizer{
 UIStoryboard *storybord = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
 
 UINavigationController *navigationController = (UINavigationController *)[storybord instantiateViewControllerWithIdentifier:@"SimpleTableVC"];
 SimpleTableViewController *tableViewController = (SimpleTableViewController *)[[navigationController viewControllers] objectAtIndex:0];
 
 NSArray *array = [LNAppInfo  nameArray];
 NSMutableArray *fixedArray = [[NSMutableArray alloc]init];
 for(int i = 0; i < [array count]; i++){
 [fixedArray insertObject:[[array objectAtIndex:i] capitalizedString] atIndex:i];
 }
 
 tableViewController.tableData = fixedArray;
 tableViewController.navigationItem.title = NSLocalizedString(@"pick_an_app", nil);
 tableViewController.delegate = self;
 
 [self presentViewController:navigationController animated:YES completion:nil];
 
 }
 
 
 
 bool timezone_debug = true;
 
 - (void)handleUpdate:(NSDictionary*)update {
	
	NSString *transcription = [[update objectForKey:@(0)] lowercaseString];
	if([transcription containsString:@"what's the time in"]){
 NSString *area = [transcription stringByReplacingOccurrencesOfString:@"what's the time in " withString:@""];
 NSString *name = [NSString stringWithFormat:@"%@", [[area capitalizedString] stringByReplacingOccurrencesOfString:@" " withString:@"_"]];
 NSArray *timezoneNames = [NSTimeZone knownTimeZoneNames];
 for(int i = 0; i < [timezoneNames count]; i++){
 NSString *timezone = [timezoneNames objectAtIndex:i];
 if([timezone containsString:name]){
 name = timezone;
 NSLog(@"Found at index %d", i);
 break;
 }
 }
 NSTimeZone *timezone = [NSTimeZone timeZoneWithName:name];
 NSLog(@"timezone %@", timezone);
 
 NSTimeZone *nba = [NSTimeZone localTimeZone];
 
 //long timeDifference = nba.getRawOffset() - inTheZone.getRawOffset() + nba.getDSTSavings() - inTheZone.getDSTSavings();
 long difference = nba.secondsFromGMT - timezone.secondsFromGMT;
 if(nba.daylightSavingTime)
 difference += nba.daylightSavingTimeOffset;
 if(timezone.daylightSavingTime)
 difference -= nba.daylightSavingTimeOffset;
 
 PBWatch *currentWatch = [[PBPebbleCentral defaultCentral] lastConnectedWatch];
 
 if(!currentWatch){
 NSLog(@"no watch rip");
 }
 
 NSDictionary *update = @{ @(300):[timezone name], @(301):@(difference), @(302):@(-1), @(303):@(-1) };
 [currentWatch appMessagesPushUpdate:update onSent:^(PBWatch *watch, NSDictionary *update, NSError *error) {
 if (!error) {
 NSLog(@"Successfully sent timezone.");
 }
 else {
 NSLog(@"Error sending: %@", error);
 }
 //[self alertOfError:error];
 }];
	}
	else if([[transcription lowercaseString] containsString:@"what's the weather in"]){
 
	}
	else{
 
	}
 }
 */

@end
