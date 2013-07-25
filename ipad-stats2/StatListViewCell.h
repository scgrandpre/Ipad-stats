//
//  StatListViewCell.h
//  ipad-stats2
//
//  Created by Scott Grandpre on 7/8/13.
//  Copyright (c) 2013 RIPP Volleyball. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Stat;
@interface StatListViewCell : UITableViewCell

- (void)updateWithStat:(Stat*)stat;

@end
