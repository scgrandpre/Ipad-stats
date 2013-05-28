//
//  DrawingView.m
//  ipad-stats2
//
//  Created by Jim Grandpre on 4/23/13.
//  Copyright (c) 2013 RIPP Volleyball. All rights reserved.
//

#import "DrawingView.h"
#import "EventEmitter.h"


@interface DrawingView ()

@property (strong) NSMutableArray *points;
@property (strong) void (^choose)(NSArray*);

@end

@implementation DrawingView

- (id)initWithFrame:(CGRect)frame {
    return [self initWithFrame:frame choose:nil];
}

- (id)initWithFrame:(CGRect)frame choose:(void (^)(NSArray*))choose {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setBackgroundColor:[UIColor clearColor]];
        self.points = [[NSMutableArray alloc] init];
        self.choose = choose;
    }
    return self;
}

- (CGPoint)pointByNormalizingPoint:(CGPoint)point {
    return CGPointMake((point.x - self.bounds.origin.x)/self.bounds.size.width,
                       (point.y - self.bounds.origin.y)/self.bounds.size.height);
}

- (CGPoint)pointByExpandingPoint:(CGPoint)point {
    return CGPointMake(point.x*self.bounds.size.width  + self.bounds.origin.x,
                       point.y*self.bounds.size.height + self.bounds.origin.y);
                      
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = touches.anyObject;
    [self processTouch:touch];
    [super touchesBegan:touches withEvent:event];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = touches.anyObject;
    [self processTouch:touch];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = touches.anyObject;
    [self processTouch:touch];
    [self emit:@"drew_line" data:self.points];
    self.points = [[NSMutableArray alloc] init];
}

- (void)processTouch:(UITouch*)touch {
    CGPoint location = [touch locationInView:self];
    [self.points addObject: [NSValue valueWithCGPoint:[self pointByNormalizingPoint:location]]];
    [self setNeedsDisplay];
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    CGContextSetStrokeColorWithColor(ctx, [UIColor blackColor].CGColor);
    CGContextSetLineWidth(ctx, 2);
    CGContextBeginPath(ctx);
    if(self.points.count > 0) {
        CGPoint point = [self pointByExpandingPoint:[self.points[0] CGPointValue]];
        CGContextMoveToPoint(ctx, point.x, point.y);
        [self.points emit:@"points" data:self.points];
        //NSLog(@"testing if this prints");
        //NSLog(@"%f", point.x);ct
    }
    for(NSValue *pointVal in self.points) {
        CGPoint point = [self pointByExpandingPoint:[pointVal CGPointValue]];
        CGContextAddLineToPoint(ctx, point.x, point.y);
    }
    CGContextStrokePath(ctx);
}

@end
