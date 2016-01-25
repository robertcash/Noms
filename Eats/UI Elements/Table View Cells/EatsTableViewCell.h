//
//  EatsTableViewCell.h
//  Eats
//
//  Created by Robert Cash on 11/26/15.
//  Copyright © 2015 Robert Cash. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EatsTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *monthLabel;
@property (weak, nonatomic) IBOutlet UILabel *foodNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *locationLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UIView *blackView;

@end
