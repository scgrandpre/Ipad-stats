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
#import "CourtView.h"
#import "AnalysisLinesView.h"
#import "StatEventButtonsView.h"
#import <EventEmitter/EventEmitter.h>

@interface StatAnalysisViewController ()
@property UITextView *text;
@property Game *game;
@property StatAnalyzer *StatAnalyzer;
@property AnalysisLinesView *linesView;
@property NSString *selectedPlayer;
@property NSString *skill;
@end

@implementation StatAnalysisViewController
@synthesize selectedPlayer = _selectedPlayer;
@synthesize skill = _skill;

-(id)initWithGame:(Game*) game {
    self = [super init];
    self.game = game;
    self.StatAnalyzer = [[StatAnalyzer alloc] initWithGame: game];
    _skill = @"Hit";
    
    return self;
}

-(void)loadView {
    [super loadView];
    self.text = [[UITextView alloc] initWithFrame:self.view.bounds];
    self.text.editable = NO;

    [self.view addSubview: self.text];
    
    CGFloat courtAspectRatio = 8/5.f;
    CGFloat height = self.view.bounds.size.height;
    CGFloat width = self.view.bounds.size.width;
    
    if (height * courtAspectRatio > width) {
        height = width/courtAspectRatio;
    } else {
        width = height * courtAspectRatio;
    }

    
    CourtView *courtView = [[CourtView alloc] initWithFrame:CGRectMake(self.view.bounds.origin.x + self.view.bounds.size.width/2 - width/2,
                                                                    self.view.bounds.origin.y + (self.view.bounds.size.height)/2 - height/2, width, height)];
    [self.view addSubview:courtView];
    
    _linesView = [[AnalysisLinesView alloc] initWithFrame:[courtView courtRect]];
    [self.view addSubview:_linesView];
    
    StatEventButtonsView *subsView = [[StatEventButtonsView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 200)];
    [self.view addSubview:subsView];
    subsView.buttonTitles = @[@"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", @"10", @"11", @"12", @"13", @"14", @"15", @"16", @"17", @"18", @"19", @"20"];
    
    self.selectedPlayer = nil;
    [subsView on:@"button-pressed" callback:^(NSString* player) {
        if (self.selectedPlayer == player) {
            subsView.selectedButton = nil;
            self.selectedPlayer = nil;
            return;
        }
        subsView.selectedButton = player;
        self.selectedPlayer = player;
    }];
    
    StatEventButtonsView *skillsView = [[StatEventButtonsView alloc] initWithFrame:CGRectMake(0, 200, self.view.bounds.size.width, 100)];
    [self.view addSubview:skillsView];
    skillsView.buttonTitles = @[@"Hit", @"Serve"];
    
    [skillsView on:@"button-pressed" callback:^(NSString* skill) {
        skillsView.selectedButton = skill;
        self.skill = skill;
    }];
    skillsView.selectedButton = self.skill;

}

-(void)viewDidAppear:(BOOL)animated {
    //self.text.text = [self basicStats];
}


- (NSString*)basicStats {
    ///kills by team 0
    int kills = [self.game filterEventsBy:@{@"skill": @"HIT"}].count;
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

- (void)updateLines {
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
                                  };

    NSMutableArray *lines = [[NSMutableArray alloc] init];
    NSMutableDictionary *filter = [[NSMutableDictionary alloc] initWithDictionary:@{@"skill": self.skill}];
    if (self.selectedPlayer != nil) {
        filter[@"player"] = self.selectedPlayer;
    }
    for (Stat *stat in [self.game filterEventsBy:filter]) {
        if (stat.details[@"line"]) {
            [lines addObject:@{@"line":stat.details[@"line"],
                               @"color": resultColor[stat.details[@"result"]]}];
        }
    }
    self.linesView.lines = lines;
}

- (void)setSelectedPlayer:(NSString *)selectedPlayer {
    _selectedPlayer = selectedPlayer;
    [self updateLines];
}

- (NSString *)selectedPlayer {
    return _selectedPlayer;
}

- (void)setSkill:(NSString *)skill {
    _skill = skill;
    [self updateLines];
}

- (NSString *)skill {
    return _skill;
}

@end
