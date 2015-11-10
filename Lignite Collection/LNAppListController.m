//
//  LNAppListController.m
//  Lignite
//
//  Created by Edwin Finch on 8/18/15.
//  Copyright (c) 2015 Edwin Finch. All rights reserved.
//

#import <PebbleKit/PebbleKit.h>
#import <StoreKit/StoreKit.h>
#import "NSUserDefaults+MPSecureUserDefaults.h"
#import "UIView+Toast.h"
#import "CreditsViewController.h"
#import "FeedbackViewController.h"
#import "LNAppListController.h"
#import "LNAppPreviewView.h"
#import "LNPreviewBuilder.h"
#import "LNTutorialViewPagerController.h"
#import "LNPebbleViewController.h"

@interface LNAppListController () <SimpleTableViewControllerDelegate, LNAppPreviewViewClickDelegate,
								    UITableViewDelegate, UITableViewDataSource,
									 PBPebbleCentralDelegate,
									  SKProductsRequestDelegate, SKPaymentTransactionObserver>

@property NSURLConnection *verifyConnection;
@property UIScrollView *contentScrollView;
@property NSArray *possibleConditionsArray, *possiblePlatformsArray, *possibleBundlesArray;
@property NSMutableDictionary *appliedConditionsDictionary;
@property UITableView *conditionsTableView;
@property UIView *coverView; //For the faded out effect on a popup
@property UIImageView *cancelIconView; //For the user being able to cancel out of the popup
@property UILabel *titleView, *subtitleView;
@property UIButton *filterViewButton, *resetViewButton;
@property PBWatch *currentWatch;
@property BOOL editingConditions;
@property (nonatomic, assign) LigniteServiceStatus serviceStatus;
@property UIAlertAction *servicesAction;

@property NSMutableArray *watchAppArray;

@property UIDynamicAnimator *animator;
@property UIGravityBehavior *gravityBehaviour;
@property UIPushBehavior *pushBehavior;

@property UIAlertView *purchaseBundleAlertView;
@property UIAlertView *tutorialAlert;
@property UIAlertView *setPebbleAlert;

@end

@implementation LNAppListController

BOOL controller_owns_app[APP_COUNT];
const int viewFrameXAdjust = 30;
const int viewFrameYAdjust = 100;

- (void)askTutorialQuestion {
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	
	BOOL tutorialResult = [defaults boolForKey:@"key-TUTORIAL-2"];
	if(!tutorialResult){
		self.tutorialAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"tutorial", nil)
														message:NSLocalizedString(@"would_you_like_tutorial", nil)
													   delegate:self
											  cancelButtonTitle:NSLocalizedString(@"no", nil)
											  otherButtonTitles:NSLocalizedString(@"yes", nil), nil];
		[self.tutorialAlert show];
		[defaults setBool:YES forKey:@"key-TUTORIAL-2"];
		[defaults synchronize];
	}
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
	if(alertView == self.purchaseBundleAlertView){
		switch(buttonIndex){
			case 1:
				NSLog(@"Yes please");
				[self purchaseWithSku:self.purchasingWatchapp.bundleName];
				break;
			case 0:
				NSLog(@"No thanks");
				[self purchaseWithSku:self.purchasingWatchapp.sku];
				[alertView dismissWithClickedButtonIndex:buttonIndex animated:YES];
				break;
		}
	}
	else if(alertView == self.tutorialAlert){
		if(0 == buttonIndex){ //cancel button
			[alertView dismissWithClickedButtonIndex:buttonIndex animated:YES];
			/*
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
			 
			}*/
		}
		else if (1 == buttonIndex){
			[self launchTutorial];
		}
	}
	else if(alertView == self.setPebbleAlert){
		if(0 == buttonIndex){ //cancel button
			[alertView dismissWithClickedButtonIndex:buttonIndex animated:YES];
			[self askTutorialQuestion];
		}
		else if (1 == buttonIndex){
			LNPebbleViewController *controller = [[LNPebbleViewController alloc]init];
			controller.sourceListController = self;
			controller.askTutorialQuestionAfter = YES;
			[self presentViewController:controller animated:YES completion:nil];
		}
	}
}

- (void)purchaseWithSku:(NSString*)sku {
	[self.view makeToast:NSLocalizedString(@"please_wait", nil)];
	
	NSLog(@"User wants to purchase %@", sku);
	
	[self dismissAppPopup:nil];
	
	if([SKPaymentQueue canMakePayments]){
		NSLog(@"User can make payments");
		
		SKProductsRequest *productsRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:[NSSet setWithObject:sku]];
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

- (void)purchaseApp:(LNPebbleApp*)watchApp {
	self.purchasingWatchapp = watchApp;
	
	NSLog(@"Bundle name %@", self.purchasingWatchapp.bundleName);
	
	if(self.purchasingWatchapp.bundleName && ![[self.purchasingWatchapp.bundles objectForKey:@"the_weather_bundle"] isEqualToNumber:@(1)]){
		NSLog(@"Asking user if they want a bundle instead");
		NSString *bundle_question = [NSString stringWithFormat:@"would_you_like_bundle_%@", self.purchasingWatchapp.bundleName];
		self.purchaseBundleAlertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(self.purchasingWatchapp.bundleName, nil)
														message:NSLocalizedString(bundle_question, nil)
													   delegate:self
											  cancelButtonTitle:NSLocalizedString(@"no_thanks", nil)
											  otherButtonTitles:NSLocalizedString(@"sure", nil), nil];
		[self.purchaseBundleAlertView show];
	}
	else{
		[self purchaseWithSku:self.purchasingWatchapp.sku];
	}
}

