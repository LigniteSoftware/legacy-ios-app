//
//  LoginViewController.h
//  Lignite
//
//  Created by Edwin Finch on 2015-05-18.
//  Copyright (c) 2015 Edwin Finch. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoginViewController : UIViewController<NSURLConnectionDelegate, UITextFieldDelegate>

@property IBOutlet UILabel *titleLabel, *subtitleLabel, *descriptionLabel, *resetLabel;
@property IBOutlet UITextField *usernameTextField, *passwordTextField;
@property IBOutlet UIButton *accessButton, *checkcodeButton, *noAccountButton;

@end
