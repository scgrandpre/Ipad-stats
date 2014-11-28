//
//  StatAnalysisViewController.h
//  ipad-stats2
//
//  Created by Jim Grandpre on 4/25/13.
//  Copyright (c) 2013 RIPP Volleyball. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Game;

@interface StatAnalysisViewController : UIViewController
-(id)initWithGame:(Game*) game;
-(void)updateStats;
@end
