//
//  BackendClass.m
//  Eats
//
//  Created by Robert Cash on 11/28/15.
//  Copyright © 2015 Robert Cash. All rights reserved.
//

#import "BackendClass.h"

@implementation BackendClass
{
    UserCache *userCache;
    NSDictionary *headers;
}
- (id)init {
    self = [super init];
    if (self) {
        // Any custom setup work goes here
        userCache = [[UserCache alloc]init];
        [UNIRest timeout:30];
        headers = @{@"Content-Type": @"application/json"};
    }
    return self;
}

#pragma mark POST REQUESTS

-(void)loginWithUserLocation:(NSDictionary *)userData withCompletionHandler:(void (^)(BOOL result, NSString *error))completionHandler{
    // Convert date to MySQL Datetime format
    NSDateFormatter *gmtDateFormatter = [[NSDateFormatter alloc] init];
    gmtDateFormatter.timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
    gmtDateFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss Z";
    NSString *dateString = [gmtDateFormatter stringFromDate:[FBSDKAccessToken currentAccessToken].expirationDate];
    
    NSDictionary* parameters = @{@"facebookUserId": userData[@"userId"], @"name": userData[@"name"], @"school":userData[@"school"], @"longitude":userData[@"longitude"], @"latitude":userData[@"latitude"],@"facebookAccessToken":[FBSDKAccessToken currentAccessToken].tokenString,@"facebookAccessTokenExpiration":dateString};
    NSLog(@"%@",parameters);
    UNIHTTPJsonResponse *response = [[UNIRest postEntity:^(UNIBodyRequest *request) {
        [request setUrl:@"http://noms.elasticbeanstalk.com/login"];
        [request setHeaders:headers];
        [request setBody:[NSJSONSerialization dataWithJSONObject:parameters options:0 error:nil]];
    }] asJson];
    
    NSLog(@"%ld",(long)response.code);
    if(response.code == 404 || response.code == 500){
        completionHandler(NO,@"Connection Error.");
    }
    else if(response.body.object[@"error"]){
        completionHandler(NO,response.body.object[@"error"]);
    }
    else if (response.code == 200){
        NSLog(@"%@",response.body.object);
        [userCache setUserId:response.body.object[@"userId"]];
        [userCache setFacebookId:response.body.object[@"facebookId"]];
        [userCache setName:response.body.object[@"name"]];
        [userCache setEducation:response.body.object[@"school"]];
        NSLog(@"%@",[userCache getEducation]);
        completionHandler(YES,@"");
    }
    else{
        completionHandler(NO,@"Connection Error.");
    }
    
}

-(void)postNom:(NSDictionary *)nom withCompletionHandler:(void (^)(BOOL result,NSString *error))completionHandler{
    // Convert date to MySQL Datetime format
    NSDateFormatter *gmtDateFormatter = [[NSDateFormatter alloc] init];
    gmtDateFormatter.timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
    gmtDateFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss Z";
    
    NSDate *postDate;
    postDate = nom[@"date"];
    if([nom[@"date"] timeIntervalSince1970] < [[NSDate date]timeIntervalSince1970]){
        postDate = [NSDate date];
    }
    
    NSString *dateString = [gmtDateFormatter stringFromDate:postDate];
    
    // Get User Location
    CLLocationManager *locationManager =[[CLLocationManager alloc]init];
    float latitude = locationManager.location.coordinate.latitude;
    float longitude = locationManager.location.coordinate.longitude;
    
    
    
    NSDictionary *parameters = @{@"food":nom[@"food"],@"location":nom[@"location"],@"date":dateString,@"authorId":[userCache getUserId],@"latitude":[NSString stringWithFormat:@"%f",latitude],@"longitude":[NSString stringWithFormat:@"%f",longitude]};
    UNIHTTPJsonResponse *response = [[UNIRest postEntity:^(UNIBodyRequest *request) {
        [request setUrl:@"http://noms.elasticbeanstalk.com/noms/post"];
        [request setHeaders:headers];
        [request setBody:[NSJSONSerialization dataWithJSONObject:parameters options:0 error:nil]];
    }] asJson];
    
    NSLog(@"%@",response);
    if(response.code == 404 || response.code == 500){
        completionHandler(NO,@"Connection Error.");
    }
    else if(response.body.object[@"error"]){
        completionHandler(NO,response.body.object[@"error"]);
    }
    else{
        completionHandler(YES,@"");
    }
}

