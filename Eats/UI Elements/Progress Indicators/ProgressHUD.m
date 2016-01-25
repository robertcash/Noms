//
//  ProgressHUD.m
//  Eats
//
//  Created by Robert Cash on 11/28/15.
//  Copyright © 2015 Robert Cash. All rights reserved.
//
#import "KVNProgress.h"
#import "ProgressHUD.h"

@implementation ProgressHUD

#pragma mark - Init

- (id)init {
    self = [super init];
    if (self) {
        // Any custom setup work goes here
        KVNProgressConfiguration *configuration = [[KVNProgressConfiguration alloc] init];
        configuration.statusColor = [UIColor whiteColor];
        configuration.successColor = [UIColor colorWithRed:72/255.0 green:179.0/255.0 blue:132.0/255.0 alpha:1];
        configuration.errorColor = [UIColor colorWithRed:72/255.0 green:179.0/255.0 blue:132.0/255.0 alpha:1];
        configuration.circleStrokeForegroundColor = [UIColor colorWithRed:72/255.0 green:179.0/255.0 blue:132.0/255.0 alpha:1];
        configuration.circleStrokeBackgroundColor = [UIColor colorWithWhite:1.0f alpha:0.3f];
        configuration.circleFillBackgroundColor = [UIColor colorWithWhite:1.0f alpha:0.1f];
        configuration.minimumSuccessDisplayTime = .75;
        configuration.minimumDisplayTime = .1;
        configuration.minimumErrorDisplayTime = .75;
        configuration.backgroundFillColor = [UIColor whiteColor];
        configuration.backgroundTintColor = [UIColor whiteColor];
        [KVNProgress setConfiguration:configuration];
    }
    return self;
}

#pragma mark - Action Code

-(void)show{
    [KVNProgress show];
}

-(void)hide{
    [KVNProgress dismiss];
}

@end
