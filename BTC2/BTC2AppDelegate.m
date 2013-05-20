//
//  BTC2AppDelegate.m
//  BTC2
//
//  Created by Joakim Fernstad on 5/17/13.
//  Copyright (c) 2013 Joakim Fernstad. All rights reserved.
//

#import "BTC2AppDelegate.h"
#import "BTC2DebugViewController.h"
#import "BTC2WorldViewController.h"

@implementation BTC2AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
//    UIStoryboard* story = [UIStoryboard storyboardWithName:@"Storyboard" bundle:nil];
//    BTC2DebugViewController* vc = [story instantiateInitialViewController];

    UIStoryboard* story = [UIStoryboard storyboardWithName:@"Storyboard" bundle:nil];
    BTC2WorldViewController* vc = [story instantiateInitialViewController];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.window.rootViewController = vc;
    [self.window makeKeyAndVisible];

    // Setup defaults
    
    if (![[NSUserDefaults standardUserDefaults] objectForKey:kUserDeviceNameKey]) {
        [[NSUserDefaults standardUserDefaults] setObject:[UIDevice currentDevice].name forKey:kUserDeviceNameKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    int64_t delta = (int64_t)(1.0e9 * 0.5); // 2 seconds
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, delta), dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:kPeripheralAddedNotification object:@"HaxxorRobot"]; // [[NSUserDefaults standardUserDefaults] objectForKey:kUserDeviceNameKey]
    });

//    delta = (int64_t)(1.0e9 * 1.5);
//	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, delta), dispatch_get_main_queue(), ^{
//        [[NSNotificationCenter defaultCenter] postNotificationName:kPeripheralAddedNotification object:@"MrRobot"]; // [[NSUserDefaults standardUserDefaults] objectForKey:kUserDeviceNameKey]
//    });
//    
//    delta = (int64_t)(1.0e9 * 2);
//	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, delta), dispatch_get_main_queue(), ^{
//        [[NSNotificationCenter defaultCenter] postNotificationName:kPeripheralAddedNotification object:@"Robota"]; // [[NSUserDefaults standardUserDefaults] objectForKey:kUserDeviceNameKey]
//    });
    
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