- (void)restorePurchases {
	NSLog(@"Restoring purchases");
	[self.view makeToast:NSLocalizedString(@"please_wait", nil)];
	[[SKPaymentQueue defaultQueue] addTransactionObserver:self];
	[[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
}

- (IBAction)purchase:(SKProduct *)product{
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

- (void)paymentQueue:(SKPaymentQueue *)queue restoreCompletedTransactionsFailedWithError:(NSError *)error {
	NSLog(@"Failed with error %@", error.localizedDescription);
}

- (void)paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue{
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

- (void)writeOwnsApp:(NSString*)appString doesOwnApp:(BOOL)owns {
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSString *ownsString = [NSString stringWithFormat:@"owns-%@", appString];
	NSLog(@"Setting owns string: %@ to %@", ownsString, (owns ? @"YES": @"NO"));
	[defaults setSecureBool:owns forKey:ownsString];
	[defaults synchronize];
}

+ (BOOL)userOwnsApp:(LNPebbleApp*)pebbleApp {
	if(pebbleApp.isKickstarter && [LNDataFramework isUserLoggedIn] && [LNDataFramework isUserBacker]){
		return YES;
	}
	
	[NSUserDefaults setSecret:@"XqcOyp_yl2U"];
	
	BOOL valid = NO;
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSString *ownsString = [NSString stringWithFormat:@"owns-%@", pebbleApp.appName];
	BOOL result = [defaults secureBoolForKey:ownsString valid:&valid];
	
	NSLog(@"User owns %@: %@.", ownsString, result ? @"YES" : @"NO");
	
	if (!valid) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"tampered_with", nil)
														message:NSLocalizedString(@"tampered_with_description", nil)
													   delegate:nil
											  cancelButtonTitle:NSLocalizedString(@"freeloader", nil)
											  otherButtonTitles:nil];
		[alert show];
		
		return NO;
	}
	
	return result;
}

+ (NSString*)appNameFromSKU:(NSString*)sku {
	NSData *data = [[NSData alloc]initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"sku_to_app" ofType:@"json"]];
	NSError *error;
	NSDictionary *rawInfoDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
	if(error){
		NSLog(@"Error creating dictionary for sku_to_app: %@", [error localizedDescription]);
	}
	NSString *appString = [rawInfoDictionary objectForKey:sku];

	return appString;
}

