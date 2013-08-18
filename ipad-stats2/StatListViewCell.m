//
//  StatListViewCell.m
//  ipad-stats2
//
//  Created by Scott Grandpre on 7/8/13.
//  Copyright (c) 2013 RIPP Volleyball. All rights reserved.
//

#import "StatListViewCell.h"
#import "Stat.h"
#import "ToggleButtonView.h"


@interface StatListViewCell ()

@property UILabel *title;
@property Stat *stat;
@property UIView *detailsView;

@end


@implementation StatListViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _title = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 30)];
        [self addSubview:_title];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        // RED VIEW!
        _detailsView = [[UIView alloc] initWithFrame:CGRectMake(0, 30, self.bounds.size.width, 300)];
        [self addSubview:_detailsView];
        _detailsView.backgroundColor = [UIColor redColor];
        
    }
    return self;
}

- (void) updateWithStat:(Stat *)stat {
    //NSLog(@"%@", stat.skill);
    self.title.text = stat.skill;
    _detailsView.hidden = YES;
    ToggleButtonView *buttonsview = [[ToggleButtonView alloc] initWithFrame:CGRectMake(0,0,100,100) buttonTitles: @[@"string1",@"string2"] currentSelection:@"string1"];
    [self.detailsView addSubview:buttonsview];
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    //NSLog(@"%@", @"SELECTED!!");
    // Configure the view for the selected state
    self.detailsView.hidden = !selected;
}

@end
