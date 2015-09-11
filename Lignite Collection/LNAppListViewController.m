//
//  LNAppListViewController.m
//  Lignite
//
//  Created by Edwin Finch on 8/18/15.
//  Copyright (c) 2015 Edwin Finch. All rights reserved.
//

#import "LNAppListViewController.h"
#import <PebbleKit/PebbleKit.h>
#import <StoreKit/StoreKit.h>
#import "NSUserDefaults+MPSecureUserDefaults.h"
#import "LoginViewController.h"
#import "LNAppInfo.h"
#import "UIView+Toast.h"
#import "LNDataFramework.h"
#import "CreditsViewController.h"
#import "FeedbackViewController.h"
#import "LNSettingsViewController.h"
#import "LNPreviewBuilderController.h"
#import "LNColourPicker.h"
#import "SimpleTableViewController.h"

@interface LNAppListViewController () <SKProductsRequestDelegate, SKPaymentTransactionObserver, SimpleTableViewControllerDelegate>

@property UIButton *button;
@property UIAlertView *pebbleAppAlertView;
@property (strong) UIDocumentInteractionController *uidocumentInteractionController;
@property NSArray* appArray;
@property NSData *response1;
@property UITapGestureRecognizer *imageTapRecognizer;
@property BOOL usingTimeImage;
@property NSURLConnection *logoutConnection, *verifyConnection;

@property UIAlertView *backerAlert;

//Tutorial shit
@property UIImageView *tutorialBackgroundImageView, *tutorialArrowImageView;
@property UIButton *tutorialButton, *skipButton;
@property UILabel *tutorialLabel;
@property UIAlertView *tutorialAlert;

@end

@implementation LNAppListViewController

int tutorialStage = 0;
BOOL tutorialRunning = NO;
BOOL runTutorial = NO;

//#define BUILD 56

- (void)purchaseApp {
    if([SKPaymentQueue canMakePayments]){
        NSLog(@"User can make payments");
        
        SKProductsRequest *productsRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:[NSSet setWithObject:[[LNAppInfo skuArray] objectAtIndex:self.currentType]]];
        productsRequest.delegate = self;
        [productsRequest start];
        
    }
    else{
        NSLog(@"User cannot make payments due to parental controls");
        //this is called the user cannot make payments, most likely due to parental controls
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"cant_pay_title", "can't make payments, probs parental controls")
                                                        message:NSLocalizedString(@"cant_pay_description", "ditto, description")
                                                       delegate:nil
                                              cancelButtonTitle:NSLocalizedString(@"damn_okay", nil)
                                              otherButtonTitles:nil];
        [alert show];
    }
}

- (IBAction)purchase:(SKProduct *)product{
    [self.view makeToast:NSLocalizedString(@"please_wait", nil)];
    SKPayment *payment = [SKPayment paymentWithProduct:product];
    
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    [[SKPaymentQueue defaultQueue] addPayment:payment];
}

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response{
    SKProduct *validProduct = nil;
    unsigned long count = [response.products count];
    if(count > 0){
        validProduct = [response.products objectAtIndex:0];
        NSLog(@"Products Available!");
        [self purchase:validProduct];
    }
    else if(!validProduct){
        NSLog(@"No products available");
        //this is called if your product id is not valid, this shouldn't be called unless that happens.
    }
}

- (void) paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue{
    NSLog(@"received restored transactions: %lu", (unsigned long)queue.transactions.count);
    for(SKPaymentTransaction *transaction in queue.transactions){
        if(transaction.transactionState == SKPaymentTransactionStateRestored){
            //called when the user successfully restores a purchase
            NSLog(@"Transaction state -> Restored: %@", transaction.payment.productIdentifier);
            
            [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
            break;
        }
    }
    if(queue.transactions.count > 0){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"restored_purchases", nil)
                                                        message:[NSString stringWithFormat:NSLocalizedString(@"restored_purchases_description", nil), (int)queue.transactions.count]
                                                       delegate:nil
                                              cancelButtonTitle:NSLocalizedString(@"okay_thanks", nil)
                                              otherButtonTitles:nil];
        [alert show];
    }
}