- (void)itemPurchased:(SKPaymentTransaction*)transaction {
	NSLog(@"Transaction state -> Purchased/Restored: %@", transaction.payment.productIdentifier);

	NSString *appString = [LNAppListController appNameFromSKU:transaction.payment.productIdentifier];
	
	if(!appString){
		NSLog(@"User did not purchase an app! They purchased a bundle (%@). Shit. Awesome, but shit.", transaction.payment.productIdentifier);
		for(int i = 0; i < APP_COUNT; i++){
			LNPebbleApp *app = [[LNPebbleApp alloc]initWithAppIndex:i];
			NSLog(@"Comparing app %@ (bundle %@) and %@", app.appName, app.bundleName, transaction.payment.productIdentifier);
			if([app.bundleName isEqualToString:transaction.payment.productIdentifier]){
				NSLog(@"App %@ is included in bundle. Writing to storage.", app.appName);
				[self writeOwnsApp:app.appName doesOwnApp:YES];
			}
			else{
				
			}
		}
	}
	else{
		NSLog(@"User purchased an app (%@). That was easy.", transaction.payment.productIdentifier);
		[self writeOwnsApp:appString doesOwnApp:YES];
	}
	[self reloadContentView];
}

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions{
	for(SKPaymentTransaction *transaction in transactions){
		NSLog(@"Transaction state: %d", (int)transaction.transactionState);
		switch((int)transaction.transactionState){
			case SKPaymentTransactionStatePurchasing: NSLog(@"Transaction state -> Purchasing");
				//called when the user is in the process of purchasing, do not add any of your own code here.
				break;
			case SKPaymentTransactionStatePurchased:
				//this is called when the user has successfully purchased the package (Cha-Ching!)
				//you can add your code for what you want to happen when the user buys the purchase here, for this tutorial
				[[SKPaymentQueue defaultQueue] finishTransaction:transaction];
				[self itemPurchased:transaction];
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

- (void)topLeftPushed:(id)sender {
    LNAppListViewController *controller = (LNAppListViewController*)[[self.pageViewController viewControllers] objectAtIndex:0];
    [controller logoutButtonPushed:self];
}

- (void)removeCoverLayerFromView {
	[self.coverView removeFromSuperview];
}

- (void)dismissAppPopup:(UITapGestureRecognizer*)recognizer{
	[UIView animateWithDuration:0.4f animations:^{
		self.pageViewController.view.frame = CGRectMake(viewFrameXAdjust, -1000, self.pageViewController.view.frame.size.width, self.view.frame.size.height-viewFrameYAdjust-10);
		self.cancelIconView.frame = CGRectMake(self.cancelIconView.frame.origin.x, -1000, self.cancelIconView.frame.size.width, self.cancelIconView.frame.size.height);
		self.coverView.backgroundColor = [UIColor colorWithRed:0.77 green:0.77 blue:0.77 alpha:0];
	}];
	[NSTimer scheduledTimerWithTimeInterval:0.5f
									 target:self
								   selector:@selector(removeCoverLayerFromView)
								   userInfo:nil
									repeats:NO];
}

- (void)launchPreviewPopupView {
	// Change the size of page view controller
	[self.view addSubview:self.coverView];
	[self.view addSubview:self.pageViewController.view];
	[self.view addSubview:self.cancelIconView];
	
	[UIView animateWithDuration:0.4f animations:^{
		self.pageViewController.view.frame = CGRectMake(viewFrameXAdjust, viewFrameYAdjust, self.view.frame.size.width-(viewFrameXAdjust*2), self.view.frame.size.height-viewFrameYAdjust-10);
		int imageSize = 30;
		self.cancelIconView.frame = CGRectMake(self.pageViewController.view.frame.origin.x + self.pageViewController.view.frame.size.width - 20, self.pageViewController.view.frame.origin.y - imageSize + 20, imageSize, imageSize);
		self.coverView.backgroundColor = [UIColor colorWithRed:0.77 green:0.77 blue:0.77 alpha:0.75];
	}];
	
	/*
	self.pageViewController.view.frame = CGRectMake(viewFrameXAdjust, viewFrameYAdjust, self.view.frame.size.width-(viewFrameXAdjust*2), self.view.frame.size.height-viewFrameYAdjust+10);
	int imageSize = 40;
	int halfImageSize = imageSize/2;
	self.cancelIconView.frame = CGRectMake(self.pageViewController.view.frame.origin.x + self.pageViewController.view.frame.size.width - halfImageSize, self.pageViewController.view.frame.origin.y - halfImageSize, imageSize, imageSize);
	self.coverView.backgroundColor = [UIColor colorWithRed:0.77 green:0.77 blue:0.77 alpha:0.5];
	
	self.animator = [[UIDynamicAnimator alloc] initWithReferenceView:self.view];
	
	UICollisionBehavior *collisionBehaviour = [[UICollisionBehavior alloc] initWithItems:@[self.pageViewController.view]];
	[collisionBehaviour setTranslatesReferenceBoundsIntoBoundaryWithInsets:UIEdgeInsetsMake(-280, 0, 0, 0)];
	[self.animator addBehavior:collisionBehaviour];
	
	self.gravityBehaviour = [[UIGravityBehavior alloc] initWithItems:@[self.pageViewController.view]];
	self.gravityBehaviour.gravityDirection = CGVectorMake(0.0f, 1.0f);
	[self.animator addBehavior:self.gravityBehaviour];
	
	self.pushBehavior = [[UIPushBehavior alloc] initWithItems:@[self.pageViewController.view] mode:UIPushBehaviorModeInstantaneous];
	self.pushBehavior.magnitude = 5.0f;
	self.pushBehavior.angle = 0.0f;
	self.pushBehavior.pushDirection = CGVectorMake(0.0f, 40.0f);
	self.pushBehavior.active = YES;
	[self.animator addBehavior:self.pushBehavior];
	
	UIDynamicItemBehavior *itemBehaviour = [[UIDynamicItemBehavior alloc] initWithItems:@[self.pageViewController.view]];
	itemBehaviour.elasticity = 0.4f;
	[self.animator addBehavior:itemBehaviour];
	 */
	
}

- (void)itemSelectedatRow:(NSInteger)row {
    self.currentIndex = row;
    [self selectAnApp:(WatchApp)self.currentIndex];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
    NSError *error;
    NSDictionary *jsonResult = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
    NSNumber *status = [jsonResult objectForKey:@"status"];
	
	NSLog(@"Got response %@", jsonResult);
	
    if(connection == self.verifyConnection){
        if(![status isEqual:@200]){
            [LNDataFramework setUserLoggedIn:[LNDataFramework getUsername] :NO];
            LoginViewController *loginScreen = [self.storyboard instantiateViewControllerWithIdentifier:@"LoginScreen"];
            [self presentViewController:loginScreen animated:YES completion:nil];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"illegal_account", "user's account is malformed")
                                                            message:NSLocalizedString(@"illegal_account_description", "ditto, description")
                                                           delegate:nil
                                                  cancelButtonTitle:NSLocalizedString(@"damn_okay", nil)
                                                  otherButtonTitles:nil];
            [alert show];
        }
        else{
            //Good2go
            //G2G
            //GG
            for(int i = 0; i < APP_COUNT; i++){
				LNPebbleApp *app = [[LNPebbleApp alloc]initWithAppIndex:i];
				controller_owns_app[i] = app.isKickstarter;
                LNAppListViewController *controller = (LNAppListViewController*)[[self.pageViewController viewControllers]objectAtIndex:0];
				controller.owns_app = app.isKickstarter;
                [controller updateContentBasedOnType];
            }
        }
    }
}

- (void)updateContentView {
	/*
	int subtitleViewEndingY = self.subtitleView.frame.origin.y+self.subtitleView.frame.size.height;
	[UIView animateWithDuration:0.5 animations:^{
		self.contentScrollView.frame = CGRectMake(0, self.editingConditions ? -self.view.frame.size.height + 20 : subtitleViewEndingY, self.contentScrollView.frame.size.width, self.contentScrollView.frame.size.height);
		self.conditionsTableView.frame = CGRectMake(0, self.editingConditions ? subtitleViewEndingY : -self.view.frame.size.height, self.conditionsTableView.frame.size.width, self.conditionsTableView.frame.size.height);
		if(self.editingConditions){
			self.titleView.text = @"What would you like to see?";
			self.subtitleView.text = @"Click to show/hide from the following";
		}
		else{
			self.titleView.text = @"Watchfaces and watchapps";
			self.subtitleView.text = @"All available";
		}
	}];
	 */
	
	self.conditionsTableView.frame = CGRectMake(self.conditionsTableView.frame.origin.x, self.contentScrollView.frame.origin.y, self.conditionsTableView.frame.size.width, self.conditionsTableView.frame.size.height);
	
	NSLog(@"Editing conditions %@", self.editingConditions ? @"YES" : @"NO");
	if(self.editingConditions){
		[UIView animateWithDuration:0.25 animations:^{
			//Animate button out
			self.filterViewButton.layer.opacity = 0;
			self.titleView.layer.opacity = 0;
			self.subtitleView.layer.opacity = 0;
		} completion:^(BOOL finished) {
			//Change button properties
			[self.filterViewButton setTitle:NSLocalizedString(@"apply_filter", nil) forState:UIControlStateNormal];
			self.titleView.text = NSLocalizedString(@"filter_title", nil);
			self.subtitleView.text = NSLocalizedString(@"filter_subtitle", nil);
			self.filterViewButton.frame = CGRectMake(self.view.frame.size.width/2 + 30, self.filterViewButton.frame.origin.y, self.view.frame.size.width/2 - 60, self.filterViewButton.frame.size.height);
			if([[self.appliedConditionsDictionary allKeys] count] == 0){
				[self.resetViewButton setTitle:NSLocalizedString(@"cancel", nil) forState:UIControlStateNormal];
			}
			else{
				[self.resetViewButton setTitle:NSLocalizedString(@"reset_filter", nil) forState:UIControlStateNormal];
			}
			[UIView animateWithDuration:0.25 animations:^{
				self.filterViewButton.layer.opacity = 1;
				self.resetViewButton.layer.opacity = 1;
				self.resetViewButton.userInteractionEnabled = YES;
				self.titleView.layer.opacity = 1;
				self.subtitleView.layer.opacity = 1;
			}];
		}];
		[UIView animateWithDuration:0.5 animations:^{
			self.contentScrollView.layer.opacity = 0;
			self.conditionsTableView.layer.opacity = 1;
		}];
	}
	else{
		[UIView animateWithDuration:0.25 animations:^{
			//Animate button out
			self.filterViewButton.layer.opacity = 0;
			self.resetViewButton.layer.opacity = 0;
			self.titleView.layer.opacity = 0;
			self.subtitleView.layer.opacity = 0;
		} completion:^(BOOL finished) {
			//Change button properties
			[self.filterViewButton setTitle:NSLocalizedString(@"modify_filter", nil) forState:UIControlStateNormal];
			self.filterViewButton.frame = CGRectMake(self.view.frame.size.width/4, self.filterViewButton.frame.origin.y, self.view.frame.size.width/2, self.filterViewButton.frame.size.height);
			[UIView animateWithDuration:0.25 animations:^{
				self.filterViewButton.layer.opacity = 1;
				self.resetViewButton.userInteractionEnabled = NO;
				self.titleView.text = NSLocalizedString(@"watchfaces_and_watchapps", nil);
				if([[self.appliedConditionsDictionary allKeys] count] == 0){
					self.subtitleView.text = NSLocalizedString(@"all_available", nil);
				}
				else{
					self.subtitleView.text = NSLocalizedString(@"custom_filter", nil);
				}
				self.titleView.layer.opacity = 1;
				self.subtitleView.layer.opacity = 1;
			}];
		}];
		[UIView animateWithDuration:0.5 animations:^{
			self.contentScrollView.layer.opacity = 1;
			self.conditionsTableView.layer.opacity = 0;
			[self.contentScrollView scrollRectToVisible:CGRectMake(0, 0, self.contentScrollView.frame.size.width, self.contentScrollView.frame.size.width) animated:YES];
		}];
	}
}

- (void)resetConditionsClicked {
	if([[self.appliedConditionsDictionary allKeys] count] != 0){
		self.appliedConditionsDictionary = [[NSMutableDictionary alloc]init];
		[self.conditionsTableView reloadData];
		[self reloadContentView];
	}
	else{
		self.editingConditions = NO;
		[self updateContentView];
	}
}

- (void)launchTutorial {
	LNTutorialViewPagerController *controller = [[LNTutorialViewPagerController alloc]init];
	[self presentViewController:controller animated:YES completion:nil];
}

- (void)runService {
	PBPebbleCentral *central = [PBPebbleCentral defaultCentral];
	//for(LNPebbleApp *watchApp in self.watchAppArray){
		//[central addAppUUID:[[NSUUID alloc]initWithUUIDString:watchApp.uuidString]];
	//}
	[central setAppUUID:[[NSUUID alloc] initWithUUIDString:[[LNPebbleApp alloc] initWithAppIndex:WATCH_APP_UPSIDE_DOWN].uuidString]];
	
	central.delegate = self;
	[central run];
	
	self.serviceStatus = LIGNITE_SERVICE_STATUS_WAITING_ON_CONNECTION;
	NSLog(@"Now waiting on watch to connect.");
}

- (IBAction)actionButtonPushed:(id)sender {
	UIAlertController *controller = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
	
	UIAlertAction *setPebbleAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"set_pebble", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction* action) {
		[self dismissAppPopup:nil];
		
		LNPebbleViewController *pickerController = [[LNPebbleViewController alloc]init];
		pickerController.sourceListController = self;
		[self presentViewController:pickerController animated:YES completion:nil];
	}];
	UIAlertAction *logoutAction;
	if([LNDataFramework isUserBacker]){
		logoutAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"send_feedback", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction* action){
			FeedbackViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"FEEDBACK"];
			[self showViewController:controller sender:nil];
		}];
	}
	else{
		logoutAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"kickstarter_backer", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction* action){
			[self.view makeToast:NSLocalizedString(@"please_wait", nil)];
			LoginViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"LoginScreen"];
			//[self showViewController:controller sender:nil];
			[self presentViewController:controller animated:YES completion:nil];
		}];
	}
	UIAlertAction *creditsAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"credits", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction* action) {
		CreditsViewController *creditsController = [self.storyboard instantiateViewControllerWithIdentifier:@"CREDITS"];
		[self showViewController:creditsController sender:nil];
	}];
	UIAlertAction *tutorialAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"replay_tutorial", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction* action) {
		[self launchTutorial];
	}];
	UIAlertAction *manageAlertsAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"lignite_settings", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction*action) {
		LNSettingsViewController *alertsController = [[LNSettingsViewController alloc]initWithStyle:UITableViewStyleGrouped];
		[alertsController setAsAlertSettings];
		[self showViewController:alertsController sender:self];
	}];
	
	/*
	NSString *serviceTitle;
	switch(self.serviceStatus){
		case LIGNITE_SERVICE_STATUS_DISCONNECTED:
			serviceTitle = @"service_disconnected";
			break;
		case LIGNITE_SERVICE_STATUS_WAITING_ON_CONNECTION:
			serviceTitle = @"service_waiting";
			break;
		case LIGNITE_SERVICE_STATUS_CONNECTED:
			serviceTitle = @"service_connected";
			break;
	}

	self.servicesAction = [UIAlertAction actionWithTitle:NSLocalizedString(serviceTitle, nil) style:(self.serviceStatus == LIGNITE_SERVICE_STATUS_CONNECTED) ? UIAlertActionStyleDestructive : UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
		switch(self.serviceStatus){
			case LIGNITE_SERVICE_STATUS_CONNECTED:
				[self.currentWatch releaseSharedSession];
				self.serviceStatus = LIGNITE_SERVICE_STATUS_DISCONNECTED;
				NSLog(@"Disconnected from service.");
				break;
			case LIGNITE_SERVICE_STATUS_WAITING_ON_CONNECTION:
				NSLog(@"Stuck, sorry");
				break;
			case LIGNITE_SERVICE_STATUS_DISCONNECTED:
				[self runService];
				break;
		}
	}];
	[controller addAction:self.servicesAction];
	*/
	
	UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"cancel", nil) style:UIAlertActionStyleCancel handler:nil];
	/*
	 UIAlertAction *purchaseAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"purchase_bundles", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
	 NSLog(@"Purchase bundles...");
	 }];
	 
	 if(![LNDataFramework isUserBacker]){
	 [controller addAction:purchaseAction];
	 }
	 */
	[controller addAction:setPebbleAction];
	[controller addAction:logoutAction];
	[controller addAction:tutorialAction];
	[controller addAction:manageAlertsAction];
	[controller addAction:creditsAction];
	[controller addAction:cancelAction];
	
	controller.popoverPresentationController.sourceView = self.view;
	controller.popoverPresentationController.sourceRect = CGRectMake(800, 50, 1.0, 1.0);
	
	[self presentViewController:controller animated:YES completion:nil];
}


