//
//  FullScreenChoiceViewController.m
//  ipad-stats2
//
//  Created by Jim Grandpre on 4/23/13.
//  Copyright (c) 2013 RIPP Volleyball. All rights reserved.
//

#import "FullScreenChoiceViewController.h"

@interface FullScreenChoiceViewController ()
@property (strong) NSArray* choices;
@property (strong) void (^choose)(int);
@property (strong) NSArray* colors;
@end

@implementation FullScreenChoiceViewController

- (id)initWithChoices:(NSArray*)choices choose:(void (^)(int)) choose {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        self.choices = choices;
        self.choose = choose;
        self.colors = @[[UIColor greenColor], [UIColor redColor]];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    CGRect bounds = self.view.bounds;
    int dx = bounds.size.height/self.choices.count;
    for(int i=0; i < self.choices.count; i++) {
        CGRect frame = CGRectMake(bounds.origin.x + dx * i, bounds.origin.y, dx, bounds.size.width);
        UIButton *button = [[UIButton alloc] initWithFrame:frame];
        [button setTitle:self.choices[i] forState:UIControlStateNormal];
        [self.view addSubview:button];
        button.backgroundColor = self.colors[i % self.colors.count];
        button.tag = i;
        [button addTarget:self action:@selector(click:) forControlEvents:UIControlEventTouchUpInside];
    }
    
}

- (void)click:(UIButton*)button {
    self.choose(button.tag);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