-(void)voteOnNom:(NSString *)vote nom:(Nom *) nom withCompletionHandler:(void (^)(BOOL result,NSString *error))completionHandler{
    
    // Get Question Type
    NSString *question = @"";
    if([[NSDate date] timeIntervalSince1970] < [nom.time timeIntervalSince1970]){
        question = @"one";
    }
    else{
       question = @"two";
    }
    
    NSDictionary *parameters = @{@"vote":vote,@"nomId":nom.eventId,@"userId":[userCache getUserId],@"question":question};
    UNIHTTPJsonResponse *response = [[UNIRest postEntity:^(UNIBodyRequest *request) {
        [request setUrl:@"http://noms.elasticbeanstalk.com/noms/vote"];
        [request setHeaders:headers];
        [request setBody:[NSJSONSerialization dataWithJSONObject:parameters options:0 error:nil]];
    }] asJson];
    
    NSLog(@"%@",response);
    if(response.code == 404 || response.code == 500){
        completionHandler(NO,@"Connection Error.");
    }
    else if(response.body.object[@"error"]){
        completionHandler(NO,response.body.object[@"error"]);
    }
    else{
        completionHandler(YES,@"");
    }
}
-(void)saveNom:(Nom *)nom withCompletionHandler:(void (^)(BOOL result,NSString *error))completionHandler{
    // Format Dates for JSON
    NSDateFormatter *gmtDateFormatter = [[NSDateFormatter alloc] init];
    gmtDateFormatter.timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
    gmtDateFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss Z";
    
    NSDictionary *parameters = @{@"nomId":nom.eventId,@"userId":[userCache getUserId],@"food":nom.food,@"location":nom.location,@"time":[gmtDateFormatter stringFromDate:nom.time],@"endTime":[gmtDateFormatter stringFromDate:nom.endTime]};
    UNIHTTPJsonResponse *response = [[UNIRest postEntity:^(UNIBodyRequest *request) {
        [request setUrl:@"http://noms.elasticbeanstalk.com/yournoms/save"];
        [request setHeaders:headers];
        [request setBody:[NSJSONSerialization dataWithJSONObject:parameters options:0 error:nil]];
    }] asJson];
    
    NSLog(@"%@",response);
    if(response.code == 404 || response.code == 500){
        completionHandler(NO,@"Connection Error.");
    }
    else if(response.body.object[@"error"]){
        completionHandler(NO,response.body.object[@"error"]);
    }
    else{
        completionHandler(YES,@"");
    }
}
-(void)unsaveNom:(Nom *)nom withCompletionHandler:(void (^)(BOOL result,NSString *error))completionHandler{
    NSDictionary *parameters = @{@"nomId":nom.eventId,@"userId":[userCache getUserId]};
    UNIHTTPJsonResponse *response = [[UNIRest postEntity:^(UNIBodyRequest *request) {
        [request setUrl:@"http://noms.elasticbeanstalk.com/yournoms/unsave"];
        [request setHeaders:headers];
        [request setBody:[NSJSONSerialization dataWithJSONObject:parameters options:0 error:nil]];
    }] asJson];
    
    NSLog(@"%@",response);
    if(response.code == 404 || response.code == 500){
        completionHandler(NO,@"Connection Error.");
    }
    else if(response.body.object[@"error"]){
        completionHandler(NO,response.body.object[@"error"]);
    }
    else{
        completionHandler(YES,@"");
    }
}

-(void)deleteNom:(Nom *)nom withCompletionHandler:(void (^)(BOOL result,NSString *error))completionHandler{
    NSDictionary *parameters = @{@"nomId":nom.eventId};
    UNIHTTPJsonResponse *response = [[UNIRest postEntity:^(UNIBodyRequest *request) {
        [request setUrl:@"http://noms.elasticbeanstalk.com/noms/delete"];
        [request setHeaders:headers];
        [request setBody:[NSJSONSerialization dataWithJSONObject:parameters options:0 error:nil]];
    }] asJson];
    
    NSLog(@"%@",response);
    if(response.code == 404 || response.code == 500){
        completionHandler(NO,@"Connection Error.");
    }
    else if(response.body.object[@"error"]){
        completionHandler(NO,response.body.object[@"error"]);
    }
    else if(response.code == 200){
        completionHandler(YES,@"");
    }
    else{
        completionHandler(NO,@"Connection Error.");
    }
    
}

-(void)updatePushNotificationToken:(NSDictionary *)token{
    NSDictionary *parameters = @{@"iOSDeviceToken":token[@"token"],@"userId":[userCache getUserId]};
    UNIHTTPJsonResponse *response = [[UNIRest postEntity:^(UNIBodyRequest *request) {
        [request setUrl:@"http://noms.elasticbeanstalk.com/notifications/update"];
        [request setHeaders:headers];
        [request setBody:[NSJSONSerialization dataWithJSONObject:parameters options:0 error:nil]];
    }] asJson];
    
    NSLog(@"%@",response);
}

