//
//  LoginViewController.m
//  Lignite
//
//  Created by Edwin Finch on 2015-05-18.
//  Copyright (c) 2015 Edwin Finch. All rights reserved.
//

#import "LoginViewController.h"
#import "LNDataFramework.h"
#import "UIView+Toast.h"
#import "LNAppListViewController.h"
#import "LNAppListController.h"

@interface LoginViewController ()

@property NSURLConnection *loginConnection, *userDataConnection;

@end

@implementation LoginViewController

- (IBAction)checkcodeButtonHit:(id)sender {    
    [LNDataFramework setUsername:self.passwordTextField.text];
	
	//Set up the post request, containing the email and password for account and current device for support and analytics.
    NSString *post = [NSString stringWithFormat:@"email=%@&password=%@&currentDevice=%@", self.usernameTextField.text, [self.passwordTextField.text uppercaseString], [LNDataFramework getCurrentDevice]];
    
    NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[postData length]];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:@"https://api.lignite.me/v2/login/ios/index.php"]];
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];
	
	//Send er' off
    self.loginConnection = [[NSURLConnection alloc]initWithRequest:request delegate:self];
    [self.loginConnection start];
}

//Push the main navigation controller. We must do this to refresh everything (a little hacky, sorry)
- (void)pushMainWindow {
	UINavigationController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"rootNavController"];
	[self showDetailViewController:controller sender:self];
}

//Go to reset account
- (IBAction)resetCodeLinkHit:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://www.lignite.me/reset/"]];
}

- (IBAction)loginButtonHit:(id)sender {
	[self pushMainWindow];
}

- (IBAction)noAccountLinkHit:(id)sender {
	[self pushMainWindow];
}

- (IBAction)forgotPasswordLinkHit:(id)sender {
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://www.lignite.me/code/"]];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSLog(@"Error %@", [error localizedDescription]);
	//If the connection failed for any general reason, let them know
    NSString *failedDescription = [[NSString alloc]initWithFormat:NSLocalizedString(@"failed_to_send", nil), [error localizedDescription]];
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"failed", nil)
                                                    message:failedDescription
                                                   delegate:nil
										  cancelButtonTitle:NSLocalizedString(@"okay", nil)
                                          otherButtonTitles:nil];
    [alert show];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
	//If got data in the login connection
    if([connection isEqual:self.loginConnection]){
        NSError *error;
        NSDictionary *jsonResult = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
        NSNumber *status = [jsonResult objectForKey:@"status"];
        NSLog(@"Got login result of %@", jsonResult);
		//Is good to go
        if([status isEqual:@200]){
			//Make a request to get the user's info, and fire it off
            NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
            NSString *requestURL = [[NSString alloc]initWithFormat:@"https://api.lignite.me/v2/backer/get_info_with_code.php?username=%@", [LNDataFramework getUsername]];
            [request setURL:[NSURL URLWithString:requestURL]];
            [request setHTTPMethod:@"GET"];
            [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
            
            self.userDataConnection = [[NSURLConnection alloc]initWithRequest:request delegate:self];
            [self.userDataConnection start];
			
			//Save the account token (used for account verification)
            [LNDataFramework setUserToken:[jsonResult objectForKey:@"token"]];
        }
        else{
			//Handle various other errors
            if([status isEqual:@401]){
                NSString *failedDescription = [[NSString alloc]initWithFormat:NSLocalizedString(@"login_failed_taken", nil)];
				UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"now_now", nil)
                                                                message:failedDescription
                                                               delegate:nil
                                                      cancelButtonTitle:NSLocalizedString(@"okay", nil)
                                                      otherButtonTitles:nil];
                [alert show];
            }
            else if([status isEqual:@404]){
                NSString *failedDescription = [[NSString alloc]initWithFormat:NSLocalizedString(@"login_failed_404", nil)];
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"silly_goose", nil)
                                                                message:failedDescription
                                                               delegate:nil
                                                      cancelButtonTitle:NSLocalizedString(@"okay", nil)
                                                      otherButtonTitles:nil];
                [alert show];
            }
            else{
                NSString *localizedMessage = [jsonResult objectForKey:@"localized_message"];
                NSString *failedDescription = [[NSString alloc]initWithFormat:NSLocalizedString(@"login_not_sure", nil), localizedMessage];
                
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"well_thats_embarassing", nil)
                                                                message:failedDescription
                                                               delegate:nil
                                                      cancelButtonTitle:NSLocalizedString(@"okay", nil)
                                                      otherButtonTitles:nil];
                [alert show];
            }
        }
    }
    else{
		//Otherwise if it's the user data connection
        NSError *error = nil;
        NSDictionary *object = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
        
        if(error){
            NSLog(@"Error parsing user data: %@", [error localizedDescription]);
        }
        
        NSString *name = NSLocalizedString(@"my_friend", nil);
        if([object isKindOfClass:[NSDictionary class]]){
            NSDictionary *results = object;
            name = [results objectForKey:@"name"];
			
			//Save the data
            [LNDataFramework setUserData:results];
            [LNDataFramework setUserLoggedIn:[LNDataFramework getUsername] :YES];
        }
        else{
            NSLog(@"Error with kind of class");
        }
		
		//Set the check code button as disabled and enable the user to login :)
		[UIView animateWithDuration:0.4f animations:^{
			UIColor *lightGrayColour = [UIColor colorWithRed:0.81 green:0.81 blue:0.81 alpha:1.0];;
			self.checkcodeButton.backgroundColor = lightGrayColour;
			self.checkcodeButton.layer.borderColor = lightGrayColour.CGColor;
			self.checkcodeButton.enabled = NO;
			self.accessButton.backgroundColor = [UIColor grayColor];
			self.accessButton.layer.borderColor = [UIColor grayColor].CGColor;
			self.accessButton.enabled = YES;
			self.descriptionLabel.text = [[NSString alloc]initWithFormat:@"Welcome %@!", name];
		}];
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection*)connection{
    NSLog(@"Finished, boi");
}

