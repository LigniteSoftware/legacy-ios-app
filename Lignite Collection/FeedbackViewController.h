//
//  FeedbackViewController.h
//  Lignite
//
//  Created by Edwin Finch on 2015-05-18.
//  Copyright (c) 2015 Edwin Finch. All rights reserved.
//

#import "LNAppListViewController.h"

@interface FeedbackViewController : UIViewController <UITextFieldDelegate, UIPickerViewDataSource, UIPickerViewDelegate, NSURLConnectionDelegate>

/*
 The feedback view controller handles sending backer's feedback to our server.
 In reality, we don't look at their feedback very often. When we do though,
 we REALLY do take it into consideration and have made many changes based off of it.
 */

@property IBOutlet UILabel *whatTypeTitleLabel, *howImportantTitleLabel, *detailsTitleLabel, *howImportantValueLabel, *feedbackPolicyLabel;
@property IBOutlet UITextView *disclaimerView;
@property IBOutlet UIPickerView *whatTypeValuePicker;
@property IBOutlet UISlider *howImportantValueSlider;
@property IBOutlet UITextField *detailsValueTextField;
@property IBOutlet UIBarButtonItem *saveButton;

- (IBAction)saveButtonPressed:(id)sender;

@end
