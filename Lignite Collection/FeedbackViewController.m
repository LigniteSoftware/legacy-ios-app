//
//  FeedbackViewController.m
//  Lignite
//
//  Created by Edwin Finch on 2015-05-18.
//  Copyright (c) 2015 Edwin Finch. All rights reserved.
//

#import "FeedbackViewController.h"
#import "LNDataFramework.h"
#import "UIView+Toast.h"

@interface FeedbackViewController ()

@property NSArray *whatTypeData;

@end

@implementation FeedbackViewController

//To dismiss the keyboard
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

//Calls to dismiss keyboard
- (IBAction)makeKeyboardDisappear:(id)sender {
    [self textFieldShouldReturn:self.detailsValueTextField];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self.howImportantValueSlider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    [self textFieldShouldReturn:self.detailsValueTextField];
    self.detailsValueTextField.delegate = self;
	
	//Recognizer for dismissing keyboard
    UITapGestureRecognizer *keyboardGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(makeKeyboardDisappear:)];
    [self.view addGestureRecognizer:keyboardGestureRecognizer];

    self.howImportantTitleLabel.text = NSLocalizedString(@"importance", "how important the issue is");
    self.whatTypeTitleLabel.text = NSLocalizedString(@"type", nil);
    self.detailsTitleLabel.text = NSLocalizedString(@"description", nil);
    self.disclaimerView.text = NSLocalizedString(@"feedback_disclaimer", nil);
    [self.saveButton setTitle:NSLocalizedString(@"send", nil)];
    
    self.whatTypeData = [NSArray arrayWithObjects:NSLocalizedString(@"type_crash", nil), NSLocalizedString(@"type_bug", nil), NSLocalizedString(@"type_design", nil), NSLocalizedString(@"type_feature", nil), NSLocalizedString(@"type_other", nil), nil];
    self.whatTypeValuePicker.delegate = self;
    self.whatTypeValuePicker.dataSource = self;
	
	[self.disclaimerView scrollRangeToVisible:NSMakeRange(0, 0)];
	
	self.navigationItem.rightBarButtonItem.title = NSLocalizedString(@"send", nil);
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView*)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView*)pickerView numberOfRowsInComponent:(NSInteger)component {
    return self.whatTypeData.count;
}

- (NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return self.whatTypeData[row];
}

- (IBAction)sliderValueChanged:(UISlider *)sender {
    self.howImportantValueLabel.text = [NSString stringWithFormat:@"%d", (int)floor(sender.value)];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//When send button is pressed
- (IBAction)saveButtonPressed:(id)sender {
	//Get rid of the stupid ' that was causing errors
    NSString *encodedString = [self.detailsValueTextField.text stringByReplacingOccurrencesOfString:@"'" withString:@""];
	//Setup the post string
    NSString *post = [NSString stringWithFormat:@"username=%@&currentDevice=%@&accessToken=%@&type=%@&details=%@&importance=%d", [LNDataFramework getUsername], [LNDataFramework getCurrentDevice], [LNDataFramework getUserToken], self.whatTypeData[[self.whatTypeValuePicker selectedRowInComponent:0]], encodedString, (int)floor(self.howImportantValueSlider.value)];

    NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[postData length]];
    //Send her off
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:@"https://api.lignite.me/v2/feedback/index.php"]];
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];
	
	//Start connection
    NSURLConnection *connection = [[NSURLConnection alloc]initWithRequest:request delegate:self];
    [connection start];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSLog(@"Error %@", [error localizedDescription]);
	//If it failed let the user know that it didn't even try
    NSString *failedDescription = [[NSString alloc]initWithFormat:NSLocalizedString(@"feedback_failed_send", nil), [error localizedDescription]];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"failed", nil)
                                                    message:failedDescription
                                                   delegate:nil
										  cancelButtonTitle:NSLocalizedString(@"okay", nil)
                                          otherButtonTitles:nil];
    [alert show];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
    NSError *error;
    NSDictionary *jsonResult = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
    NSNumber *status = [jsonResult objectForKey:@"status"];
    if([status isEqual:@200]){
		//If the server loved it, let'em know
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"success", nil)
                                                        message:NSLocalizedString(@"feedback_success", nil)
                                                       delegate:nil
                                              cancelButtonTitle:NSLocalizedString(@"awesome", nil)
                                              otherButtonTitles:nil];
        [alert show];
    }
    else{
		//If the server hated it, let'em know
        NSString *localizedError = [jsonResult objectForKey:@"localized_message"];
        NSString *failedDescription = [[NSString alloc]initWithFormat:NSLocalizedString(@"feedback_failed_to_hit_server", nil), localizedError];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"failed", nil)
                                                        message:failedDescription
                                                       delegate:nil
                                              cancelButtonTitle:NSLocalizedString(@"okay", nil)
                                              otherButtonTitles:nil];
        [alert show];
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection*)connection{
    NSLog(@"Finished, boi");
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
