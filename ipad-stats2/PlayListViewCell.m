//
//  PlayListViewCell.m
//  ipad-stats2
//
//  Created by Scott Grandpre on 6/17/13.
//  Copyright (c) 2013 RIPP Volleyball. All rights reserved.
//

#import "PlayListViewCell.h"
#import "Play.h"
#import "Stat.h"

@interface PlayListViewCell ()

@property UILabel *title;
@property UIView *stats;

@end

@implementation PlayListViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        _title = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 30)];
        _title.text = @"Play!";
        
        _stats = [[UILabel alloc] initWithFrame:CGRectMake(0, 30, 100, 100)];
        [self addSubview:_stats];
        [self addSubview:_title];
    }
    return self;
}

- (void)updateWithPlay:(Play*)play {
    self.title.frame = CGRectMake(0, 0, self.bounds.size.width, 30);
    self.stats.frame = CGRectMake(0, 30, self.bounds.size.width, 50 * [play.stats count]);
    
    for (UIView* view in [self.stats subviews]) {
        [view removeFromSuperview];
    }
    
    for (int i=0; i < play.stats.count; i++) {
        Stat* stat = play.stats[i];
        UIView *statView = [[UIView alloc] initWithFrame:CGRectMake(0, 50 * i, self.bounds.size.width, 50)];
        UILabel* labelView = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, 50)];
        [statView addSubview:labelView];
        [self.stats addSubview:statView];
        labelView.text = stat.skill;
    }
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