- (void)itemPurchased:(SKPaymentTransaction*)transaction {
    NSLog(@"Transaction state -> Purchased/Restored: %@", transaction.payment.productIdentifier);
    int index = (int)[[LNAppInfo skuArray] indexOfObject:transaction.payment.productIdentifier];
    self.owns_app = true;
    if(index == self.currentType){
        [self.settingsButton setTitle:NSLocalizedString(@"settings", nil) forState:UIControlStateNormal];
    }
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setSecureBool:YES forKey:[NSString stringWithFormat:@"owns-%@", [LNAppInfo getAppNameFromType:index]]];
    [defaults synchronize];
}

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions{
    for(SKPaymentTransaction *transaction in transactions){
        NSLog(@"transaction state: %d", (int)transaction.transactionState);
        switch((int)transaction.transactionState){
            case SKPaymentTransactionStatePurchasing: NSLog(@"Transaction state -> Purchasing");
                //called when the user is in the process of purchasing, do not add any of your own code here.
                break;
            case SKPaymentTransactionStatePurchased:
                //this is called when the user has successfully purchased the package (Cha-Ching!)
                //you can add your code for what you want to happen when the user buys the purchase here, for this tutorial
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                
            case SKPaymentTransactionStateRestored:
                NSLog(@"Got transaction %@! Restoring...", transaction);
                [self itemPurchased:transaction];
                break;
            case SKPaymentTransactionStateFailed:
                //called when the transaction does not finish
                if(transaction.error.code == SKErrorPaymentCancelled){
                    NSLog(@"Transaction state -> Cancelled");
                    //the user cancelled the payment ;(
                }
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                break;
        }
    }
}

- (IBAction)installApp:(id)sender {
	NSDictionary *settings = [LNDataFramework getSettingsDictionaryForAppType:APP_TYPE_NOTHING];
	
	if([[settings objectForKey:@"general-pebble_app_to_open"] integerValue] == 0){
		self.pebbleAppAlertView = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"what_pebble_app", nil)
														   message:NSLocalizedString(@"what_pebble_app_description", nil)
														   delegate:self
												           cancelButtonTitle:NSLocalizedString(@"cancel", nil)
												           otherButtonTitles:NSLocalizedString(@"manage_settings", nil),
																			 NSLocalizedString(@"pebble_app_original", nil),
																			 NSLocalizedString(@"pebble_app_time", nil), nil];
		[self.pebbleAppAlertView show];
	}
	else{
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@://appstore/%@", [[settings objectForKey:@"general-pebble_app_to_open"] integerValue] == 1 ? @"pebble-2" : @"pebble-3",[[LNAppInfo locationArray] objectAtIndex:self.currentType]]]];
	}
    /*
     * RIP in pepperoni 1.2.1 feature u will b missed <3 ;(((
     *
     NSURL *pbwUrl = [[NSBundle mainBundle] URLForResource:[PebbleInfo getAppNameFromType:self.currentType] withExtension:@"pbw"];
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
        [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
    }
}

- (IBAction)actionButtonPushed:(id)sender {
    UIAlertController *controller = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *logoutAction;
    if([LNDataFramework isUserBacker]){
        logoutAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"send_feedback", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction* action){
            FeedbackViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"FEEDBACK"];
            [self showViewController:controller sender:nil];
        }];
    }
    else{
        logoutAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"kickstarter_backer", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction* action){
            FeedbackViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"LoginScreen"];
            //[self showViewController:controller sender:nil];
            [LNDataFramework setUserBacker:YES];
            [self presentViewController:controller animated:YES completion:nil];
        }];
    }
    UIAlertAction *creditsAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"credits", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction* action) {
        CreditsViewController *creditsController = [self.storyboard instantiateViewControllerWithIdentifier:@"CREDITS"];
        [self showViewController:creditsController sender:nil];
    }];
    UIAlertAction *tutorialAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"replay_tutorial", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction* action) {
		[self safeFireTutorial];
    }];
    UIAlertAction *manageAlertsAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"lignite_settings", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction*action) {
        LNSettingsViewController *alertsController = [[LNSettingsViewController alloc]initWithStyle:UITableViewStyleGrouped];
        [alertsController setAsAlertSettings];
        [self showViewController:alertsController sender:self];
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"cancel", nil) style:UIAlertActionStyleCancel handler:nil];
    /*
    UIAlertAction *purchaseAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"purchase_bundles", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        NSLog(@"Purchase bundles...");
    }];
    
    if(![LNDataFramework isUserBacker]){
        [controller addAction:purchaseAction];
    }
	 */
    [controller addAction:logoutAction];
    [controller addAction:tutorialAction];
    [controller addAction:manageAlertsAction];
    [controller addAction:creditsAction];
    [controller addAction:cancelAction];
    
    controller.popoverPresentationController.sourceView = self.view;
    controller.popoverPresentationController.sourceRect = CGRectMake(800, 50, 1.0, 1.0);
    
    [self presentViewController:controller animated:YES completion:nil];
}

