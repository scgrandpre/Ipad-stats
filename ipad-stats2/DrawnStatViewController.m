//
//  DrawnStatViewController.m
//  ipad-stats2
//
//  Created by Jim Grandpre on 4/23/13.
//  Copyright (c) 2013 RIPP Volleyball. All rights reserved.
//

#import "DrawnStatViewController.h"
#import "CourtView.h"
#import "DrawingView.h"
#import "FullScreenChoiceViewController.h"
#import "Game.h"
#import "CourtView.h"
#import "CourtOverlayView.h"
#import <EventEmitter.h>
#import "Play.h"

@interface DrawnStatViewController ()

@end

@implementation DrawnStatViewController


- (id)initWithGame:(Game*)game {
    self = [super init];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)drawRect:(CGRect)rect {

}
- (void)viewDidLoad
{
    [super viewDidLoad];
    NSLog(@"%@", NSStringFromCGRect(self.view.bounds));
    CourtView *court = [[CourtView alloc] initWithFrame:CGRectMake(0,50,1024,592)];
    self.view.backgroundColor = [UIColor clearColor];
    court.userInteractionEnabled = NO;
 
    [self.view addSubview:court];
    
    DrawingView *drawing = [[DrawingView alloc] initWithFrame:CGRectMake(self.view.bounds.origin.x, self.view.bounds.origin.y, self.view.bounds.size.height, self.view.bounds.size.width) choose:^(NSArray *points) {
        
        //CGContextRef ctx = UIGraphicsGetCurrentContext();
        //CGContextSetStrokeColorWithColor(ctx, [UIColor blackColor].CGColor);
        //CGContextSetLineWidth(ctx, 4);
        
        // draw line
        //CGContextBeginPath(ctx);
        //CGContextMoveToPoint(   ctx, points);
        //CGContextAddLineToPoint(ctx, 4*width, 2.5*height);
        //[CGContextStrokePath(ctx);
        
        
        NSLog(@"here?");
        NSLog(@"%@", points);
        NSMutableDictionary *pointsDict = [[NSMutableDictionary alloc] init]; // Don't always need this
        // Note you can't use setObject: forKey: if you are using NSDictionary
        
        [pointsDict setObject:points forKey:@"Key1"];
        for (id key in pointsDict) {
            NSLog(@"key: %@, value: %@ \n", key, [pointsDict objectForKey:key]);
        }
        
        CGContextRef ctx = UIGraphicsGetCurrentContext();
        
        CGContextSetStrokeColorWithColor(ctx, [UIColor blackColor].CGColor);
        CGContextSetLineWidth(ctx, 2);
        CGContextBeginPath(ctx);
        NSLog(@"first point: %@",[pointsDict objectForKey:@"Key1"][0]);
        CGPoint point = [[pointsDict objectForKey:@"Key1"][0] CGPointValue];
        NSLog(@"pointx: %f, pointy: %f", point.x, point.y);
        CGContextMoveToPoint(ctx, point.x, point.y);
        
        for (id currentPoint in [pointsDict objectForKey:@"Key1"]) {
            CGPoint point = [currentPoint CGPointValue];
            CGContextAddLineToPoint(ctx, point.x, point.y);

            
            NSLog(@"testingDictionary");
            NSLog(@"%@",currentPoint);
        
        }
        CGContextStrokePath(ctx);
        

     //   FullScreenChoiceViewController *chooser = [[FullScreenChoiceViewController alloc] initWithChoices:@[@"Intent to Score", @"Safe Hit"] choose:^(int choice) {
     //       NSLog(@"%d", choice);
     //       [self dismissViewControllerAnimated:NO completion:nil];
     //   }];
     //   [self presentViewController:chooser animated:NO completion:nil];
    }];
    [self.view addSubview:drawing];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
