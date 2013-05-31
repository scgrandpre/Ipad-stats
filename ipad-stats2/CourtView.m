//
//  CourtView.m
//  ipad-stats
//
//  Created by Jim Grandpre on 4/11/13.
//  Copyright (c) 2013 RIPP Volleyball. All rights reserved.
//

#import "CourtView.h"
#import "CourtOverlayView.h"
#import <EventEmitter.h>
#import "Play.h"

@interface CourtView ()
@property (strong) CourtOverlayView* overlay;

@end

@implementation CourtView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        //UIImageView *background = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Pitt_center"]];
        //background.frame = self.bounds;
        //[self addSubview:background];
        self.backgroundColor = [UIColor clearColor];
        self.overlay = [[CourtOverlayView alloc] initWithFrame:self.bounds];
        [self addSubview:self.overlay];
        
        [self.overlay on:@"end_play" callback:^(Play* play) {
            [self emit:@"end_play" data:play];
        }];
        
        
    }
    return self;

}

- (void)rotateWithTeam:(NSString*)team increment:(int)increment {
    [self.overlay rotateWithTeam:team increment:increment];
}

- (void)drawRect:(CGRect)rect {
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    float width = self.bounds.size.width/8;
    float height = self.bounds.size.height/5;
    CGContextSetStrokeColorWithColor(ctx, [UIColor blackColor].CGColor);
    CGContextSetLineWidth(ctx, 4);
    
    // BORDER
    CGContextBeginPath(ctx);
    CGContextMoveToPoint(   ctx, .2*width,   2*height);
    CGContextAddLineToPoint(ctx,  6*width,   2*height);
    CGContextAddLineToPoint(ctx,  6*width, 4.9*height);
    CGContextAddLineToPoint(ctx, .2*width, 4.9*height);
    CGContextClosePath(ctx);
    CGContextStrokePath(ctx);
    // NET
    CGContextBeginPath(ctx);
    CGContextMoveToPoint(   ctx, 3.1*width,  2*height);
    CGContextAddLineToPoint(ctx, 3.1*width, 4.9*height);
    CGContextStrokePath(ctx);
    
    //10 FT Line
    CGContextBeginPath(ctx);
    CGContextMoveToPoint(   ctx, 2.14*width,  2*height);
    CGContextAddLineToPoint(ctx, 2.14*width, 4.9*height);
    CGContextMoveToPoint(   ctx, 4.06*width,  2*height);
    CGContextAddLineToPoint(ctx, 4.06*width, 4.9*height);
    CGContextStrokePath(ctx);
    
    //sample table
    CGContextBeginPath(ctx);
    CGContextMoveToPoint(   ctx, .2*width, .25*height);
    CGContextAddLineToPoint(ctx, 6*width, .25*height);
    CGContextAddLineToPoint(ctx, 6*width, 1.25 *height);
    CGContextAddLineToPoint(ctx, .2*width, 1.25 *height);
    CGContextClosePath(ctx);
    CGContextStrokePath(ctx);
    
    //sample pattern
    CGContextBeginPath(ctx);
    CGContextMoveToPoint(   ctx, 6.5*width, .25*height);
    CGContextAddLineToPoint(ctx, 6.5*width, 4.9*height);
    CGContextAddLineToPoint(ctx, 7.9*width, 4.9*height);
    CGContextAddLineToPoint(ctx, 7.9*width, .25*height);
    CGContextClosePath(ctx);
    CGContextStrokePath(ctx);

}



@end
