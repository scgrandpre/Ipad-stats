//
//  ScoreView.h
//  ipad-stats2
//
//  Created by Jim Grandpre on 4/25/13.
//  Copyright (c) 2013 RIPP Volleyball. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ScoreView : UIView
- (id)initWithFrame:(CGRect)frame flipped:(BOOL)flipped increment:(void (^)())didIncrement;
- (void)increment;
- (void)decrement;
@end