- (void)editConditionsClicked {
	self.editingConditions = !self.editingConditions;
	[self updateContentView];
}

/*
 conditionsTableView delegate
 */

- (UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath {
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MyIdentifier"];

	if (cell == nil) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"MyIdentifier"];
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
	}
	
	switch([indexPath section]){
		case 0:{
			NSString *key = [self.possibleConditionsArray objectAtIndex:[indexPath row]];
			cell.textLabel.text = NSLocalizedString(key, nil);
			cell.accessoryType = [self.appliedConditionsDictionary objectForKey:key] ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
			break;
		}
		case 1:{
			NSString *key = [self.possibleBundlesArray objectAtIndex:[indexPath row]];
			cell.textLabel.text = NSLocalizedString(key, nil);
			cell.accessoryType = [self.appliedConditionsDictionary objectForKey:key] ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
			break;
		}
	}
	
	return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	switch(section){
		case 0:
			return NSLocalizedString(@"features", nil);
		case 1:
			return NSLocalizedString(@"bundles", nil);
	}
	return @"oops";
}

- (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section {
	switch(section){
		case 0:
			return [self.possibleConditionsArray count];
		case 1:
			return [self.possibleBundlesArray count];
	}
	return 0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 2;
}

- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath {
	NSString *key;
	switch([indexPath section]){
		case 0:
			key = [self.possibleConditionsArray objectAtIndex:[indexPath row]];
			break;
		case 1:
			key = [self.possibleBundlesArray objectAtIndex:[indexPath row]];
			break;
	}
	if([self.appliedConditionsDictionary objectForKey:key]){
		[self.appliedConditionsDictionary removeObjectForKey:key];
	}
	else{
		[self.appliedConditionsDictionary setObject:@"yes" forKey:key];
	}
	[self.conditionsTableView reloadData];
	[self reloadContentView];
}

//End conditionsTableView delegate

/*
 App preview delegate
 */
- (void)appPreviewTileClickedOnApp:(WatchApp)app {
	NSLog(@"A request has been made to launch app %d", app);

	[self launchPreviewPopupView];
	[self selectAnApp:app];
}
//End app preview delegate

/*
 Pebble central delegate
 */
- (void)pebbleCentral:(PBPebbleCentral*)central watchDidConnect:(PBWatch*)watch isNew:(BOOL)isNew {
	NSLog(@"Got connected watch %@", watch);
	self.currentWatch = watch;
	self.serviceStatus = LIGNITE_SERVICE_STATUS_CONNECTED;
}
//End Pebble central delegate

- (void)reloadContentView {
	[self.contentScrollView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
	[self.contentScrollView scrollRectToVisible:CGRectMake(0, 0, self.contentScrollView.frame.size.width, self.contentScrollView.frame.size.width) animated:YES];
	int spacing = 15;
	int factor = 2;
	int height = self.view.frame.size.height/3;
	int amountOfAdded = 0;
	for(int i = 0; i < APP_COUNT; i++){
		LNPebbleApp *watchApp = [self.watchAppArray objectAtIndex:i];
		BOOL qualifies = YES;
		NSArray *allConditionKeys = self.appliedConditionsDictionary.allKeys;
		NSArray *allWatchAppKeys = [[self.watchAppArray objectAtIndex:i] allKeysDictionary].allKeys;
		for(int i1 = 0; i1 < [allConditionKeys count]; i1++){
			if(![allWatchAppKeys containsObject:[allConditionKeys objectAtIndex:i1]]){
				qualifies = NO;
				break;
			}
		}
		if(qualifies){
			LNPebbleWatch *defaultModel = [LNPreviewBuilder defaultPebble];
			qualifies = [watchApp isCompatibleWithPlatform:defaultModel.platform];
			if(qualifies){
				LNAppPreviewView *previewView = [[LNAppPreviewView alloc]initWithWatchApp:watchApp onFrame:CGRectMake(self.view.frame.size.width/factor * (amountOfAdded % factor), (amountOfAdded/factor) * (height+spacing) - 40, self.view.frame.size.width/factor, height)];
				previewView.delegate = self;
				[self.contentScrollView addSubview:previewView];
				amountOfAdded++;
			}
		}
	}
	if(amountOfAdded == 0){
		UILabel *sadLabel = [[UILabel alloc]initWithFrame:CGRectMake(30, 30, self.contentScrollView.frame.size.width-60, 100)];
		sadLabel.text = NSLocalizedString(@"filter_failed", nil);
		sadLabel.numberOfLines = 0;
		sadLabel.textAlignment = NSTextAlignmentCenter;
		[self.contentScrollView addSubview:sadLabel];
	}
	LNAppPreviewView *lastPreview = self.contentScrollView.subviews.lastObject;
	[self.contentScrollView setContentSize:CGSizeMake(self.view.frame.size.width, lastPreview.frame.origin.y+lastPreview.frame.size.height+20)];
	
	if([[self.appliedConditionsDictionary allKeys] count] == 0){
		[self.resetViewButton setTitle:NSLocalizedString(@"cancel", nil) forState:UIControlStateNormal];
	}
	else{
		[self.resetViewButton setTitle:NSLocalizedString(@"reset_filter", nil) forState:UIControlStateNormal];
	}
}

- (UIStatusBarStyle)preferredStatusBarStyle{
	NSLog(@"Returning default");
	return UIStatusBarStyleDefault;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.watchAppArray = [[NSMutableArray alloc]init];
	for(int i = 0; i < APP_COUNT; i++){
		[self.watchAppArray addObject:[[LNPebbleApp alloc] initWithAppIndex:i]];
	}
	
	[self runService];
	
	[self setNeedsStatusBarAppearanceUpdate];
	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
	
	//self.view.backgroundColor = [UIColor blueColor];
	
	//Initialize the title view
	self.titleView = [[UILabel alloc]initWithFrame:CGRectMake(0, 80, self.view.frame.size.width, 40)];
	self.titleView.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:24.0f];
	self.titleView.text = NSLocalizedString(@"watchfaces_and_watchapps", nil);
	self.titleView.textColor = [UIColor blackColor];
	self.titleView.textAlignment = NSTextAlignmentCenter;
	self.titleView.userInteractionEnabled = YES;
	[self.view addSubview:self.titleView];
	
	//Initialize the subtitle view
	self.subtitleView = [[UILabel alloc]initWithFrame:CGRectMake(0, self.titleView.frame.origin.y+self.titleView.frame.size.height, self.view.frame.size.width, 32)];
	self.subtitleView.text = NSLocalizedString(@"all_available", nil);
	self.subtitleView.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:16.0f];
	self.subtitleView.textColor = [UIColor blackColor];
	self.subtitleView.textAlignment = NSTextAlignmentCenter;
	self.subtitleView.userInteractionEnabled = YES;
	[self.view addSubview:self.subtitleView];
	
	//Add in all of the watchfaces to the content view (basic loading of all, currently)
	
	int yAdjustment = self.subtitleView.frame.origin.y+self.subtitleView.frame.size.height;
	self.contentScrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, yAdjustment, self.view.frame.size.width, self.view.frame.size.height-yAdjustment-70)];
	[self reloadContentView];
	[self.view addSubview:self.contentScrollView];
	
	self.filterViewButton = [[UIButton alloc]initWithFrame:CGRectMake(self.view.frame.size.width/4, self.contentScrollView.frame.origin.y+self.contentScrollView.frame.size.height+14, self.view.frame.size.width/2, 36)];
	[self.filterViewButton setTitle:NSLocalizedString(@"modify_filter", nil) forState:UIControlStateNormal];
	[self.filterViewButton addTarget:self action:@selector(editConditionsClicked) forControlEvents:UIControlEventTouchUpInside];
	self.filterViewButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:18];
	self.filterViewButton.backgroundColor = [UIColor redColor];
	self.filterViewButton.layer.masksToBounds = YES;
	self.filterViewButton.layer.cornerRadius = 4;
	[self.view addSubview:self.filterViewButton];
	
	self.resetViewButton = [[UIButton alloc]initWithFrame:CGRectMake(30, self.filterViewButton.frame.origin.y, self.view.frame.size.width/2 - 60, self.filterViewButton.frame.size.height)];
	[self.resetViewButton setTitle:NSLocalizedString(@"cancel", nil) forState:UIControlStateNormal];
	[self.resetViewButton addTarget:self action:@selector(resetConditionsClicked) forControlEvents:UIControlEventTouchUpInside];
	self.resetViewButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:18];
	self.resetViewButton.backgroundColor = [UIColor redColor];
	self.resetViewButton.layer.masksToBounds = YES;
	self.resetViewButton.layer.cornerRadius = 4;
	self.resetViewButton.layer.opacity = 0;
	self.resetViewButton.userInteractionEnabled = NO;
	[self.view addSubview:self.resetViewButton];
	
	//Set up all possible conditions
	NSData *data = [[NSData alloc]initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"possibilities" ofType:@"json"]];
	NSError *error;
	NSDictionary *tagsDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
	
	self.possibleConditionsArray = [[NSArray alloc]initWithArray:[tagsDictionary objectForKey:@"possible_tags"]];
	self.possiblePlatformsArray = [[NSArray alloc]initWithArray:[tagsDictionary objectForKey:@"possible_platforms"]];
	self.possibleBundlesArray = [[NSArray alloc]initWithArray:[tagsDictionary objectForKey:@"possible_bundles"]];
	
	self.appliedConditionsDictionary = [[NSMutableDictionary alloc]init];
	
	//Add in the conditions table view
	self.conditionsTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, self.contentScrollView.frame.origin.y, self.contentScrollView.frame.size.width, self.contentScrollView.frame.size.height) style:UITableViewStyleGrouped];
	self.conditionsTableView.delegate = self;
	self.conditionsTableView.dataSource = self;
	self.conditionsTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLineEtched;
	self.conditionsTableView.layer.opacity = 0;
	[self.view addSubview:self.conditionsTableView];

	//Set up the bar button items
	UIImage *image = [UIImage imageNamed:@"more_icon.png"];
	UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(10, 7, image.size.width/3, image.size.height/3)];
	button.contentMode = UIViewContentModeScaleAspectFit;
	[button setImage:image forState:UIControlStateNormal];
	[button addTarget:self action:@selector(actionButtonPushed:) forControlEvents:UIControlEventTouchUpInside];
	
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:button];
	
	self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:NSLocalizedString(@"logout", nil) style:UIBarButtonItemStylePlain target:self action:@selector(topLeftPushed:)];
    self.title = @"Lignite";
	
	//If they are a backer, verify that their account is legit
    if([LNDataFramework isUserBacker]){
        NSString *post = [NSString stringWithFormat:@"username=%@&accessToken=%@", [LNDataFramework getUsername], [LNDataFramework getUserToken]];
		
		NSLog(@"Checking for %@", post);
		        
        NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
        
        NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[postData length]];
        
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
        [request setURL:[NSURL URLWithString:@"https://api.lignite.me/v2/checkaccesstoken/index.php"]];
        [request setHTTPMethod:@"POST"];
        [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
        [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
        [request setHTTPBody:postData];
        
        self.verifyConnection = [[NSURLConnection alloc]initWithRequest:request delegate:self];
        [self.verifyConnection start];
    }
	
	//If they aren't a backer, add a restore button
    if(![LNDataFramework isUserBacker]){
        self.navigationItem.leftBarButtonItem.title = NSLocalizedString(@"restore", nil);
    }
	
	self.coverView = [[UIView alloc]initWithFrame:self.view.frame];
	
	self.cancelIconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cancel_icon.png"]];
	self.cancelIconView.frame = CGRectMake(0, -100, 10, 10);
	self.cancelIconView.contentMode = UIViewContentModeScaleAspectFit;
	[self.view addSubview:self.cancelIconView];
	
	UITapGestureRecognizer *cancelTapRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(dismissAppPopup:)];
	self.cancelIconView.userInteractionEnabled = YES;
	[self.cancelIconView addGestureRecognizer:cancelTapRecognizer];
	
	self.pageViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"PageViewController"];
	self.pageViewController.dataSource = self;
	
	self.pageViewController.view.layer.cornerRadius = 8.0;
	self.pageViewController.view.layer.masksToBounds = YES;
	
	LNAppListViewController *startingViewController = [self viewControllerAtIndex:WATCH_APP_TIMEZONES];
	NSArray *viewControllers = @[startingViewController];
	[self.pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
	
	self.pageViewController.view.frame = CGRectMake(viewFrameXAdjust, viewFrameYAdjust, self.pageViewController.view.frame.size.width, 0);
	
	[self addChildViewController:_pageViewController];
	[self.view addSubview:_pageViewController.view];
	[self.pageViewController didMoveToParentViewController:self];
	
	for (UIScrollView *view in self.pageViewController.view.subviews) {
		if ([view isKindOfClass:[UIScrollView class]]) {
			view.scrollEnabled = NO;
		}
	}
	
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	
	BOOL pebbleResult = [defaults boolForKey:@"key-set-pebble"];
	if(!pebbleResult){
		self.setPebbleAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"pebble", nil)
														message:NSLocalizedString(@"would_you_like_to_set_pebble", nil)
													   delegate:self
											  cancelButtonTitle:NSLocalizedString(@"no", nil)
											  otherButtonTitles:NSLocalizedString(@"yes", nil), nil];
		[self.setPebbleAlert show];
		[defaults setBool:YES forKey:@"key-set-pebble"];
		[defaults synchronize];
	}
	/*
	for (UIScrollView *view in self.pageViewController.view.subviews) {
		
		if ([view isKindOfClass:[UIScrollView class]]) {
			
			view.scrollEnabled = NO;
		}
	}
	 */
	//[self launchTutorial];
}

