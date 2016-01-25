//
//  EatsTableViewCell.m
//  Eats
//
//  Created by Robert Cash on 11/26/15.
//  Copyright © 2015 Robert Cash. All rights reserved.
//

#import "EatsTableViewCell.h"

@implementation EatsTableViewCell

- (void)awakeFromNib {
    // Initialization code
    self.blackView.layer.cornerRadius = 5;
    self.blackView.clipsToBounds = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
