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
#import "LinesView.h"


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
- (void)viewDidLoad
{
    [super viewDidLoad];
    NSLog(@"%@", NSStringFromCGRect(self.view.bounds));
    
    
    CourtView* court = [[CourtView alloc] initWithFrame:CGRectMake(0,50,1024,592)];
    self.view.backgroundColor = [UIColor clearColor];
    court.userInteractionEnabled = NO;
 
    [self.view addSubview:court];
    
    LinesView* linesView = [[LinesView alloc] initWithFrame:CGRectMake(self.view.bounds.origin.x, self.view.bounds.origin.y, self.view.bounds.size.height, self.view.bounds.size.width)];
    [self.view addSubview:linesView];
    
    
    
    DrawingView *drawing = [[DrawingView alloc] initWithFrame:CGRectMake(self.view.bounds.origin.x, self.view.bounds.origin.y, self.view.bounds.size.height, self.view.bounds.size.width)];

    [drawing on:@"drew_line" callback:^(NSArray* points) {
        linesView.lines = [linesView.lines arrayByAddingObject:points];
    }];
        
    [self.view addSubview:drawing];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