- (IBAction)settingsButtonPushed:(id)sender {
    if(!self.owns_app){
        [self purchaseApp];
        return;
    }
    LNSettingsViewController *view_controller = [[LNSettingsViewController alloc]initWithStyle:UITableViewStyleGrouped];
    [view_controller setPebbleApp:self.currentType];
    [self showViewController:view_controller sender:self];
    
    NSString *appUUID = [LNAppInfo getAppUUID:self.currentType];
    [LNDataFramework sendLigniteGuardUnlockToPebble:self.currentType settingsController:view_controller];
    uuid_t myAppUUIDbytes;
    NSUUID *myAppUUID = [[NSUUID alloc] initWithUUIDString:appUUID];
    [myAppUUID getUUIDBytes:myAppUUIDbytes];
    PBWatch *watch = [[PBPebbleCentral defaultCentral] lastConnectedWatch];
    [watch appMessagesLaunch:nil withUUID:[NSData dataWithBytes:myAppUUIDbytes length:16]];
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
            [LNDataFramework setUserLoggedIn:[LNDataFramework getUsername] :NO];
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
	if(alertView == self.pebbleAppAlertView){
		NSLog(@"index %d", (int)buttonIndex);
		switch(buttonIndex){
			case 2:
				[[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"pebble-2://appstore/%@",[[LNAppInfo locationArray] objectAtIndex:self.currentType]]]];
				break;
			case 3:
				[[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"pebble-3://appstore/%@",[[LNAppInfo locationArray] objectAtIndex:self.currentType]]]];
				break;
			case 1:;
				LNSettingsViewController *alertsController = [[LNSettingsViewController alloc]initWithStyle:UITableViewStyleGrouped];
				[alertsController setAsAlertSettings];
				[self showViewController:alertsController sender:self];
				break;
		}
	}
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
				[self.backerAlert show];
				[LNDataFramework userAnsweredBackerQuestion:YES];
				[LNDataFramework setupDefaults];
			}
		}
		else if (1 == buttonIndex){
			[self safeFireTutorial];
		}
	}
	else{
		if(0 == buttonIndex){ //cancel button
			[alertView dismissWithClickedButtonIndex:buttonIndex animated:YES];
		}
		else if (1 == buttonIndex){
			LoginViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"LoginScreen"];
			[LNDataFramework setUserBacker:YES];
			[self presentViewController:controller animated:YES completion:nil];
		}
	}
}

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

- (void)itemSelectedatRow:(NSInteger)row {
    self.currentType = (AppTypeCode)row;
    [self updateContentBasedOnType];
    [LNDataFramework setPreviousAppType:self.currentType];
}

- (void)setScrollingEnabled:(BOOL)scrolling {
	for (UIScrollView *view in self.sourcePageViewController.view.subviews) {
		if ([view isKindOfClass:[UIScrollView class]]) {
			view.scrollEnabled = scrolling;
		}
	}
}

