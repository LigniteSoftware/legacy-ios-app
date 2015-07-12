//
//  FeedbackViewController.h
//  Lignite
//
//  Created by Edwin Finch on 2015-05-18.
//  Copyright (c) 2015 Edwin Finch. All rights reserved.
//

#import "ViewController.h"

@interface FeedbackViewController : UIViewController <UITextFieldDelegate, UIPickerViewDataSource, UIPickerViewDelegate, NSURLConnectionDelegate>

@property IBOutlet UILabel *whatTypeTitleLabel, *howImportantTitleLabel, *detailsTitleLabel, *howImportantValueLabel, *feedbackPolicyLabel;
@property IBOutlet UIPickerView *whatTypeValuePicker;
@property IBOutlet UISlider *howImportantValueSlider;
@property IBOutlet UITextField *detailsValueTextField;
@property IBOutlet UIBarButtonItem *saveButton;

- (IBAction)saveButtonPressed:(id)sender;

@end
