//
//  PlayListView.h
//  ipad-stats2
//
//  Created by Scott Grandpre on 6/17/13.
//  Copyright (c) 2013 RIPP Volleyball. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Game.h"


@interface PlayListView : UIView <UITableViewDelegate, UITableViewDataSource>

- (id)initWithFrame:(CGRect)frame game:(Game*)game;
- (void) refresh;

@end