-(void)sendFacebookEvents{
    // Convert date to MySQL Datetime format
    NSDateFormatter *gmtDateFormatter = [[NSDateFormatter alloc] init];
    gmtDateFormatter.timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
    gmtDateFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss Z";
    NSString *dateString = [gmtDateFormatter stringFromDate:[FBSDKAccessToken currentAccessToken].expirationDate];
    NSLog(@"%@ %@",[userCache getEducation],[userCache getUserId]);
    NSDictionary *parameters = @{@"userId":[userCache getUserId],@"facebookAccessToken":[FBSDKAccessToken currentAccessToken].tokenString,@"facebookId":[userCache getFacebookId],@"facebookAccessTokenExpiration":dateString,@"userSchool":[userCache getEducation]};
    [[UNIRest postEntity:^(UNIBodyRequest *request) {
        [request setUrl:@"http://noms.elasticbeanstalk.com/facebook"];
        [request setHeaders:headers];
        [request setBody:[NSJSONSerialization dataWithJSONObject:parameters options:0 error:nil]];
    }]asJsonAsync:^(UNIHTTPJsonResponse* response, NSError *error) {
        // This is the asyncronous callback block
        
    }];
    
    
}

#pragma mark GET REQUESTS

-(void)getNoms:(void (^)(NSDictionary * noms, NSArray * nomsSections, NSString *error))completionHandler{
    // Get User Location
    CLLocationManager *locationManager =[[CLLocationManager alloc]init];
    float latitude = locationManager.location.coordinate.latitude;
    float longitude = locationManager.location.coordinate.longitude;
    //(33.7911, -84.3239989)
    NSDictionary *parameters = @{@"userId":[userCache getUserId],@"userSchool":[userCache getEducation],@"latitude":[NSString stringWithFormat:@"%f",latitude],@"longitude":[NSString stringWithFormat:@"%f",longitude]};
    UNIHTTPJsonResponse *response = [[UNIRest postEntity:^(UNIBodyRequest *request) {
        [request setUrl:@"http://noms.elasticbeanstalk.com/noms/get"];
        [request setHeaders:headers];
        [request setBody:[NSJSONSerialization dataWithJSONObject:parameters options:0 error:nil]];
    }] asJson];
    
    NSLog(@"%@",response);
    if(response.code == 404 || response.code == 500){
        completionHandler(@{},@[],@"Connection Error.");
    }
    else if(response.body.object[@"error"]){
        completionHandler(@{},@[],response.body.object[@"error"]);
    }
    else{
        NSDictionary *noms = [self sortNoms:response.body.object[@"noms"]];
        NSArray *nomsOrder = [self sortNomsOrdering:response.body.object[@"noms"]];
        completionHandler(noms,nomsOrder,@"");
    }
}

-(void)getYourNoms:(void (^)(NSDictionary* yourNoms,NSArray *yourNomsSections, NSString *error))completionHandler{
    NSDictionary *parameters = @{@"userId":[userCache getUserId]};
    UNIHTTPJsonResponse *response = [[UNIRest postEntity:^(UNIBodyRequest *request) {
        [request setUrl:@"http://noms.elasticbeanstalk.com/yournoms/get"];
        [request setHeaders:headers];
        [request setBody:[NSJSONSerialization dataWithJSONObject:parameters options:0 error:nil]];
    }] asJson];
    
    NSLog(@"%@",response);
    if(response.code == 404 || response.code == 500){
        completionHandler(@{},@[],@"Connection Error.");
    }
    else if(response.body.object[@"error"]){
        completionHandler(@{},@[],response.body.object[@"error"]);
    }
    else{
        NSDictionary *noms = [self sortNoms:response.body.object[@"noms"]];
        NSArray *nomsOrder = [self sortNomsOrdering:response.body.object[@"noms"]];
        completionHandler(noms,nomsOrder,@"");
    }
}

-(void)getNotifications:(void (^)(NSNumber *notifcations, NSString *error))completionHandler{
    NSDictionary *parameters = @{@"userId":[userCache getUserId]};
    UNIHTTPJsonResponse *response = [[UNIRest postEntity:^(UNIBodyRequest *request) {
        [request setUrl:@"http://noms.elasticbeanstalk.com/notifications/get"];
        [request setHeaders:headers];
        [request setBody:[NSJSONSerialization dataWithJSONObject:parameters options:0 error:nil]];
    }] asJson];
    
    NSLog(@"%@",response);
    if(response.code == 404){
        completionHandler([NSNumber numberWithInteger:0],@"Connection Error.");
    }
    else if(response.body.object[@"error"]){
        completionHandler([NSNumber numberWithInteger:0],response.body.object[@"error"]);
    }
    else{
        int number = [response.body.object[@"number"] intValue];
        completionHandler([NSNumber numberWithInt:number],@"");
    }
}

