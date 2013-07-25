//
//  PlayListViewCell.h
//  ipad-stats2
//
//  Created by Scott Grandpre on 6/17/13.
//  Copyright (c) 2013 RIPP Volleyball. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Play;
@interface PlayListViewCell : UITableViewCell <UITableViewDataSource, UITableViewDelegate>

- (void)updateWithPlay:(Play*)play;

@end
