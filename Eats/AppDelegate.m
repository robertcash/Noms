//
//  AppDelegate.m
//  Eats
//
//  Created by Robert Cash on 11/14/15.
//  Copyright (c) 2015 Robert Cash. All rights reserved.
//
#import "UserCache.h"
#import "BackendClass.h"
#import "IQKeyboardManager.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <Parse/Parse.h>
#import "AppDelegate.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

#pragma mark Default Methods

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    // UI Stuff
    [[UITabBar appearance] setTranslucent:NO];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:NO];
    [[UINavigationBar appearance] setBarTintColor:[UIColor colorWithRed:72/255.0 green:179.0/255.0 blue:132.0/255.0 alpha:1]];
    [[UITabBar appearance] setTintColor: [UIColor colorWithRed:72/255.0 green:179.0/255.0 blue:132.0/255.0 alpha:1]];
    [[UILabel appearanceWhenContainedIn:[UITableViewHeaderFooterView class],nil] setFont:
     [UIFont fontWithName:@"Gotham-Book" size:12.0]];
    [[UILabel appearanceWhenContainedIn:[UITableViewHeaderFooterView class], nil] setTextColor:[UIColor colorWithRed:102/255.0 green:102.0/255.0 blue:102.0/255.0 alpha:1]];
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    [[UINavigationBar appearance] setTranslucent:NO];
    // Push
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    if (currentInstallation.badge != 0) {
        currentInstallation.badge = 0;
        [currentInstallation saveEventually];
    }
    
    // Facebook/Parse Stuff
    [Parse setApplicationId:@"nLu3tdKYSKBPpgSY04QvcIVGI8AfGqTRJzVOQy5B"
                  clientKey:@"Ea1UXNbYgTh3ht6mQQHVtl0ptcDOv6J3Xee1HJCk"];
    [[FBSDKApplicationDelegate sharedInstance] application:application
                             didFinishLaunchingWithOptions:launchOptions];
    [FBSDKLoginButton class];
    
    
    // Other
    [[IQKeyboardManager sharedManager] disableToolbarInViewControllerClass:[UIViewController class]];

    
    return YES;
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    // Store the deviceToken in the current installation and save it to Parse.
    UserCache *userCache = [[UserCache alloc]init];
    NSString *tokenString = [deviceToken description];
    tokenString = [tokenString stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    tokenString = [tokenString stringByReplacingOccurrencesOfString:@" " withString:@""];
    [userCache setDeviceToken:tokenString];
    if([userCache getUserId]){
        [self sendPushNotificationToken:tokenString];
    }
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:deviceToken];
    [currentInstallation saveInBackground];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    [PFPush handlePush:userInfo];
    
    if([userInfo valueForKey:@"open"]) {
        UITabBarController *tabb = (UITabBarController *)self.window.rootViewController;
        tabb.selectedIndex = 1;
    }
}



- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    return [[FBSDKApplicationDelegate sharedInstance] application:application
                                                          openURL:url
                                                sourceApplication:sourceApplication
                                                       annotation:annotation
            ];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    if (currentInstallation.badge != 0) {
        currentInstallation.badge = 0;
        [currentInstallation saveEventually];
    }
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma Other Methods

-(void)sendPushNotificationToken:(NSString *)token{
    BackendClass *backendClass = [[BackendClass alloc]init];
    
    [backendClass updatePushNotificationToken:@{@"token":token}];
}

-(void)sendFacebookEventData{
    BackendClass *backendClass = [[BackendClass alloc]init];
    
    [backendClass sendFacebookEvents];
}

@end
