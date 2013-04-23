//
//  CourtOverlayView.m
//  ipad-stats2
//
//  Created by Jim Grandpre on 4/11/13.
//  Copyright (c) 2013 RIPP Volleyball. All rights reserved.
//

#import "CourtOverlayView.h"
#import "FancyMultipleButtonsView.h"

@interface CourtOverlayView ()
@property CGRect court;
@end

@implementation CourtOverlayView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
        self.court = CGRectInset(self.bounds, self.bounds.size.width*.11, self.bounds.size.height*.17);
        [self makeFrontRowPlayers];
        [self makeBackRowPlayers];
    }
    return self;
}

- (void)makeFrontRowPlayers {
    NSArray *options = @[@"HIT", @"BLOCK", @"DIG", @"PASS"];
    CGFloat xPosition = self.court.origin.x + self.court.size.width*.3;
    for(int y=0; y < 3; y++) {
        CGFloat yPosition = self.court.origin.y + self.court.size.height * (y)/3;
        FancyMultipleButtonsView *menu = [[FancyMultipleButtonsView alloc] initWithFrame:CGRectMake(xPosition, yPosition, self.court.size.width/4,self.court.size.height/3) label:[NSString stringWithFormat:@"%i", y] options:options choose:^(int selection) {
        }];
        [self addSubview:menu];
    }
}


- (void)makeBackRowPlayers {
    NSArray *options = @[@"HIT", @"SERVE", @"DIG", @"PASS"];
    CGFloat xPosition = self.court.origin.x + self.court.size.width*.05;
    for(int y=0; y < 3; y++) {
        CGFloat yPosition = self.court.origin.y + self.court.size.height * (y)/3;
        FancyMultipleButtonsView *menu = [[FancyMultipleButtonsView alloc] initWithFrame:CGRectMake(xPosition, yPosition, self.court.size.width/4,self.court.size.height/3) label:[NSString stringWithFormat:@"%i", y + 3] options:options choose:^(int selection) {
        }];
        [self addSubview:menu];
    }
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(ctx, [UIColor greenColor].CGColor);
    CGRect court = CGRectInset(rect, self.bounds.size.width*.11, self.bounds.size.height*.17);
    //CGContextFillRect(ctx, court);
}

@end
