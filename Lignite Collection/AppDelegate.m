//
//  AppDelegate.m
//  Lignite Collection
//
//  Created by Edwin Finch on 2015-05-02.
//  Copyright (c) 2015 Edwin Finch. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>
#import "AppDelegate.h"
#import "LNDataFramework.h"

@interface AppDelegate () <CLLocationManagerDelegate>

/*
@property (nonatomic, retain) CLLocationManager *locationManager;
@property (nonatomic)CLLocation *currentLocation;
 */

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
	
	NSLog(@"Setting up defaults.");
	[LNDataFramework setupDefaults];
	
	//NO
	UIPageControl *pageControl = [UIPageControl appearance];
	pageControl.pageIndicatorTintColor = [UIColor clearColor];
	pageControl.currentPageIndicatorTintColor = [UIColor clearColor];
	pageControl.backgroundColor = [UIColor clearColor];
	
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

/*
- (void)fetchWeather:(NSTimer*)timer {
    NSLog(@"Fetching weather...");
	//Fetches the weather from OpenWeatherMap
	//[self.weatherAPI currentWeatherByCoordinate:(CLLocationCoordinate2D) withCallback:<#^(NSError *error, NSDictionary *result)callback#>]
    [self.weatherAPI currentWeatherByCoordinate:[self.currentLocation coordinate] withCallback:^(NSError *error, NSDictionary *result) {
        if (error) {
            // handle the error
            NSLog(@"An error occurred: %@", [error localizedDescription]);
            return;
        }
        
        // The data is ready
        NSString *cityName = result[@"name"];
        NSNumber *currentTemp = result[@"main"][@"temp"];
        NSLog(@"Got %@'s data: %@", cityName, currentTemp);
    }];
}


- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
	switch (status) {
		case kCLAuthorizationStatusNotDetermined:
			NSLog(@"User still thinking..");
			break;
		case kCLAuthorizationStatusDenied:
			NSLog(@"User hates you");
			break;
		case kCLAuthorizationStatusAuthorizedWhenInUse:
		case kCLAuthorizationStatusAuthorizedAlways:
			[self.locationManager startUpdatingLocation];
			NSLog(@"Good to fucking go");
			break;
		default:
			NSLog(@"Got weird status: %d", (int)status);
			break;
	}
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
	NSLog(@"OldLocation %f %f", oldLocation.coordinate.latitude, oldLocation.coordinate.longitude);
	NSLog(@"NewLocation %f %f", newLocation.coordinate.latitude, newLocation.coordinate.longitude);
	self.currentLocation = newLocation;
	[self fetchWeather:nil];
}
 */

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
	
	//Uncomment this to have tasks run in the background
	//[application beginBackgroundTaskWithExpirationHandler:^{}];
	
//[NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(tick) userInfo:nil repeats:YES];
//
}

- (void)tick {
	NSLog(@"I'm alive");
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
	NSLog(@"Terminating...");
}

@end
