//
//  HitView.h
//  ipad-stats2
//
//  Created by Scott Grandpre on 5/23/13.
//  Copyright (c) 2013 RIPP Volleyball. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LinesView : UIView
@property NSArray* lines;

- (id)initWithFrame:(CGRect)frame lines:(NSArray*)lines;

@end
