//
//  PlayListViewCell.m
//  ipad-stats2
//
//  Created by Scott Grandpre on 6/17/13.
//  Copyright (c) 2013 RIPP Volleyball. All rights reserved.
//

#import "PlayListViewCell.h"
#import "StatListViewCell.h"
#import "Play.h"
#import "Stat.h"

@interface PlayListViewCell ()

@property UILabel *title;
@property UITableView *eventTableView;
@property Play *play;

@end

@implementation PlayListViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        _title = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 30)];
        _title.text = @"Play!";
        
        [self addSubview:_title];
        
        _eventTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 30, 100, 100)];
        [self addSubview:_eventTableView];
        
        _eventTableView.delegate = self;
        _eventTableView.dataSource = self;

    }
    return self;
}

- (void)updateWithPlay:(Play*)play {
    self.title.frame = CGRectMake(0, 0, self.bounds.size.width, 30);
    CGFloat selected = 0;
    if ([self.eventTableView indexPathForSelectedRow] != nil) {
        selected = 300;
    }
    self.eventTableView.frame = CGRectMake(0, 30, self.bounds.size.width, 50 * [play.stats count] + selected);
    self.play = play;
    [self.eventTableView reloadData];
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    //NSLog(@"%@", @"SELECTED!!");

    // Configure the view for the selected state
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    StatListViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[StatListViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell"];
    }
    Stat *stat = self.play.stats[indexPath.row];
    [cell updateWithStat:stat];
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.play.stats count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSIndexPath *selection = [tableView indexPathForSelectedRow];
    if (selection != nil && selection.row == indexPath.row) {
        return 350;
    } else {
        return 50;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"Selected row at %@!", indexPath);
    
    [tableView beginUpdates];
    [tableView endUpdates];
    [((UITableView*)self.superview) beginUpdates];
    [((UITableView*)self.superview) endUpdates];
    
    self.eventTableView.frame = CGRectMake(0, 30, self.bounds.size.width, 50 * [self.play.stats count] + 300);
}

@end
