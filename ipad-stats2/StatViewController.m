//
//  StatViewController.m
//  ipad-stats2
//
//  Created by Jim Grandpre on 4/11/13.
//  Copyright (c) 2013 RIPP Volleyball. All rights reserved.
//

#import "StatViewController.h"
#import "CourtView.h"

@interface StatViewController ()

@end

@implementation StatViewController
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
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
 
    [self.view addSubview:court];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