#pragma mark - Backend Helper Methods

// Assembles Noms Objects and sorts them into date headings
-(NSDictionary *)sortNoms:(NSArray *)nomsFromJSON{
    NSMutableDictionary *noms = [[NSMutableDictionary alloc]init];
    
    for(NSDictionary *nomFromJSON in nomsFromJSON){
        Nom *nom = [[Nom alloc]init];
        nom.eventId = nomFromJSON[@"nomId"];
        nom.nomAuthorID = nomFromJSON[@"nomAuthorId"];
        nom.food = nomFromJSON[@"food"];
        nom.location = nomFromJSON[@"location"];
        if(nomFromJSON[@"facebookDescription"] != [NSNull null]){
            nom.facebookDescription = nomFromJSON[@"facebookDescription"];
        }
        nom.time = [self dateFromJSONToNSDate:nomFromJSON[@"startTime"]];
        nom.endTime = [self dateFromJSONToNSDate:nomFromJSON[@"endTime"]];
        if(nomFromJSON[@"pollOneResult"] == [NSNull null]){
            nom.voteResultPollOne = @"";
        }
        else{
            nom.voteResultPollOne = nomFromJSON[@"pollOneResult"];
        }
        if(nomFromJSON[@"pollTwoResult"] == [NSNull null]){
            nom.voteResultPollTwo = @"";
        }
        else{
            nom.voteResultPollTwo = nomFromJSON[@"pollTwoResult"];
        }
        nom.yesCountOne = [NSNumber numberWithInt:[nomFromJSON[@"yesCountOne"] intValue]];
        nom.noCountOne = [NSNumber numberWithInt:[nomFromJSON[@"noCountOne"] intValue]];
        nom.yesCountTwo = [NSNumber numberWithInt:[nomFromJSON[@"yesCountTwo"] intValue]];
        nom.noCountTwo = [NSNumber numberWithInt:[nomFromJSON[@"noCountTwo"] intValue]];
        nom.isSaved = [nomFromJSON[@"userSaved"] boolValue];
        nom.question = nomFromJSON[@"question"];
        if([nomFromJSON[@"eventType"]isEqualToString:@"facebook"]){
            nom.isFacebookEvent = YES;
        }
        else{
            nom.isFacebookEvent = NO;
        }
        
        if(noms[[self dateFromJSONToDisplayDate:nom]]){
            NSMutableArray *dayNoms = noms[[self dateFromJSONToDisplayDate:nom]];
            [dayNoms addObject:nom];
            [noms setValue:dayNoms forKey:[self dateFromJSONToDisplayDate:nom]];
            
        }
        else{
            NSMutableArray *dayNoms = [[NSMutableArray alloc]init];
            [dayNoms addObject:nom];
            [noms setValue:dayNoms forKey:[self dateFromJSONToDisplayDate:nom]];
        }
        
    }
    return [noms copy];
}

// Sorts order of header labels
-(NSArray *)sortNomsOrdering:(NSDictionary *)nomsFromJson{
    NSMutableArray * nomOrdering = [[NSMutableArray alloc]init];
    
    for (NSDictionary *nomFromJSON in nomsFromJson){
        Nom *nom = [[Nom alloc]init];
        nom.time = [self dateFromJSONToNSDate:nomFromJSON[@"startTime"]];
        
        if([nomOrdering containsObject:[self dateFromJSONToDisplayDate:nom]]){
            continue;
        }
        else{
            [nomOrdering addObject:[self dateFromJSONToDisplayDate:nom]];
        }
    }
    return [nomOrdering copy];
}

-(NSDate *)dateFromJSONToNSDate:(NSString *)jsonDate{
    NSLocale *locale = [NSLocale currentLocale];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.locale = locale;
    [formatter setFormatterBehavior:NSDateFormatterBehavior10_4];   // Explicitly re-stating default behavior for 10.4+
    formatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss Z";
    formatter.timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
    return [formatter dateFromString:jsonDate];
}

-(NSString *)dateFromJSONToDisplayDate:(Nom *)nom{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    NSLocale *locale = [NSLocale currentLocale];
    formatter.locale = locale;
    formatter.doesRelativeDateFormatting = YES;
    [formatter setDateStyle:NSDateFormatterFullStyle];
    return [formatter stringFromDate:nom.time];
}

@end
