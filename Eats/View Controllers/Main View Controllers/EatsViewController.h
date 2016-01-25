//
//  EatsViewController.h
//  Eats
//
//  Created by Robert Cash on 11/21/15.
//  Copyright © 2015 Robert Cash. All rights reserved.
//
// Data Stuff
#import "BackendClass.h"
#import "UserCache.h"
#import "Nom.h"
// UI
#import "EatsTableViewCell.h"
#import "ProgressHUD.h"
// Frameworks
#import <UIKit/UIKit.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
// View Controllers
#import "EatDetailViewController.h"
#import "EatDetailDescriptionViewController.h"

@interface EatsViewController : UITableViewController

// Data

@property NSDictionary *nomsData;

@end
