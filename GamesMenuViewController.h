//
//  GamesMenuViewController.h
//  ipad-stats2
//
//  Created by Jim Grandpre on 4/30/13.
//  Copyright (c) 2013 RIPP Volleyball. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GamesMenuViewController
    : UIViewController <UITableViewDataSource, UITableViewDelegate,
                        UITextFieldDelegate>

- (id)initWithGames:(NSArray *)games;
@end
