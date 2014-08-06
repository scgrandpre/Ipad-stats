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
#import "StatFilterView.h"
#import "CourtView.h"
#import "AnalysisLinesView.h"
#import "StatEventButtonsView.h"
#import "StatAnalysisVideoPlayer.h"
#import <EventEmitter/EventEmitter.h>
#import <MediaPlayer/MediaPlayer.h>

@interface StatAnalysisViewController ()
@property Game *game;

@property(readonly) UITextView *statsTextView;
@property(readonly) AnalysisLinesView *linesView;
@property(readonly) CourtView *courtView;
@property(readonly) UITextField *field;
@property(readonly) UITextView *offset;
@property(readonly) StatFilterView *filters;
@property(readonly) StatAnalysisVideoPlayer *videoPlayer;
@end

@implementation StatAnalysisViewController
@synthesize statsTextView = _statsTextView;
@synthesize linesView = _linesView;
@synthesize courtView = _courtView;
@synthesize field = _field;
@synthesize offset = _offset;
@synthesize videoPlayer = _videoPlayer;
@synthesize filters = _filters;

- (id)initWithGame:(Game *)game {
    self = [super init];
    self.game = game;
    
    [game on:@"play-added"
    callback:^(id arg0) {
        [self updateStats];
        self.filters.stats = [[self game] allStats];
    }];
    
    return self;
}

- (void)loadView {
    [super loadView];
    [self.view addSubview:self.statsTextView];
    [self.view addSubview:self.field];
    [self.view addSubview:self.offset];
    [self.view addSubview:self.filters];
    [self.view addSubview:self.courtView];
    [self.view addSubview:self.videoPlayer];
    [self.view addSubview:self.linesView];
    self.videoPlayer.hidden = YES;
}

- (void)viewWillLayoutSubviews {
    CGFloat courtAspectRatio = 8 / 5.f;
    CGFloat courtWidth = self.view.bounds.size.width;
    CGFloat courtHeight = courtWidth / courtAspectRatio;
    self.courtView.frame =
    CGRectMake(self.view.bounds.origin.x,
               CGRectGetMaxY(self.view.bounds) - courtHeight - 20, courtWidth,
               courtHeight);
    self.linesView.frame = [self.courtView courtRect];
    
    self.filters.frame =
    CGRectMake(self.view.bounds.origin.x, self.view.bounds.origin.y,
               self.view.bounds.size.width / 2,
               self.view.bounds.size.height - courtHeight - 20);
    
    self.videoPlayer.frame =
    CGRectMake(self.view.bounds.origin.x, self.view.bounds.origin.y,
               self.view.bounds.size.width,
               self.view.bounds.size.height - courtHeight - 20);
}

- (UITextView *)statsTextView {
    CGFloat courtAspectRatio = 8 / 5.f;
    CGFloat courtWidth = self.view.bounds.size.width;
    CGFloat courtHeight = courtWidth / courtAspectRatio;
    if (_statsTextView == nil) {
        _statsTextView = [[UITextView alloc]
                          initWithFrame:CGRectMake(
                                                   self.view.bounds.size.width / 2,
                                                   self.view.bounds.origin.y,
                                                   self.view.bounds.size.width / 2,
                                                   self.view.bounds.size.height - courtHeight - 20)];
        _statsTextView.editable = NO;
    }
    return _statsTextView;
}

- (UITextField *)field {
    if (_field == nil) {
        _field = [[UITextField alloc] init];
        _field.backgroundColor = [UIColor grayColor];
    }
    return _field;
}

- (UITextView *)offset {
    if (_offset == nil) {
        _offset = [[UITextView alloc] init];
        _offset.text = @"Offset:";
        _offset.editable = NO;
    }
    return _offset;
}

- (StatFilterView *)filters {
    if (_filters == nil) {
        _filters = [[StatFilterView alloc] init];
        _filters.stats = [[self game] allStats];
        
        [_filters on:@"filtered-stats"
            callback:^(NSArray *stats) { [self updateStats]; }];
    }
    return _filters;
}

