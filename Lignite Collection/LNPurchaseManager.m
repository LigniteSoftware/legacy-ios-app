//
//  LNPurchaseManager.m
//  Lignite
//
//  Created by Edwin Finch on 11/9/15.
//  Copyright © 2015 Edwin Finch. All rights reserved.
//

#import <StoreKit/StoreKit.h>
#import "LNPurchaseManager.h"

@interface LNPurchaseManager() <SKProductsRequestDelegate, SKPaymentTransactionObserver>

@end

@implementation LNPurchaseManager

- (BOOL)ownsWatchapp:(LNPebbleApp*)watchApp {
	if(watchApp.isKickstarter && [LNDataFramework isUserLoggedIn] && [LNDataFramework isUserBacker]){
		return YES;
	}
	return NO;
}

@end
