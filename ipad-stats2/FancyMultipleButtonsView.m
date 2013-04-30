//
//  FancyMultipleButtonsView.m
//  ipad-stats2
//
//  Created by Jim Grandpre on 4/11/13.
//  Copyright (c) 2013 RIPP Volleyball. All rights reserved.
//

#import "FancyMultipleButtonsView.h"
#import <UIKit/NSText.h>

#define M_TAU (M_PI*2)

@interface FancyMultipleButtonsView ()
@property NSArray *options;
@property BOOL menuOpen;
@property int  currentSelection;
@property(strong) void (^choose)(int choice, UITouch*);
@property(strong) UITouch* currentTouch;
@end

static CGFloat CENTER_SIZE = .5;

@implementation FancyMultipleButtonsView

- (id)initWithFrame:(CGRect)frame label:(NSString*)label options:(NSArray*)options choose:(void (^)(int, UITouch*)) choose {
    self = [self initWithFrame:frame];
    if(self) {
        self.choose = choose;
        self.options = options;
        self.label = label;
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

/*
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
    [self select];
}
 */

- (void)select {
    if(self.currentSelection >= 0 && self.menuOpen) {
        self.choose(self.currentSelection, self.currentTouch);
    }
    self.menuOpen = NO;
    [self setNeedsDisplay];
}

- (void)processTouch:(UITouch*) touch {
    CGPoint touchLocation = [touch locationInView:self];
    CGPoint center = CGPointMake(self.bounds.origin.x + self.bounds.size.width/2, self.bounds.origin.y + self.bounds.size.height/2);
    CGFloat radius = MIN(self.bounds.size.width, self.bounds.size.height) * CENTER_SIZE;
    if(YES || !self.menuOpen) {
        CGFloat dist2 = (center.x - touchLocation.x) * (center.x - touchLocation.x) + (center.y - touchLocation.y) * (center.y - touchLocation.y);
        if (dist2 < (.25 * radius*radius)) {
            if(!self.menuOpen || self.currentSelection >= 0) { [self setNeedsDisplay]; }
            self.menuOpen = YES;
            self.currentSelection = -1;
        } else {
            CGFloat angle = atan2(touchLocation.y - center.y, touchLocation.x - center.x);
            CGFloat offset = M_TAU/4 + (1.f/self.options.count * M_TAU/2);
            int currentSelection = (int)((((angle + offset)/M_TAU) * self.options.count) + self.options.count) % self.options.count;
            self.currentTouch = touch;
            if(currentSelection != self.currentSelection) { [self setNeedsDisplay]; }
            self.currentSelection = currentSelection;
        }
        if (dist2 > 4 * (radius * radius)/4) {
            [self select];
        }
    }
}

- (BOOL)pointInside:(CGPoint)touchLocation withEvent:(UIEvent *)event{
    CGPoint center = CGPointMake(self.bounds.origin.x + self.bounds.size.width/2, self.bounds.origin.y + self.bounds.size.height/2);
    CGFloat radius = MIN(self.bounds.size.width, self.bounds.size.height) * CENTER_SIZE;
    CGFloat dist2 = (center.x - touchLocation.x) * (center.x - touchLocation.x) + (center.y - touchLocation.y) * (center.y - touchLocation.y);
    return (self.menuOpen || dist2 < (.25 * radius * radius));
}

- (void)drawText:(NSString*)text atPoint:(CGPoint)point {
    CGRect theRect = CGRectMake(point.x-200, point.y - 20/2, 400, 20);
    [text drawInRect:theRect withFont:[UIFont systemFontOfSize:20] lineBreakMode:NSLineBreakByClipping alignment:NSTextAlignmentCenter];
}


- (void)drawRect:(CGRect)rect
{
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    CGFloat radius = MAX(self.bounds.size.width, self.bounds.size.height)/2;
    CGFloat outerRadius = MAX(self.bounds.size.width, self.bounds.size.height)/2;
    CGPoint center = CGPointMake(self.bounds.origin.x + self.bounds.size.width/2, self.bounds.origin.y + self.bounds.size.height/2);
    if(!self.menuOpen){
        CGContextSetFillColorWithColor(ctx, [UIColor blueColor].CGColor);
    } else {
        for(int i=0; i < self.options.count; i++) {
            CGFloat angle = (((CGFloat)i)/self.options.count) * M_TAU - M_TAU/4;
            
            if(i == self.currentSelection) {
                CGContextSetFillColorWithColor(ctx, [UIColor redColor].CGColor);
            }
            [self drawText:self.options[i] atPoint:CGPointMake(center.x + self.bounds.size.width/2*cos(angle)/1.5, center.y + self.bounds.size.height/2*sin(angle)/1.2)];
            
            CGContextSetFillColorWithColor(ctx, [UIColor blackColor].CGColor);
            CGFloat lineAngle = angle - (1.f/self.options.count * M_TAU/2);
            CGContextSetStrokeColorWithColor(ctx, [UIColor blackColor].CGColor);
            CGContextSetLineWidth(ctx, 2);
            CGContextBeginPath(ctx);
            CGContextMoveToPoint(ctx, center.x, center.y);
            CGContextAddLineToPoint(ctx, center.x + outerRadius*cos(lineAngle), center.y + outerRadius*sin(lineAngle));
            CGContextStrokePath(ctx);
        }
        CGContextSetFillColorWithColor(ctx, [UIColor greenColor].CGColor);
    }
    CGFloat middle_radius = MIN(self.bounds.size.width, self.bounds.size.height) * CENTER_SIZE;
    CGRect middle = CGRectMake(center.x - middle_radius/2, center.y - middle_radius/2, middle_radius, middle_radius);
    CGContextFillEllipseInRect(ctx, middle);
    CGContextSetFillColorWithColor(ctx, [UIColor blackColor].CGColor);
    [self drawText:self.label atPoint:center];
}

@end
