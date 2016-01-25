//
//  YourNomsViewController.h
//  Eats
//
//  Created by Robert Cash on 12/23/15.
//  Copyright © 2015 Robert Cash. All rights reserved.
//
// Data
#import "BackendClass.h"
#import "Nom.h"
// UI
#import "EatsTableViewCell.h"
#import "ProgressHUD.h"
// Frameworks
#import <UIKit/UIKit.h>
// View Controllers
#import "EatDetailViewController.h"
#import "EatDetailDescriptionViewController.h"

@interface YourNomsViewController : UITableViewController

@property NSDictionary *yourNomsData;

-(void)scrollToTop;

@end
