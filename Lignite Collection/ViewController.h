//
//  ViewController.h
//  Lignite Collection
//
//  Created by Edwin Finch on 2015-05-02.
//  Copyright (c) 2015 Edwin Finch. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController<UIDocumentInteractionControllerDelegate, NSURLConnectionDelegate>

@property IBOutlet UIImageView *imageView;
@property IBOutlet UILabel *appTitleLabel;
@property IBOutlet UITextView *appDescriptionLabel;
@property IBOutlet UIButton *installButton, *settingsButton;

@end