- (CourtView *)courtView {
    if (_courtView == nil) {
        _courtView = [[CourtView alloc] init];
    }
    return _courtView;
};

- (AnalysisLinesView *)linesView {
    if (_linesView == nil) {
        _linesView = [[AnalysisLinesView alloc] init];
        [_linesView on:@"selected-stat"
              callback:^(Stat *stat) {
                  // NSLog(@"%@", stat);
                  self.videoPlayer.hidden = NO;
                  [self.videoPlayer seekTo:stat];
              }];
    }
    return _linesView;
}

- (StatAnalysisVideoPlayer *)videoPlayer {
    if (_videoPlayer == nil) {
        _videoPlayer = [[StatAnalysisVideoPlayer alloc] init];
    }
    return _videoPlayer;
}

- (void)viewDidAppear:(BOOL)animated {
    self.statsTextView.text = [self basicStats];
}



- (NSString *)basicStats {
    
    
    NSUInteger kills = [Stat filterStats:self.filters.filteredStats
                             withFilters:@{
                                           @"skill" : @"Hit",
                                           @"details" : @{@"result" : @"kill"}
                                           }].count;
    
    NSUInteger hittingAttempts = [Stat filterStats:self.filters.filteredStats
                                       withFilters:@{@"skill" : @"Hit"}].count;
    
    NSUInteger hittingErrors =
    [Stat filterStats:self.filters.filteredStats
          withFilters:@{
                        @"skill" : @"Hit",
                        @"details" : @{@"result" : @"error"}
                        }].count;
    
    /// passing stat team 0
    
    NSArray *passingOptions = [NSArray
                               arrayWithObjects:@"4", @"3", @"2", @"1", @"0", @"ace", @"err", nil];
    NSString *currentPassingOption;
    NSMutableDictionary *passValue = [[NSMutableDictionary alloc] init];
    
    for (currentPassingOption in passingOptions) {
        //    NSLog(@"%@", currentPassingOption);
        
        NSUInteger pass =
        [Stat filterStats:self.filters.filteredStats
              withFilters:@{
                            @"skill" : @"Serve",
                            @"details" : @{@"result" : currentPassingOption}
                            }].count;
        
        passValue[currentPassingOption] = [NSNumber numberWithUnsignedInt:pass];
        NSLog(@"pass value:%@%@",currentPassingOption,passValue);
    }
    NSUInteger passingAttempts = [Stat filterStats:self.filters.filteredStats
                                       withFilters:@{@"skill" : @"Serve"}].count;
    
    NSNumber *passStat = [NSNumber numberWithDouble:(
                                                     ([passValue[@"1"] integerValue] *1 +
                                                      [passValue[@"2"] integerValue] *2 +
                                                      [passValue[@"3"] integerValue] *3 +
                                                      [passValue[@"4"] integerValue] *4 +
                                                      [passValue[@"err"] integerValue] *4
                                                      )/(float)(passingAttempts))];
    
    
    NSLog(@"passingattempts: %lu\n%lu", (unsigned long)passingAttempts,
          (unsigned long)passValue[passingOptions[1]]);
    
    
    NSNumber *hitPercent = [NSNumber numberWithDouble:((float)kills - hittingErrors) / hittingAttempts];
    
    return [NSString
            stringWithFormat:@"STATS\n\n##Hitting##\n    K    |    E    |    A    | Kill Per | Hit Per |\n    %lu    |    %lu    |    %lu    | %.02@ | %.02@ |\n",
            (unsigned long)kills, (unsigned long)hittingErrors,
            (unsigned long)hittingAttempts,
            hitPercent,
            passStat];
    
}

- (void)updateStats {
    self.linesView.stats = self.filters.filteredStats;
    self.statsTextView.text = [self basicStats];
    self.videoPlayer.playlist = self.filters.filteredStats;
}

@end