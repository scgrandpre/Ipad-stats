//
//  PlayListView.m
//  ipad-stats2
//
//  Created by Scott Grandpre on 6/17/13.
//  Copyright (c) 2013 RIPP Volleyball. All rights reserved.
//

#import "PlayListView.h"
#import "PlayListViewCell.h"
#import "Play.h"

@interface PlayListView ()
@property Game* game;
@property UITableView *tableView;
@end

@implementation PlayListView

- (id)initWithFrame:(CGRect)frame game:(Game*)game {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _game = game;
        
        _tableView = [[UITableView alloc] initWithFrame:self.bounds];
        [self addSubview:_tableView];
        
        _tableView.delegate = self;
        _tableView.dataSource = self;
    }
    return self;
}

- (void) refresh {
    [self.tableView reloadData];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    PlayListViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[PlayListViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell"];
    }
    Play *play = self.game.plays[indexPath.row];
    [cell updateWithPlay:play];
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSLog(@"%lu", (unsigned long)self.game.plays.count);
    return [self.game.plays count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat height = ((Play*)self.game.plays[indexPath.row]).stats.count * 50 + 20;
    if (indexPath.row == self.game.plays.count - 1) {
        return MAX(height, self.bounds.size.height);
    } else {
        return height;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"Selected row at %@!", indexPath);
}

@end
