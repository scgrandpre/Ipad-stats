//
//  AnalysisLinesView.m
//  ipad-stats2
//
//  Created by Scott Grandpre on 11/23/13.
//  Copyright (c) 2013 RIPP Volleyball. All rights reserved.
//

#import "AnalysisLinesView.h"
#import <EventEmitter.h>

@interface AnalysisLinesView ()

@property NSMutableDictionary *highlights;
@property Stat *selectedStat;

@end

@implementation AnalysisLinesView
@synthesize stats = _stats;
@synthesize selectedStat = _selectedStat;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _stats = [[NSArray alloc] init];
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

- (void)setLines:(NSArray *)stats {
    _stats = stats;
    [self setNeedsDisplay];
}

- (void)setStats:(NSArray *)stats {
    [self setLines:stats];
    _stats = stats;
}

- (NSArray *)stats {
    return _stats;
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
    if ([self.stats count] == 0) {
        return;
    }
    CGPoint location = [touch locationInView:self];
    location = [self pointByNormalizingPoint:location];
    int closest = 0;
    float closeDist = 1111111;
    for (int i = 0; i < [self.stats count]; i++) {
        NSDictionary *lineDict = [self lineDictForStat:self.stats[i]];;
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
    self.selectedStat = self.stats[closest];


    [self setNeedsDisplay];
}

- (NSDictionary*)lineDictForStat:(Stat*)stat {
    NSDictionary *resultColor = @{@"kill":  [UIColor colorWithRed:.5 green:.5 blue:1 alpha:.9],
                                  @"error": [UIColor colorWithRed:1 green:.5 blue:.5 alpha:.9],
                                  @"err": [UIColor colorWithRed:1 green:.5 blue:.5 alpha:.9],
                                  
                                  @"ace":  [UIColor colorWithRed:.5 green:.5 blue:1 alpha:.9],
                                  @"us": [UIColor colorWithRed:.5 green:.5 blue:.7 alpha:.2],
                                  @"them": [UIColor colorWithRed:.7 green:.5 blue:.5 alpha:.2],
                                  @"0": [UIColor colorWithRed:.5 green:.5 blue:.7 alpha:.2],
                                  @"1": [UIColor colorWithRed:.5 green:.5 blue:.7 alpha:.2],
                                  @"2": [UIColor colorWithRed:.5 green:.5 blue:.7 alpha:.2],
                                  @"3": [UIColor colorWithRed:.5 green:.5 blue:.7 alpha:.2],
                                  @"4": [UIColor colorWithRed:.5 green:.5 blue:.7 alpha:.2],
                                  @"Overpass": [UIColor colorWithRed:.5 green:.5 blue:.7 alpha:.2],
                                  
                                  };
    return @{@"line":stat.details[@"line"] ? stat.details[@"line"] : @[] ,
             @"color": resultColor[stat.details[@"result"] ? stat.details[@"result"] : @"kill"]};
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    
    CGContextSetLineWidth(ctx, 2);
    for (int i = 0; i < [self.stats count]; i++) {
        NSDictionary *lineDict = [self lineDictForStat:self.stats[i]];
        if (lineDict[@"color"]) {
            CGContextSetStrokeColorWithColor(ctx, [lineDict[@"color"] CGColor]);
        } else {
            CGContextSetStrokeColorWithColor(ctx, [UIColor blackColor].CGColor);
        }
        //Show the highlights so we can see what we're selecting
        CGContextSetStrokeColorWithColor(ctx, [self.highlights[[NSNumber numberWithInteger:i]] CGColor]);
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

- (Stat *)selectedStat {
    return _selectedStat;
}

- (void)setSelectedStat:(Stat *)selectedStat {
    if (selectedStat == _selectedStat) {
        return;
    }
    _selectedStat = selectedStat;
    [self emit:@"selected-stat" data:selectedStat];
}

@end
