//
//  BackendClass.h
//  Eats
//
//  Created by Robert Cash on 11/28/15.
//  Copyright © 2015 Robert Cash. All rights reserved.
//
#import "Nom.h"
#import "UserCache.h"
#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "UNIRest.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>

@interface BackendClass : NSObject

// POST REQUESTS
-(void)loginWithUserLocation:(NSDictionary *)userData withCompletionHandler:(void (^)(BOOL result,NSString *error))completionHandler;
-(void)postNom:(NSDictionary *)nom withCompletionHandler:(void (^)(BOOL result,NSString *error))completionHandler;
-(void)voteOnNom:(NSString *)vote nom:(Nom *) nom withCompletionHandler:(void (^)(BOOL result,NSString *error))completionHandler;
-(void)saveNom:(Nom *)nom withCompletionHandler:(void (^)(BOOL result,NSString *error))completionHandler;
-(void)unsaveNom:(Nom *)nom withCompletionHandler:(void (^)(BOOL result,NSString *error))completionHandler;
-(void)deleteNom:(Nom *)nom withCompletionHandler:(void (^)(BOOL result,NSString *error))completionHandler;
-(void)updatePushNotificationToken:(NSDictionary *)token;
-(void)sendFacebookEvents;

// GET REQUESTS
-(void)getNoms:(void (^)(NSDictionary * noms, NSArray * nomsSections, NSString *error))completionHandler;
-(void)getYourNoms:(void (^)(NSDictionary * yourNoms, NSArray * yourNomsSections, NSString *error))completionHandler;

-(void)getNotifications:(void (^)(NSNumber *notifcations, NSString *error))completionHandler;


@end