- (void)updateTutorial {
		[UIView animateWithDuration:0.3f animations:^{
			NSArray *views_array = [NSArray arrayWithObjects:self.skipButton, self.tutorialArrowImageView, self.tutorialButton, self.tutorialLabel, self.settingsButton, self.installButton, nil];
			for(int i = 0; i < [views_array count]; i++){
				UIView *view = [views_array objectAtIndex:i];
				if((view == self.installButton && (tutorialStage < 2 || tutorialStage > 3)) || (view == self.settingsButton && (tutorialStage < 3 || tutorialStage > 4))){
					goto skip_animate;
				}
				[view setAlpha:0.0f];
				skip_animate:;
			}
			//update frames
		} completion:^(BOOL finished) {
			//fade in
			[UIView animateWithDuration:0.1f animations:^{
				CGRect label_frames[] = {
					CGRectMake(20, self.appDescriptionLabel.frame.origin.y-12, self.tutorialBackgroundImageView.frame.size.width-40, 70),
					CGRectMake(20, self.imageView.frame.size.height + 25, self.view.frame.size.width-40, 200),
					CGRectMake(20, self.appDescriptionLabel.frame.origin.y-50, self.view.frame.size.width-40, 100),
					CGRectMake(20, self.appTitleLabel.frame.origin.y-25, self.view.frame.size.width-40, 125),
					CGRectMake(20, self.imageView.frame.origin.y+self.imageView.frame.size.height/2 - 30, self.view.frame.size.width-40, 100),
					CGRectMake(20, self.imageView.frame.origin.y+self.imageView.frame.size.height/2 - 30, self.view.frame.size.width-40, 125),
					CGRectMake(20, self.appDescriptionLabel.frame.origin.y, self.view.frame.size.width-40, 50),
				};
				int x_offset = self.view.frame.size.width/2 - (self.view.frame.size.width/2 - 50)/2;
				CGRect button_frames[] = {
					CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, 100),
					CGRectMake(0, self.view.frame.size.height, self.tutorialButton.frame.size.width, self.tutorialButton.frame.size.height),
					CGRectMake(x_offset, self.appDescriptionLabel.frame.origin.y + 55, self.view.frame.size.width/2 - 50, 32),
					CGRectMake(x_offset, self.appDescriptionLabel.frame.origin.y + 55, self.view.frame.size.width/2 - 50, 32),
					CGRectMake(x_offset, self.view.frame.size.height/2 - 15, self.view.frame.size.width/2 - 50, 32),
					CGRectMake(x_offset, self.view.frame.size.height/2 + 15, self.view.frame.size.width/2 - 50, 32),
					CGRectMake(self.view.frame.size.width/2 - (self.view.frame.size.width/2 - 25)/2,  self.appDescriptionLabel.frame.origin.y + 75, self.view.frame.size.width/2 - 25, 32)
				};
				CGRect skip_frames[] = {
					CGRectMake(x_offset, self.appDescriptionLabel.frame.origin.y + 75, self.view.frame.size.width/2 - 50, 32),
					CGRectMake(x_offset, self.view.frame.size.height/2 + 125, self.view.frame.size.width/2 - 50, 32),
					CGRectMake(x_offset, self.appDescriptionLabel.frame.origin.y + 95, self.view.frame.size.width/2 - 50, 32),
					CGRectMake(x_offset, self.appDescriptionLabel.frame.origin.y + 95, self.view.frame.size.width/2 - 50, 32),
					CGRectMake(x_offset, self.view.frame.size.height/2 + 25, self.view.frame.size.width/2 - 50, 32),
					CGRectMake(x_offset, self.view.frame.size.height/2 + 55, self.view.frame.size.width/2 - 50, 32),
					CGRectMake(self.view.frame.size.width + 100, self.view.frame.size.height/3 * 2 + 75, self.view.frame.size.width/2 - 50, 32)
				};
				CGRect arrow_frames[] = {
					CGRectMake(10, self.leftArrow.frame.origin.y, self.view.frame.size.width-20, 100),
					CGRectMake(10, self.imageView.frame.origin.y + self.imageView.frame.size.height/2, self.view.frame.size.width-20, 100),
					CGRectMake(self.installButton.frame.origin.x/2, self.installButton.frame.origin.y, self.installButton.frame.size.width-20, 50),
					CGRectMake(self.settingsButton.frame.origin.x+(self.settingsButton.frame.size.width*1.3), self.settingsButton.frame.origin.y-20, self.settingsButton.frame.size.width-20, 50),
					CGRectMake(10, self.imageView.frame.origin.y, 50, 70),
					CGRectMake(self.imageView.frame.origin.x+self.imageView.frame.size.width, self.imageView.frame.origin.y, 50, 70)
				};
				NSString *button_keys[] = {
					@"", @"", @"awesome", @"ok", @"thanks", @"alright", @"cool_bye_bye"
				};
				NSString *arrow_names[] = {
					@"double_arrows_pointed_up.png", @"arrow_up_thin.png", @"arrow_right_thin.png", @"arrow_left_thin.png", @"arrow_up_thin.png", @"arrow_up_thin_flipped.png"
				};
				
				uint8_t fixedIndex = tutorialStage == 7 ? 6 : tutorialStage;
				if(tutorialStage == -1){
					fixedIndex = 6;
				}
				
				self.tutorialLabel.frame = label_frames[fixedIndex];
				NSString *key = [NSString stringWithFormat:@"tutorial_main_%d", fixedIndex];
				self.tutorialLabel.text = NSLocalizedString(key, nil);
				
				self.skipButton.frame = skip_frames[fixedIndex];
				
				self.tutorialButton.frame = button_frames[tutorialStage];
				[self.tutorialButton setTitle:NSLocalizedString(button_keys[fixedIndex], nil) forState:UIControlStateNormal];
				
				self.tutorialArrowImageView.frame = arrow_frames[fixedIndex];
				self.tutorialArrowImageView.image = [UIImage imageNamed:arrow_names[fixedIndex]];
				
				self.imageView.userInteractionEnabled = NO;
				self.tutorialBackgroundImageView.userInteractionEnabled = YES;
				//self.sourceController.pageViewController.dataSource = nil;
				if([[self.tutorialBackgroundImageView subviews] containsObject:self.leftArrow] && tutorialStage != 0){
					[self.leftArrow removeFromSuperview];
					[self.view addSubview:self.leftArrow];
					[self.rightArrow removeFromSuperview];
					[self.view addSubview:self.rightArrow];
				}
				if([[self.tutorialBackgroundImageView subviews] containsObject:self.imageView] && tutorialStage != 1){
					[self.imageView removeFromSuperview];
					[self.view addSubview:self.imageView];
				}
				if([[self.tutorialBackgroundImageView subviews] containsObject:self.installButton] && tutorialStage != 2){
					[self.installButton removeFromSuperview];
					[self.view addSubview:self.installButton];
				}
				if([[self.tutorialBackgroundImageView subviews] containsObject:self.settingsButton] && tutorialStage != 3){
					[self.settingsButton removeFromSuperview];
					[self.view addSubview:self.settingsButton];
				}
				
				[self.tutorialBackgroundImageView removeFromSuperview];
				[self.view addSubview:self.tutorialBackgroundImageView];
				[self setScrollingEnabled:NO];
				
				switch(tutorialStage){
					case 0:
						[self setScrollingEnabled:YES];
						[self.view addSubview:self.leftArrow];
						[self.view addSubview:self.rightArrow];
						break;
					case 1:
						self.imageView.userInteractionEnabled = YES;
						[self.tutorialBackgroundImageView addSubview:self.imageView];
						[self.tutorialBackgroundImageView addSubview:self.skipButton];
						break;
					case 2:
						[self.view addSubview:self.installButton];
						break;
					case 3:
						[self.view addSubview:self.settingsButton];
						break;
					case -1:
						tutorialStage = 0;
					case 7:
						[UIView animateWithDuration:1.0f animations:^{
							self.tutorialBackgroundImageView.frame = CGRectMake(0, self.view.frame.size.height, self.tutorialBackgroundImageView.frame.size.width, self.tutorialBackgroundImageView.frame.size.height);
							tutorialRunning = NO;
							self.imageView.userInteractionEnabled = YES;
							self.appDescriptionLabel.userInteractionEnabled = YES;
							self.appTitleLabel.userInteractionEnabled = YES;
							self.settingsButton.userInteractionEnabled = YES;
							self.installButton.userInteractionEnabled = YES;
							tutorialStage = -1;
							[self setScrollingEnabled:YES];
							[[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
						}];
						break;
				}
			} completion:^(BOOL finished) {
				
				//fade in
				[UIView animateWithDuration:0.3f animations:^{
					
					NSArray *views_array = [NSArray arrayWithObjects:self.skipButton, self.tutorialArrowImageView, self.tutorialButton, self.tutorialLabel, self.settingsButton, self.installButton, nil];
					for(int i = 0; i < [views_array count]; i++){
						UIView *view = [views_array objectAtIndex:i];
						if((view == self.installButton && (tutorialStage < 2 || tutorialStage > 3)) || (view == self.settingsButton && (tutorialStage < 3 || tutorialStage > 4))){
							goto skip_animate;
						}
						[view setAlpha:1.0f];
					skip_animate:;
					}
					
				} completion:nil];
			}];}];
}

- (IBAction)tutorialNext:(id)sender {
    tutorialRunning = YES;
    tutorialStage++;
    [self updateTutorial];
}

- (IBAction)tutorialEnd:(id)sender {
	tutorialStage = 7;
	[self updateTutorial];
}

- (void)safeFireTutorial {
	if(tutorialRunning){
		return;
	}
	if(self.currentType == 0 || self.currentType == APP_COUNT-1){
		runTutorial = YES;
		LNAppListController *controller = (LNAppListController*)self.sourceViewController;
		[controller selectAnApp:APP_TYPE_COLOURS];
		return;
	}
	else{
		LNAppListController *controller = (LNAppListController*)self.sourceViewController;
		[controller selectAnApp:self.currentType];
	}
	tutorialStage = 0;
	[self fireTutorial];
}

- (void)fireTutorial {
	[[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];

	if(tutorialStage == -1){
		tutorialStage = 0;
	}
    self.tutorialBackgroundImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, 0)];
    [self.tutorialBackgroundImageView setImage:[UIImage imageNamed:@"tutorial_background.png"]];
    
    self.tutorialArrowImageView = [[UIImageView alloc]initWithFrame:CGRectMake(10, self.leftArrow.frame.origin.y, self.view.frame.size.width-20, 100)];
    self.tutorialArrowImageView.contentMode = UIViewContentModeScaleAspectFit;
	self.tutorialArrowImageView.image = [UIImage imageNamed:@"double_arrows.png"];
    [self.tutorialBackgroundImageView addSubview:self.tutorialArrowImageView];
    
    self.tutorialLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, self.appDescriptionLabel.frame.origin.y, self.tutorialBackgroundImageView.frame.size.width-40, 50)];
    self.tutorialLabel.text = NSLocalizedString(@"tutorial_main_0", nil);
    self.tutorialLabel.numberOfLines = 0;
    self.tutorialLabel.lineBreakMode = NSLineBreakByWordWrapping;
	if(self.view.frame.size.height > 480){
		self.tutorialLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:18.0f];
	}
	else{
		self.tutorialLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:14.0f];
	}
	self.tutorialLabel.textAlignment = NSTextAlignmentCenter;
    [self.tutorialBackgroundImageView addSubview:self.tutorialLabel];
    
    self.tutorialButton = [[UIButton alloc]initWithFrame:CGRectMake(self.view.frame.size.width, -100, self.view.frame.size.width, 100)];
    [self.tutorialButton setTitle:NSLocalizedString(@"ok_got_it", nil) forState:UIControlStateNormal];
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
	
	int x_offset = self.view.frame.size.width/2 - (self.view.frame.size.width/2 - 50)/2;
    self.skipButton = [[UIButton alloc]initWithFrame:CGRectMake(x_offset, self.appDescriptionLabel.frame.origin.y + 75, self.view.frame.size.width/2 - 50, 320)];
    [self.skipButton setTitle:NSLocalizedString(@"end_tutorial", nil) forState:UIControlStateNormal];
    [self.skipButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	[self.skipButton setBackgroundColor:[UIColor colorWithRed:0.81 green:0.81 blue:0.81 alpha:1.0]];
    [self.skipButton addTarget:self action:@selector(tutorialEnd:) forControlEvents:UIControlEventTouchUpInside];
	self.skipButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:14.0f];
    self.skipButton.userInteractionEnabled = YES;
	self.skipButton.layer.masksToBounds = YES;
	self.skipButton.layer.borderWidth = 1.0;
	self.skipButton.layer.borderColor = self.skipButton.backgroundColor.CGColor;
	self.skipButton.layer.cornerRadius = 5.0;
    [self.tutorialBackgroundImageView addSubview:self.skipButton];
	
    self.imageView.userInteractionEnabled = NO;
    self.appDescriptionLabel.userInteractionEnabled = NO;
    self.appTitleLabel.userInteractionEnabled = NO;
    self.settingsButton.userInteractionEnabled = NO;
    self.installButton.userInteractionEnabled = NO;
    
    self.tutorialBackgroundImageView.userInteractionEnabled = YES;
    
    [self.view addSubview:self.tutorialBackgroundImageView];
    
    [self updateTutorial];
    tutorialRunning = YES;
	
	[UIView animateWithDuration:1.0f animations:^{
		self.tutorialBackgroundImageView.frame = self.view.frame;
	}];
}

