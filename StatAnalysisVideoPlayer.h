//
//  StatAnalysisVideoPlayer.h
//  ipad-stats2
//
//  Created by James Grandpre on 6/13/14.
//  Copyright (c) 2014 RIPP Volleyball. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Stat.h"

@interface StatAnalysisVideoPlayer : UIView

@property NSArray *playlist;
@property CGFloat offset;

- (void)seekTo:(Stat *)stat;

@end
