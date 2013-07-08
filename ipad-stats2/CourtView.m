//
//  CourtView.m
//  ipad-stats
//
//  Created by Jim Grandpre on 4/11/13.
//  Copyright (c) 2013 RIPP Volleyball. All rights reserved.
//

#import "CourtView.h"
#import "DrawingView.h"
#import <EventEmitter.h>
#import "Play.h"

static float PADDING_RATIO = 1/8.f;

@interface CourtView ()

@end

@implementation CourtView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        
        DrawingView *drawingView = [[DrawingView alloc] initWithFrame:self.bounds];
        [self addSubview:drawingView];
        
        [drawingView on:@"drew-line" callback:^(NSArray* line) {
            NSMutableArray *normalized = [[NSMutableArray alloc] init];

            
            for (NSValue *pointValue in line) {
                CGPoint point = [pointValue CGPointValue];
                
                point.x = (point.x*2 - 1) / (1 - 2*PADDING_RATIO);
                point.y = (point.y - .5) / (1 - 2*PADDING_RATIO);
                
                [normalized addObject:[NSValue valueWithCGPoint:point]];
            }
            [self emit:@"drew-line" data:normalized];
        }];
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    float width = self.bounds.size.width;
    float height = self.bounds.size.height;
    CGContextSetStrokeColorWithColor(ctx, [UIColor blackColor].CGColor);
    CGContextSetLineWidth(ctx, 4);
    
    CGFloat left   =          PADDING_RATIO * width;
    CGFloat top    =          PADDING_RATIO * height;
    CGFloat right  = width -  PADDING_RATIO * width;
    CGFloat bottom = height - PADDING_RATIO * height;
    
    // BORDER
    CGContextBeginPath(ctx);
    CGContextMoveToPoint(   ctx, left,  top);
    CGContextAddLineToPoint(ctx, left,  bottom);
    CGContextAddLineToPoint(ctx, right, bottom);
    CGContextAddLineToPoint(ctx, right, top);
    CGContextClosePath(ctx);
    
    // NET
    CGFloat net_x = (left + right)/2;
    CGContextMoveToPoint(   ctx, net_x, top);
    CGContextAddLineToPoint(ctx, net_x, bottom);
    
    //10 FT Lines
    CGContextMoveToPoint(   ctx, left +   (right - left)/3.f,  top);
    CGContextAddLineToPoint(ctx, left +   (right - left)/3.f,  bottom);
    CGContextMoveToPoint(   ctx, left + 2*(right - left)/3.f,  top);
    CGContextAddLineToPoint(ctx, left + 2*(right - left)/3.f,  bottom);
    CGContextStrokePath(ctx);

}



@end
