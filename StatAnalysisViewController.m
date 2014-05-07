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
#import <MediaPlayer/MediaPlayer.h>

#import <AVFoundation/AVFoundation.h>
#import "AVPlayerView.h"

@interface StatAnalysisViewController ()
@property UITextView *text;
@property Game *game;
@property StatAnalyzer *StatAnalyzer;
@property AnalysisLinesView *linesView;
@property NSString *selectedPlayer;
@property NSString *skill;
@property AVPlayer *video;
@property AVPlayerView *videoPlayer;
@end

@implementation StatAnalysisViewController
@synthesize selectedPlayer = _selectedPlayer;
@synthesize skill = _skill;

-(id)initWithGame:(Game*) game {
    self = [super init];
    self.game = game;
    self.StatAnalyzer = [[StatAnalyzer alloc] initWithGame: game];
    _skill = @"Hit";
    
    [game on:@"play-added" callback:^(id arg0) {
        [self updateLines];
    }];
    
    return self;
}

-(void)loadView {
    [super loadView];
    self.text = [[UITextView alloc] initWithFrame:CGRectMake(CGRectGetMaxY(self.view.bounds) - 300, CGRectGetMaxX(self.view.bounds) -400, 300, 400)];
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
    [_linesView on:@"selected-stat" callback:^(Stat *stat) {
        NSLog(@"%@", stat);
        Stat *firstStat = [self.game.plays[0] stats][0];
        NSDate *firstStatTime = firstStat.timestamp;
        NSTimeInterval offset = [stat.timestamp timeIntervalSinceDate:firstStatTime];
        // TODO(jim): Figure out the right time from stat.timestamp
        [self.videoPlayer seekToTime:CMTimeMakeWithSeconds(offset + 1637, 1)];
        [self.videoPlayer play];
    }];
    
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
    
    _video = [[AVPlayer alloc] initWithURL:[NSURL URLWithString:@"http://acsvolleyball.com/videos/shu_liu_a.mp4"]];
    _videoPlayer = [[AVPlayerView alloc] initWithFrame:CGRectMake(500, 0, 400, 300)];
    [_videoPlayer setPlayer:_video];
    [self.view addSubview:self.videoPlayer];

}

-(void)viewDidAppear:(BOOL)animated {
    self.text.text = [self basicStats];
}


- (NSString*)basicStats {
    ///kills by team 0
    NSString *playerFilter = self.selectedPlayer;
    //if (playerFilter == nil){
      //  playerFilter = nil;
    //}
    
    
    NSLog(@"%s%@","playerFilter: ",playerFilter);
    
    
    NSUInteger kills = [self.game filterEventsBy:@{@"skill": @"Hit", @"details": @{@"result":@"kill"}}].count;
    
    //NSUInteger killsTeam0 = [self.game filterEventsBy:@{@"skill": @"Hit", @"details": @{@"result":@"kill", @"details": @{@"team":@"0"}}}].count;
    
    NSUInteger hittingAttempts = [self.game filterEventsBy:@{@"skill": @"Hit"}].count;
    NSUInteger hittingErrors = [self.game filterEventsBy:@{@"skill": @"Hit", @"details": @{@"result":@"error"}}].count;
    
    ///passing stat team 0
    
    NSLog(@"here I am");
    NSUInteger passingAttempts = [self.game filterEventsBy:@{@"skill": @"Serve"}].count;
    NSUInteger pass4 = [self.game filterEventsBy:@{@"skill": @"Serve", @"details": @{@"result":@"4"}}].count;
    NSUInteger pass3 = [self.game filterEventsBy:@{@"skill": @"Serve", @"details": @{@"result":@"3"}}].count;
    NSUInteger pass2 = [self.game filterEventsBy:@{@"skill": @"Serve", @"details": @{@"result":@"2"}}].count;
    NSUInteger pass1 = [self.game filterEventsBy:@{@"skill": @"Serve", @"details": @{@"result":@"1"}}].count;
    NSUInteger pass0 = [self.game filterEventsBy:@{@"skill": @"Serve", @"details": @{@"result":@"0"}}].count;
    NSUInteger passAce = [self.game filterEventsBy:@{@"skill": @"Serve", @"details": @{@"result":@"ace"}}].count;
    NSUInteger passStat = 0;
    if ((pass4+pass3+pass2+pass1+pass0+passAce) > 0){
        passStat = (pass4*4+pass3*3+pass2*2+pass1*1)/(pass4+pass3+pass2+pass1+pass0+passAce);
    }   
    
    
    
    
    //NSUInteger countPasses = 0;
    //for (i in [self filterEventsBy:@{@"skill": @"SERVE"}]){
    //    countPasses += i
    
    //}
    //NSString *passStat = countPasses
    
    
    
    
    NSLog(@"%lu\n%lu", (unsigned long)passingAttempts, (unsigned long)pass4);
    
    
    return [NSString stringWithFormat:@"Attempts: %lu\nKills: %lu\nErrors: %lu\nHitting Average: %f\nCurrent Player: %@\nPass Stat: %lu", (unsigned long)hittingAttempts, (unsigned long)kills, (unsigned long)hittingErrors, ((float)kills - hittingErrors)/hittingAttempts,  self.selectedPlayer,  (unsigned long)passStat];
}

- (void)updateLines {
    NSMutableDictionary *filter = [[NSMutableDictionary alloc] initWithDictionary:@{@"skill": self.skill}];
    if (self.selectedPlayer != nil) {
        filter[@"player"] = self.selectedPlayer;
    }
    self.linesView.stats = [self.game filterEventsBy:filter];
    self.text.text = [self basicStats];
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
