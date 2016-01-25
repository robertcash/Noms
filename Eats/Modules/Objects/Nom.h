//
//  Nom.h
//  Eats
//
//  Created by Robert Cash on 12/24/15.
//  Copyright © 2015 Robert Cash. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Nom : NSObject

// ID
@property NSString *eventId;
@property NSString *nomAuthorID;

// Details
@property NSString *food;
@property NSString *location;
@property NSDate *time;
@property NSDate *endTime;
@property NSString *facebookDescription;
@property BOOL isFacebookEvent;

// Voting System
@property NSString *question;
@property NSNumber *yesCountOne;
@property NSNumber *noCountOne;
@property NSNumber *yesCountTwo;
@property NSNumber *noCountTwo;


// User Specific
@property BOOL isSaved;
@property NSString *voteResultPollOne;
@property NSString *voteResultPollTwo;


@end
