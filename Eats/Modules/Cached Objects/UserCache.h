//
//  UserCache.h
//  Eats
//
//  Created by Robert Cash on 11/28/15.
//  Copyright © 2015 Robert Cash. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserCache : NSObject

-(NSString *)getUserId;
-(void)setUserId:(NSString *)userId;
-(NSString *)getFacebookId;
-(void)setFacebookId:(NSString *)facebookId;
-(NSString *)getName;
-(void)setName:(NSString *)name;
-(NSString *)getDeviceToken;
-(void)setDeviceToken:(NSString *)deviceToken;
-(NSString *)getEducation;
-(void)setEducation:(NSString *)education;

-(void)clearAllData;

@end
