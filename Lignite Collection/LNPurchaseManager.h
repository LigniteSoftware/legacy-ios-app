//
//  LNPurchaseManager.h
//  Lignite
//
//  Created by Edwin Finch on 11/9/15.
//  Copyright © 2015 Edwin Finch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LNPebbleApp.h"
#import "LNDataFramework.h"

@interface LNPurchaseManager : NSObject

- (BOOL)ownsWatchapp:(LNPebbleApp*)watchApp;

@end