-(BOOL)prefersStatusBarHidden{
	return NO;
}

- (void)viewDidAppear:(BOOL)animated {
    if(![[self.view subviews] containsObject:self.tutorialBackgroundImageView] && tutorialRunning){
        [self fireTutorial];
    }
    if(tutorialRunning || (tutorialStage == -1)){
        [self updateTutorial];
    }
	[super viewDidAppear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
	
	srand(time(NULL));
	
	if(!tutorialRunning){
		[[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
		[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
	}
	
    CGRect viewFrame = self.view.frame;
    
    self.appTitleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, (viewFrame.size.height/4)*2.26, viewFrame.size.width, 40)];
    self.appTitleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:28.0f];
    self.appTitleLabel.text = @"App Title";
    self.appTitleLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:self.appTitleLabel];
    
    self.installButton = [[UIButton alloc]initWithFrame:CGRectMake(viewFrame.size.width/2 - 54, viewFrame.size.height - 66, 52, 52)];
    [self.installButton setImage:[UIImage imageNamed:@"install-button.png"] forState:UIControlStateNormal];
    [self.installButton addTarget:self action:@selector(installApp:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.installButton];
    
    self.settingsButton = [[UIButton alloc]initWithFrame:CGRectMake(viewFrame.size.width/2 + 6, viewFrame.size.height - 66, 52, 52)];
    [self.settingsButton setImage:[UIImage imageNamed:@"settings-button.png"] forState:UIControlStateNormal];
    [self.settingsButton addTarget:self action:@selector(settingsButtonPushed:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.settingsButton];
    
    self.appDescriptionLabel = [[UITextView alloc]initWithFrame:CGRectMake(20, (viewFrame.size.height/4)*2.55, viewFrame.size.width-40, (viewFrame.size.height - 70) - (viewFrame.size.height/4)*2.6 - 3)];
    self.appDescriptionLabel.editable = NO;
    self.appDescriptionLabel.backgroundColor = [UIColor clearColor];
    self.appDescriptionLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:18.0f];
    [self.view addSubview:self.appDescriptionLabel];
    
    self.imageView = [[UIImageView alloc]initWithFrame:CGRectMake(60, 80, viewFrame.size.width-120, (viewFrame.size.height/4)*2.3 - 80)];
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    self.imageView.userInteractionEnabled = YES;
    [self.view addSubview:self.imageView];
    
    [NSUserDefaults setSecret:@"XqcOyp_yl2U"];
    
    if([LNDataFramework getUsername].length != 6){
        [LNDataFramework setUserBacker:NO];
    }
    
    if(![LNDataFramework isUserBacker]){
        for(int i = 0; i < APP_COUNT; i++){
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            
            BOOL valid = NO;
            BOOL registered = [defaults secureBoolForKey:[NSString stringWithFormat:@"owns-%@", [LNAppInfo getAppNameFromType:i]] valid:&valid];
            if (!valid) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"tampered_with", nil)
                                                                message:NSLocalizedString(@"tampered_with_description", nil)
                                                               delegate:nil
                                                      cancelButtonTitle:NSLocalizedString(@"freeloader", nil)
                                                      otherButtonTitles:nil];
                [alert show];
            }
            else {
                self.owns_app = registered;
            }
        }
    }
    
