//
//  UserCache.m
//  Eats
//
//  Created by Robert Cash on 11/28/15.
//  Copyright © 2015 Robert Cash. All rights reserved.
//

#import "UserCache.h"

@implementation UserCache
{
    NSUserDefaults *defaults;
}

#pragma mark - Init

- (id)init {
    self = [super init];
    if (self) {
        // Any custom setup work goes here
        defaults = [NSUserDefaults standardUserDefaults];
    }
    return self;
}

#pragma mark - User Cache Getters

-(NSString *)getUserId{
   return [defaults objectForKey:@"userId"];
}

-(NSString *)getFacebookId{
    return [defaults objectForKey:@"facebookId"];
}

-(NSString *)getDeviceToken{
    return [defaults objectForKey:@"deviceToken"];
}

-(NSString *)getEducation{
    return [defaults objectForKey:@"education"];
}
-(NSString *)getName{
    return [defaults objectForKey:@"name"];
}



#pragma mark User Cache Setters

-(void)setUserId:(NSString *)userId;{
    [defaults setObject:userId forKey:@"userId"];
}

-(void)setFacebookId:(NSString *)facebookId;{
    [defaults setObject:facebookId forKey:@"facebookId"];
}

-(void)setDeviceToken:(NSString *)deviceToken{
    [defaults setObject:deviceToken forKey:@"deviceToken"];
}

-(void)setEducation:(NSString *)education{
    [defaults setObject:education forKey:@"education"];
}

-(void)setName:(NSString *)name{
    [defaults setObject:name forKey:@"name"];
}

#pragma mark - Other Methods

-(void)clearAllData{
    [defaults setObject:NULL forKey:@"userId"];
    [defaults setObject:NULL forKey:@"deviceToken"];
    [defaults setObject:NULL forKey:@"education"];
    [defaults setObject:NULL forKey:@"name"];
}

@end
