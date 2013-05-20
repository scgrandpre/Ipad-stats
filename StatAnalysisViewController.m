//
//  StatAnalysisViewController.m
//  ipad-stats2
//
//  Created by Jim Grandpre on 4/25/13.
//  Copyright (c) 2013 RIPP Volleyball. All rights reserved.
//

#import "StatAnalysisViewController.h"
#import "Game.h"
#import "Play.h"
#import "Stat.h"
#import "StatAnalyzer.h"

@interface StatAnalysisViewController ()
@property UITextView *text;
@property Game *game;
@property StatAnalyzer *StatAnalyzer;
@end




@implementation StatAnalysisViewController

-(id)initWithGame:(Game*) game {
    self = [super init];
    self.game = game;
    self.StatAnalyzer = [[StatAnalyzer alloc] initWithGame: game];
    
    return self;
}

-(void)loadView {
    [super loadView];
    self.text = [[UITextView alloc] initWithFrame:self.view.bounds];
    self.text.editable = NO;
    [self.view addSubview: self.text];
    
}

-(void)viewDidAppear:(BOOL)animated {
    self.text.text = [self basicStats];
}


- (NSString*)basicStats {
    ///kills by team 0
    int kills = [self.game filterEventsBy:@{@"skill": @"HIT", @"details": @{@"RESULT":@"KILL"}}].count;
    int hittingAttempts = [self.game filterEventsBy:@{@"skill": @"HIT"}].count;
    int hittingErrors = [self.game filterEventsBy:@{@"skill": @"HIT", @"details": @{@"RESULT":@"ERROR"}}].count;
    
    ///passing stat team 0
    int passingAttempts = [self.game filterEventsBy:@{@"skill": @"SERVE"}].count;
    int pass4 = [self.game filterEventsBy:@{@"skill": @"SERVE", @"details": @{@"RESULT":@"4"}}].count;
    int countPasses = 0;
    //for (i in [self filterEventsBy:@{@"skill": @"SERVE"}]){
    //    countPasses += i
    
    //}
    //NSString *passStat = countPasses
    
    
    NSLog(@"%d\n%d", passingAttempts, pass4);
    
    
    return [NSString stringWithFormat:@"Attempts: %i\nKills: %i\nErrors: %i\nHitting Average: %f\n4 Passes: %i", hittingAttempts, kills, hittingErrors, ((float)kills - hittingErrors)/hittingAttempts, pass4];
    
    
    
    
}

@end