#ifdef BUILD
    if(![LNDataFramework isUserLoggedIn]){
        for(int i = 0; i < APP_COUNT; i++){
            self.owns_app = true;
            NSLog(@"Skipping purchases... You own everything. Congrats!");
        }
        UILabel *skipping = [[UILabel alloc]initWithFrame:CGRectMake(20, 0, self.view.frame.size.width-40, 200)];
        skipping.textAlignment = NSTextAlignmentCenter;
        skipping.numberOfLines = 0;
        skipping.text = [NSString stringWithFormat:@"Build %d %p - purchases skipped!", BUILD, skipping];
        skipping.textColor = [UIColor colorWithRed:255 green:0 blue:0 alpha:50];
        [self.view addSubview:skipping];
    }
#endif
    
    self.imageTapRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapImageGestureRecognizer:)];
    
    [self.imageView addGestureRecognizer:self.imageTapRecognizer];
        
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	
	BOOL tutorialResult = [defaults boolForKey:@"key-TUTORIAL"];
	if(!tutorialResult){
		self.tutorialAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"tutorial", nil)
														message:NSLocalizedString(@"would_you_like_tutorial", nil)
													   delegate:self
											  cancelButtonTitle:NSLocalizedString(@"no", nil)
											  otherButtonTitles:NSLocalizedString(@"yes", nil), nil];
		[self.tutorialAlert show];
		[defaults setBool:YES forKey:@"key-TUTORIAL"];
		[defaults synchronize];
	}
	
    self.leftArrow = [[UIImageView alloc]initWithFrame:CGRectMake(24, self.imageView.frame.origin.y+self.imageView.frame.size.height/2.2, 10, 10)];
    [self.leftArrow setImage:[UIImage imageNamed:@"arrow-active.png"]];
    if(self.currentType == 0){
        [self.leftArrow setImage:[UIImage imageNamed:@"arrow-inactive.png"]];
    }
    [self.view addSubview:self.leftArrow];
    
    self.rightArrow = [[UIImageView alloc]initWithFrame:CGRectMake(self.view.frame.size.width - 40, self.imageView.frame.origin.y+self.imageView.frame.size.height/2.2, 10, 10)];
    [self.rightArrow setImage:[UIImage imageNamed:@"arrow-active-right.png"]];
    if(self.currentType == APP_COUNT-1){
        [self.rightArrow setImage:[UIImage imageNamed:@"arrow-inactive-right.png"]];
    }
    [self.view addSubview:self.rightArrow];
    
    
    /*
     LNSettingsViewController *view_controller = [[LNSettingsViewController alloc]initWithStyle:UITableViewStyleGrouped];
     [view_controller setPebbleApp:APP_TYPE_SPEEDOMETER];
     [self showViewController:view_controller sender:self];
     
     LNColourPicker *colour_picker = [[LNColourPicker alloc]init];
     [self showViewController:colour_picker sender:self];
     
    self.navigationController.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(actionButtonPushed:)];
    self.navigationController.title = @"Lignite";
    self.navigationController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"Hello" style:UIBarButtonItemStyleDone target:self action:@selector(actionButtonPushed:)];
    */
    
    if(self.currentType == APP_TYPE_TIMEDOCK){
        self.owns_app = YES;
    }
    
    [self updateContentBasedOnType];
    if(tutorialRunning && tutorialStage == 0){
        tutorialStage++;
    }
	if(runTutorial){
		runTutorial = NO;
		[self fireTutorial];
	}
}

