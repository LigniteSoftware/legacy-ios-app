//
//  LoginViewController.h
//  Lignite
//
//  Created by Edwin Finch on 2015-05-18.
//  Copyright (c) 2015 Edwin Finch. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoginViewController : UIViewController<NSURLConnectionDelegate, UITextFieldDelegate>

/*
 For backer login. It follows a simple check with the server to make sure the credentials are legit,
 and if it gets a valid response it will handle accordingly.
 */

@property UIView *rootView;

@property UILabel *titleLabel, *subtitleLabel, *descriptionLabel;
@property UITextField *usernameTextField, *passwordTextField;
@property UIButton *accessButton, *checkcodeButton, *noAccountButton, *resetButton, *findAccountButton;
@property UIImageView *logoView;

@end
