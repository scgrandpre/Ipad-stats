//
//  StatViewController.m
//  ipad-stats2
//
//  Created by Jim Grandpre on 4/11/13.
//  Copyright (c) 2013 RIPP Volleyball. All rights reserved.
//

#import "StatViewController.h"
#import "CourtView.h"
#import "ScoreView.h"
#import "EventEmitter.h"

@interface RotationButtonView : UIView
@property (strong) void (^rotate)(int);
@end

@implementation RotationButtonView

- (id)initWithFrame:(CGRect)frame rotate:(void (^)(int)) rotate {
    self = [super initWithFrame:frame];
    if (self) {
        self.rotate = rotate;
        
        float width = self.bounds.size.width/2;
        
        UIButton *rotateBack = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        rotateBack.frame = CGRectMake(self.bounds.origin.x, self.bounds.origin.y, width, self.bounds.size.height);
        rotateBack.titleLabel.font = [UIFont systemFontOfSize:16];
        [rotateBack setTitle:@"-1" forState:UIControlStateNormal];
        [rotateBack addTarget:self action:@selector(rotateBack:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview: rotateBack];
        
        UIButton *rotateForward = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        rotateForward.frame = CGRectMake(self.bounds.origin.x + width, self.bounds.origin.y, width, self.bounds.size.height);
        rotateForward.titleLabel.font = [UIFont systemFontOfSize:16];
        [rotateForward setTitle:@"+1" forState:UIControlStateNormal];
        [rotateForward addTarget:self action:@selector(rotateForward:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview: rotateForward];
        
    }
    return self;
}

- (void)rotateBack:(UIButton*)button {
    self.rotate(-1);
}

- (void)rotateForward:(UIButton*)button {
    self.rotate(1);
}

@end

@interface StatViewController ()
@property int servingTeam;
@property NSMutableArray *stats;
@end

@implementation StatViewController

- (id)initWithStats:(NSMutableArray*)stats {
    self = [super init];
    if (self) {
        self.stats = stats;
        self.servingTeam = 0;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    CourtView *court = [[CourtView alloc] initWithFrame:CGRectMake(0,50,1024,592)];
    
    ScoreView *scoreView = [[ScoreView alloc] initWithFrame:CGRectMake(0, 0, 200, 100) flipped:NO increment: ^{
        if(self.servingTeam != 0) {
            [court rotateWithTeam:@"0" increment:1];
            self.servingTeam = 0;
        }
    }];
    [self.view addSubview:scoreView];
    
    RotationButtonView *rotationButtons = [[RotationButtonView alloc] initWithFrame:CGRectMake(250, 0, 133, 50) rotate:^(int increment) {
        [court rotateWithTeam:@"0" increment:increment];
    }];
    [self.view addSubview:rotationButtons];
    
    ScoreView *otherScoreView = [[ScoreView alloc] initWithFrame:CGRectMake(self.view.bounds.origin.x + self.view.bounds.size.height - 200, self.view.bounds.origin.y, 200, 100) flipped: YES increment:^{
        if(self.servingTeam != 1) {
            [court rotateWithTeam:@"1" increment:1];
            self.servingTeam = 1;
        }
    }];
    [self.view addSubview:otherScoreView];
    
    RotationButtonView *otherRotationButtons = [[RotationButtonView alloc] initWithFrame:CGRectMake(self.view.bounds.size.height - (250 + 133), 0, 133, 50) rotate:^(int increment) {
        [court rotateWithTeam:@"1" increment:increment];
    }];
    [self.view addSubview:otherRotationButtons];
    
    self.view.backgroundColor = [UIColor clearColor];
 
    [self.view addSubview:court];
    
    [court on:@"end_play" callback:^(NSDictionary* play) {
        NSLog(@"%@", play);
        NSString *winner = play[@"winner"];
        if([winner compare: @"0"] == NSOrderedSame) {
            [scoreView increment];
        } else {
            [otherScoreView increment];
        }
        [self.stats addObject:play];
    }];
    

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