- (void)viewDidDisappear:(BOOL)animated {
	NSLog(@"Releasing session with watch %@", self.currentWatch);
	[self.currentWatch releaseSharedSession];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Page View Controller Data Source


- (void)selectAnApp:(WatchApp)app {
	// Instead get the view controller of the first page
	LNAppListViewController *newInitialViewController = (LNAppListViewController *)[self viewControllerAtIndex:app];
	NSArray *initialViewControllers = [NSArray arrayWithObject:newInitialViewController];
	// Do the setViewControllers: again but this time use direction animation:
	[self.pageViewController setViewControllers:initialViewControllers direction:UIPageViewControllerNavigationDirectionReverse animated:NO completion:nil];
}
/*
- (void)selectAnApp:(WatchApp)app {
    LNAppListViewController *startingViewController = [self viewControllerAtIndex:app];
    NSArray *viewControllers = @[startingViewController];
    [self.pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionReverse animated:NO completion:nil];
    self.currentIndex = app;
    [self.pageViewController didMoveToParentViewController:self];
}
*/
- (LNAppListViewController *)viewControllerAtIndex:(NSUInteger)index{
    // Create a new view controller and pass suitable data.
    LNAppListViewController *pageContentViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"AppViewController"];
	pageContentViewController.watchApp = [[LNPebbleApp alloc]initWithAppIndex:(WatchApp)index];
    pageContentViewController.owns_app = controller_owns_app[index];
	pageContentViewController.sourcePageViewController = self.pageViewController;
	pageContentViewController.sourceViewController = self;
	pageContentViewController.connectedWatch = self.currentWatch;
    //pageContentViewController.sourceController = self;
    self.currentIndex = index;
        
    return pageContentViewController;
}

- (NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController{
    return APP_COUNT;
}

- (NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController{
    return 0;
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController{
    NSUInteger index = ((LNAppListViewController*) viewController).watchApp.watchApp;
    
    if ((index == 0) || (index == NSNotFound)) {
        return nil;
    }
    
    index--;
    return [self viewControllerAtIndex:index];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController{
    NSUInteger index = ((LNAppListViewController*) viewController).watchApp.watchApp;
    
    if (index == NSNotFound) {
        return nil;
    }
    
    index++;
    if (index > APP_COUNT-1) {
        return nil;
    }
    return [self viewControllerAtIndex:index];
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
