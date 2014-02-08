//
//  AnalysisLinesView.m
//  ipad-stats2
//
//  Created by Scott Grandpre on 11/23/13.
//  Copyright (c) 2013 RIPP Volleyball. All rights reserved.
//

#import "AnalysisLinesView.h"

@interface AnalysisLinesView ()

@property NSMutableDictionary *highlights;

@end

@implementation AnalysisLinesView
@synthesize lines = _lines;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _lines = [[NSArray alloc] init];
        _highlights = [[NSMutableDictionary alloc] init];
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (CGPoint)pointByExpandingPoint:(CGPoint)point {
    return CGPointMake((point.x + 1)/2 *self.bounds.size.width  + self.bounds.origin.x,
                       (point.y + .5) *self.bounds.size.height + self.bounds.origin.y);
    
}

- (CGPoint)pointByNormalizingPoint:(CGPoint)point {
    return CGPointMake((point.x - self.bounds.origin.x)/self.bounds.size.width * 2 - 1,
                       (point.y - self.bounds.origin.y)/self.bounds.size.height - .5);
}

- (void)setLines:(NSArray *)lines {
    _lines = lines;
    [self setNeedsDisplay];
}

- (NSArray *)lines {
    return _lines;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = touches.anyObject;
    [self processTouch:touch];
    [super touchesBegan:touches withEvent:event];
    //[[self superview] touchesBegan:touches withEvent:event];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = touches.anyObject;
    [self processTouch:touch];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = touches.anyObject;
    [self processTouch:touch];
}

- (void)processTouch:(UITouch*)touch {
    CGPoint location = [touch locationInView:self];
    location = [self pointByNormalizingPoint:location];
    int closest = 0;
    float closeDist = 1111111;
    for (int i = 0; i < [self.lines count]; i++) {
        NSDictionary *lineDict = self.lines[i];
        NSArray *line = lineDict[@"line"];
        if(line.count > 0) {
            CGPoint point = [line[0] CGPointValue];
            float dist2 = (point.x - location.x) * (point.x - location.x) +
                          (point.y - location.y) * (point.y - location.y);
            if (dist2 < closeDist) {
                closeDist = dist2;
                closest = i;
            }
            self.highlights[[NSNumber numberWithInteger:i]] = [UIColor colorWithWhite:.7 alpha:1];
        }
    }
    self.highlights[[NSNumber numberWithInteger:closest]] = [UIColor colorWithWhite:0 alpha:1];

    [self setNeedsDisplay];
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    
    CGContextSetLineWidth(ctx, 2);
    for (int i = 0; i < [self.lines count]; i++) {
        NSDictionary *lineDict = self.lines[i];
        if (lineDict[@"color"]) {
            CGContextSetStrokeColorWithColor(ctx, [lineDict[@"color"] CGColor]);
        } else {
            CGContextSetStrokeColorWithColor(ctx, [UIColor blackColor].CGColor);
        }
        //Show the highlights so we can see what we're selecting
        //CGContextSetStrokeColorWithColor(ctx, [self.highlights[[NSNumber numberWithInteger:i]] CGColor]);
        CGContextBeginPath(ctx);
        NSArray *line = lineDict[@"line"];
        if(line.count > 0) {
            CGPoint point = [self pointByExpandingPoint:[line[0] CGPointValue]];
            CGContextAddEllipseInRect(ctx, CGRectMake(point.x - 5, point.y - 5, 10, 10));
            CGContextMoveToPoint(ctx, point.x, point.y);
        }
        for(NSValue *pointVal in line) {
            CGPoint point = [self pointByExpandingPoint:[pointVal CGPointValue]];
            CGContextAddLineToPoint(ctx, point.x, point.y);
        }
        CGContextStrokePath(ctx);
    }
}



@end
