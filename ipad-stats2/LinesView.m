//
//  HitView.m
//  ipad-stats2
//
//  Created by Scott Grandpre on 5/23/13.
//  Copyright (c) 2013 RIPP Volleyball. All rights reserved.
//

#import "LinesView.h"
#import "DrawnStatViewController.h"
#import "StatEntryView.h"


@implementation LinesView
@synthesize lines = _lines;

// [[LinesView alloc] initWithFrame:frame lines:line]
// LinesView* linesView = [[LinesView alloc] initWithFrame:frame lines:line];
// [linesView drawRect:rect] --> self === linesView


- (id)initWithFrame:(CGRect)frame {
    return [self initWithFrame:frame lines:@[]];
}

- (id)initWithFrame:(CGRect)frame lines:(NSArray*)lines {
    self = [super initWithFrame:frame];
    if (self) {
        _lines = lines;
        self.backgroundColor = [UIColor clearColor];
        self.userInteractionEnabled = NO;
    }
    return self;
}

- (void)setLines:(NSArray *)lines {
    _lines = lines;
    [self setNeedsDisplay];
}

- (NSArray *)lines {
    return _lines;
}


- (void)drawLine:(NSArray*)line withContext:(CGContextRef)ctx {
    CGContextBeginPath(ctx);
    
    for (int i=0;i<line.count;i++) {
        CGPoint point = [line[i] CGPointValue];
        point.x = point.x * self.bounds.size.width  + self.bounds.origin.x;
        point.y = point.y * self.bounds.size.height + self.bounds.origin.y;
        if(i == 0) {
            CGContextMoveToPoint(ctx, point.x, point.y);
        } else {
            CGContextAddLineToPoint(ctx, point.x, point.y);
        }
    }
    
    CGContextStrokePath(ctx);
}

- (void)drawRect:(CGRect)rect
{
    NSLog(@"in draw rect");
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    CGContextSetStrokeColorWithColor(ctx, [UIColor blackColor].CGColor);
    CGContextSetLineWidth(ctx, 2);
    
    NSLog(@"%@", self.lines);
    for (NSArray* line in self.lines) {
        [self drawLine:line withContext:ctx];
        
        
    }
}

@end