- (void)updatePebblePreview {
    UIImage *toImage = [LNPreviewBuilderController imageForPebble:[UIImage imageNamed:[LNDataFramework defaultPebbleImage]] andScreenshot:[UIImage imageNamed:[NSString stringWithFormat:@"%@-%@-1.png", [LNAppInfo getAppNameFromType:self.currentType], [LNDataFramework pebbleImageIsTime:[LNDataFramework defaultPebbleImage]] ? @"basalt" : @"aplite"]]];
	if(toImage == nil){
		NSLog(@"is nil mate");
		toImage = [LNPreviewBuilderController imageForPebble:[UIImage imageNamed:@"snowy-black.png"] andScreenshot:[UIImage imageNamed:[NSString stringWithFormat:@"%@-%@-1.png", [LNAppInfo getAppNameFromType:self.currentType], [LNDataFramework pebbleImageIsTime:[LNDataFramework defaultPebbleImage]] ? @"basalt" : @"aplite"]]];
		[LNDataFramework setDefaultPebbleImage:@"snowy-black.png"];
		[self updatePebblePreview];
		return;
	}
    self.imageView.image = toImage;
}

- (void)tapImageGestureRecognizer:(UITapGestureRecognizer*)rec {
    LNPreviewBuilderController *editController = [self.storyboard instantiateViewControllerWithIdentifier:@"EditController"];
    editController.appType = self.currentType;
    editController.isTutorial = tutorialStage > 0;
    if(editController.isTutorial){
        [self presentViewController:editController animated:YES completion:nil];
    }
    else{
        [self showViewController:editController sender:self];
    }
    editController.sourceController = self;
    if(tutorialStage > 0){
        [self tutorialNext:self];
    }
}

- (IBAction)fireTimer:(id)sender {
    NSLog(@"Response of %@", self.response1);
}

- (void)updateContentBasedOnType {
    self.appTitleLabel.text = [[LNAppInfo getAppNameFromType:self.currentType] capitalizedString];
    [self updatePebblePreview];
    self.appDescriptionLabel.text = [LNAppInfo getAppDescriptionFromType:self.currentType];
    if(self.currentType == APP_TYPE_KNIGHTRIDER){
        self.appTitleLabel.text = @"RightNighter";
    }
    self.appDescriptionLabel.font = [UIFont fontWithName:@"helvetica neue" size:14.0];
    self.settingsButton.enabled = [LNAppInfo settingsEnabled:self.currentType];
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

@end