//Dismiss keyboard
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (IBAction)makeKeyboardDisappear:(id)sender {
    [self textFieldShouldReturn:self.passwordTextField];
    [self textFieldShouldReturn:self.usernameTextField];
	[UIView animateWithDuration:0.2f animations:^(void){
		self.rootView.frame = CGRectMake(self.rootView.frame.origin.x, self.view.frame.origin.y, self.rootView.frame.size.width, self.rootView.frame.size.height);
	}];
}

//Detect keyboard shown and change the view accordingly to fit the new "dimemsions"
- (void)keyboardWasShown:(NSNotification *)notification{
	// Get the size of the keyboard.
	CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
	
	//Given size may not account for screen rotation
	int height = MIN(keyboardSize.height,keyboardSize.width);
	[UIView animateWithDuration:0.2f animations:^(void){
		self.rootView.frame = CGRectMake(self.rootView.frame.origin.x, -height/1.5, self.rootView.frame.size.width, self.rootView.frame.size.height);
	}];
}

- (void)viewDidLoad {
    [super viewDidLoad];
	
	//Set up the root view for items (so we can adjust for keyboard)
	self.rootView = [[UIView alloc]initWithFrame:self.view.frame];
	[self.view addSubview:self.rootView];
	
	/*
	 Below lies uncommented setup for the login view, which just creates all elements on the screen.
	 Good luck.
	 */
	
	//NOTE: The logo frame here is completely different from the logo frame below, becuse Philipp wanted it centred.
	CGRect logo_frame = CGRectMake(self.view.frame.size.width/2 - self.view.frame.size.width/2/2, self.view.frame.size.height/10, self.view.frame.size.width/2, self.view.frame.size.height/4);
	self.descriptionLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, logo_frame.origin.y + logo_frame.size.height, self.view.frame.size.width, 22)];
	self.descriptionLabel.textColor = [UIColor blackColor];
	self.descriptionLabel.font = [UIFont fontWithName:@"HelveticaNeue-Thin" size:16.0f];
	self.descriptionLabel.text = NSLocalizedString(@"enter_details", nil);
	self.descriptionLabel.textAlignment = NSTextAlignmentCenter;
	[self.rootView addSubview:self.descriptionLabel];
	
	self.logoView = [[UIImageView alloc]initWithFrame:CGRectMake(self.view.frame.size.width/2 - self.view.frame.size.width/2/2, 20, self.view.frame.size.width/2, self.descriptionLabel.frame.origin.y-20)];
	[self.logoView setImage:[UIImage imageNamed:@"Lignite-BETA-logo.png"]];
	self.logoView.contentMode = UIViewContentModeScaleAspectFit;
	[self.rootView addSubview:self.logoView];
	
	CGRect description_frame = self.descriptionLabel.frame;
	self.usernameTextField = [[UITextField alloc]initWithFrame:CGRectMake(10, description_frame.origin.y + description_frame.size.height + 16, self.view.frame.size.width-20, 30)];
	self.usernameTextField.borderStyle = UITextBorderStyleRoundedRect;
	self.usernameTextField.font = [UIFont fontWithName:@"HelveticaNeue-Thin" size:16.0f];
	self.usernameTextField.autocorrectionType = UITextAutocorrectionTypeNo;
	self.usernameTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
	self.usernameTextField.keyboardType = UIKeyboardTypeEmailAddress;
	[self.rootView addSubview:self.usernameTextField];
	
	CGRect username_frame = self.usernameTextField.frame;
	self.passwordTextField = [[UITextField alloc]initWithFrame:CGRectMake(username_frame.origin.x, username_frame.origin.y + username_frame.size.height + 10, username_frame.size.width, username_frame.size.height)];
	self.passwordTextField.borderStyle = self.usernameTextField.borderStyle;
	self.passwordTextField.font = self.usernameTextField.font;
	self.passwordTextField.secureTextEntry = YES;
	[self.rootView addSubview:self.passwordTextField];
	
	CGRect password_frame = self.passwordTextField.frame;
	self.checkcodeButton = [[UIButton alloc]initWithFrame:CGRectMake(self.view.frame.size.width/6, password_frame.origin.y + password_frame.size.height + 20, self.view.frame.size.width/6 * 2 - 20, 28)];
	self.checkcodeButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:14.0f];
	[self.checkcodeButton addTarget:self action:@selector(checkcodeButtonHit:) forControlEvents:UIControlEventTouchUpInside];
	[self.checkcodeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	self.checkcodeButton.layer.masksToBounds = YES;
	self.checkcodeButton.backgroundColor = [UIColor grayColor];
	self.checkcodeButton.layer.borderWidth = 0.0f;
	self.checkcodeButton.layer.cornerRadius = 6.0f;
	self.checkcodeButton.layer.borderColor = self.checkcodeButton.backgroundColor.CGColor;
	[self.rootView addSubview:self.checkcodeButton];
	
	CGRect check_frame = self.checkcodeButton.frame;
	self.accessButton = [[UIButton alloc]initWithFrame:CGRectMake(self.view.frame.size.width/2 + 20, check_frame.origin.y, check_frame.size.width, check_frame.size.height)];
	self.accessButton.titleLabel.font = self.checkcodeButton.titleLabel.font;
	[self.accessButton addTarget:self action:@selector(loginButtonHit:) forControlEvents:UIControlEventTouchUpInside];
	[self.accessButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	self.accessButton.enabled = NO;
	self.accessButton.layer.masksToBounds = YES;
	self.accessButton.backgroundColor = [UIColor colorWithRed:0.81 green:0.81 blue:0.81 alpha:1.0];
	self.accessButton.layer.borderWidth = 0.0f;
	self.accessButton.layer.cornerRadius = 6.0f;
	self.accessButton.layer.borderColor = self.accessButton.backgroundColor.CGColor;
	[self.rootView addSubview:self.accessButton];
	
	self.resetButton = [[UIButton alloc]initWithFrame:CGRectMake(10, check_frame.origin.y + check_frame.size.height + 22, self.view.frame.size.width - 20, 20)];
	self.resetButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Thin" size:14.0f];
	self.resetButton.titleLabel.numberOfLines = 0;
	self.resetButton.titleLabel.textAlignment = NSTextAlignmentCenter;
	[self.resetButton addTarget:self action:@selector(resetCodeLinkHit:) forControlEvents:UIControlEventTouchUpInside];
	[self.resetButton setTitleColor:[UIColor colorWithRed:0.00 green:0.64 blue:1.00 alpha:1.0] forState:UIControlStateNormal];
	[self.rootView addSubview:self.resetButton];
	
	CGRect reset_frame = self.resetButton.frame;
	self.noAccountButton = [[UIButton alloc]initWithFrame:CGRectMake(10, reset_frame.origin.y + reset_frame.size.height + 20, self.view.frame.size.width - 20, 40)];
	self.noAccountButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Thin" size:14.0f];
	self.noAccountButton.titleLabel.numberOfLines = 0;
	self.noAccountButton.titleLabel.textAlignment = NSTextAlignmentCenter;
	[self.noAccountButton addTarget:self action:@selector(noAccountLinkHit:) forControlEvents:UIControlEventTouchUpInside];
	[self.noAccountButton setTitleColor:[UIColor colorWithRed:0.00 green:0.64 blue:1.00 alpha:1.0] forState:UIControlStateNormal];
	[self.rootView addSubview:self.noAccountButton];
	
	CGRect no_account_frame = self.noAccountButton.frame;
	self.findAccountButton = [[UIButton alloc]initWithFrame:CGRectMake(no_account_frame.origin.x, no_account_frame.origin.y + no_account_frame.size.height, no_account_frame.size.width, 40)];
	self.findAccountButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Thin" size:14.0f];
	self.findAccountButton.titleLabel.numberOfLines = 0;
	self.findAccountButton.titleLabel.textAlignment = NSTextAlignmentCenter;
	[self.findAccountButton addTarget:self action:@selector(forgotPasswordLinkHit:) forControlEvents:UIControlEventTouchUpInside];
	[self.findAccountButton setTitleColor:[UIColor colorWithRed:0.00 green:0.64 blue:1.00 alpha:1.0] forState:UIControlStateNormal];
	[self.rootView addSubview:self.findAccountButton];
	
	//Localize everything
    [self.checkcodeButton setTitle:NSLocalizedString(@"check", "check code") forState:UIControlStateNormal];
    [self.accessButton setTitle:NSLocalizedString(@"login", nil) forState:UIControlStateNormal];
    self.usernameTextField.placeholder = NSLocalizedString(@"username", nil);
    self.passwordTextField.placeholder = NSLocalizedString(@"password", nil);
    [self.resetButton setTitle:NSLocalizedString(@"cant_login", "for resetting account") forState:UIControlStateNormal];
    [self.noAccountButton setTitle:NSLocalizedString(@"no_account", "for non backers") forState:UIControlStateNormal];
	[self.findAccountButton setTitle:NSLocalizedString(@"no_password", "for idiots that forget their passwords") forState:UIControlStateNormal];
	
	//If the user is logged in for some weird reason, set up the view to be ready for them
    if([LNDataFramework isUserLoggedIn]){
        NSDictionary *userData = [LNDataFramework getUserData];
        if(!userData){
            NSLog(@"User data is nil! Returning...");
            self.descriptionLabel.text = @"Weird issue parsing your data :/";
            return;
        }
        NSLog(@"Got %@", userData);
        NSString *name = [userData objectForKey:@"name"];
        NSString *email = [LNDataFramework getEmail];
        NSString *password = [LNDataFramework getUsername];
        self.checkcodeButton.enabled = NO;
        self.accessButton.enabled = YES;
        self.usernameTextField.text = email;
        self.passwordTextField.text = password;
        self.descriptionLabel.text = [[NSString alloc]initWithFormat:NSLocalizedString(@"welcome_back", "welcome back %@"), name];
        self.usernameTextField.enabled = NO;
        self.passwordTextField.enabled = NO;
    }
	//Gesture recognizer to dismiss keyboard
    UITapGestureRecognizer *keyboardGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(makeKeyboardDisappear:)];
    [self.view addGestureRecognizer:keyboardGestureRecognizer];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(keyboardWasShown:)
												 name:UIKeyboardDidShowNotification
											   object:nil];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    // Prevent crashing undo bug – see note below.
    if(range.length + range.location > textField.text.length)
    {
        return NO;
    }
    
    NSUInteger newLength = [textField.text length] + [string length] - range.length;
    return newLength <= 6;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
