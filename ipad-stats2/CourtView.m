//
//  CourtView.m
//  ipad-stats
//
//  Created by Jim Grandpre on 4/11/13.
//  Copyright (c) 2013 RIPP Volleyball. All rights reserved.
//

#import "CourtView.h"
#import "CourtOverlayView.h"

@implementation CourtView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        UIImageView *background = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Pitt_center"]];
        background.frame = self.bounds;
        [self addSubview:background];
        CourtOverlayView *overlay = [[CourtOverlayView alloc] initWithFrame:self.bounds];
        [self addSubview:overlay];
        
    }
    return self;

}

@end
