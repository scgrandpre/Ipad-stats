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
    CourtView *court = [[CourtView alloc] initWithFrame:CGRectMake(0,50,1024,592)];
    self.view.backgroundColor = [UIColor clearColor];
    court.userInteractionEnabled = NO;
 
    [self.view addSubview:court];
    
    DrawingView *drawing = [[DrawingView alloc] initWithFrame:CGRectMake(self.view.bounds.origin.x, self.view.bounds.origin.y, self.view.bounds.size.height, self.view.bounds.size.width) choose:^(NSArray *points) {
        NSLog(@"%@", points);
        
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
