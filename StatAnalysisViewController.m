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
#import <EventEmitter/EventEmitter.h>
#import <MediaPlayer/MediaPlayer.h>

#import <AVFoundation/AVFoundation.h>
#import "AVPlayerView.h"

@interface StatAnalysisViewController ()
@property Game *game;

@property(readonly) UITextView *statsTextView;
@property(readonly) AnalysisLinesView *linesView;
@property(readonly) CourtView *courtView;
@property(readonly) AVPlayer *video;
@property(readonly) AVPlayerView *videoPlayer;
@property(readonly) UITextField *field;
@property(readonly) UITextView *offset;
@property(readonly) StatFilterView *filters;
@end

@implementation StatAnalysisViewController
@synthesize statsTextView = _statsTextView;
@synthesize linesView = _linesView;
@synthesize courtView = _courtView;
@synthesize video = _video;
@synthesize videoPlayer = _videoPlayer;
@synthesize field = _field;
@synthesize offset = _offset;
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
      CGRectMake(CGRectGetMaxX(self.filters.frame), self.view.bounds.origin.y,
                 self.view.bounds.size.width / 2,
                 self.view.bounds.size.height - courtHeight - 20);
}

- (UITextView *)statsTextView {
  if (_statsTextView == nil) {
    _statsTextView = [[UITextView alloc] init];
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
              NSLog(@"%@", stat);
              Stat *firstStat = [self.game.plays[0] stats][0];
              NSDate *firstStatTime = firstStat.timestamp;
              NSTimeInterval offset =
                  [stat.timestamp timeIntervalSinceDate:firstStatTime];
              int manualOffset = [self.field.text intValue];

              [self.videoPlayer
                  seekToTime:CMTimeMakeWithSeconds(offset + manualOffset, 1)];
              [self.videoPlayer play];
          }];
  }
  return _linesView;
}

- (AVPlayerView *)videoPlayer {
  if (_videoPlayer == nil) {
    _video = [[AVPlayer alloc]
        initWithURL:[NSURL
                        URLWithString:
                            @"http://acsvolleyball.com/videos/shu_liu_a.mp4"]];
    _videoPlayer = [[AVPlayerView alloc] init];
    _videoPlayer.backgroundColor =
        [UIColor colorWithRed:0 green:0 blue:0 alpha:.8];
    [_videoPlayer setPlayer:_video];
  }
  return _videoPlayer;
}

- (void)viewDidAppear:(BOOL)animated {
  self.statsTextView.text = [self basicStats];
}

- (NSString *)basicStats {
  NSUInteger kills = [Stat filterStats:self.filters.stats
                           withFilters:@{
                                         @"skill" : @"Hit",
                                         @"details" : @{@"result" : @"kill"}
                                       }].count;

  NSUInteger hittingAttempts =
      [self.game filterEventsBy:@{@"skill" : @"Hit"}].count;
  NSUInteger hittingErrors =
      [self.game filterEventsBy:@{
                                  @"skill" : @"Hit",
                                  @"details" : @{@"result" : @"error"}
                                }].count;

  /// passing stat team 0

  NSLog(@"here I am");
  NSUInteger passingAttempts =
      [self.game filterEventsBy:@{@"skill" : @"Serve"}].count;
  NSUInteger pass4 =
      [self.game filterEventsBy:@{
                                  @"skill" : @"Serve",
                                  @"details" : @{@"result" : @"4"}
                                }].count;
  NSUInteger pass3 =
      [self.game filterEventsBy:@{
                                  @"skill" : @"Serve",
                                  @"details" : @{@"result" : @"3"}
                                }].count;
  NSUInteger pass2 =
      [self.game filterEventsBy:@{
                                  @"skill" : @"Serve",
                                  @"details" : @{@"result" : @"2"}
                                }].count;
  NSUInteger pass1 =
      [self.game filterEventsBy:@{
                                  @"skill" : @"Serve",
                                  @"details" : @{@"result" : @"1"}
                                }].count;
  NSUInteger pass0 =
      [self.game filterEventsBy:@{
                                  @"skill" : @"Serve",
                                  @"details" : @{@"result" : @"0"}
                                }].count;
  NSUInteger passAce =
      [self.game filterEventsBy:@{
                                  @"skill" : @"Serve",
                                  @"details" : @{@"result" : @"ace"}
                                }].count;
  NSUInteger passStat = 0;
  if ((pass4 + pass3 + pass2 + pass1 + pass0 + passAce) > 0) {
    passStat = (pass4 * 4 + pass3 * 3 + pass2 * 2 + pass1 * 1) /
               (pass4 + pass3 + pass2 + pass1 + pass0 + passAce);
  }

  // NSUInteger countPasses = 0;
  // for (i in [self filterEventsBy:@{@"skill": @"SERVE"}]){
  //    countPasses += i

  //}
  // NSString *passStat = countPasses

  NSLog(@"%lu\n%lu", (unsigned long)passingAttempts, (unsigned long)pass4);

  return [NSString
      stringWithFormat:@"Attempts: %lu\nKills: %lu\nErrors: %lu\nHitting "
                       @"Average: %f\nPass Stat: %lu",
                       (unsigned long)hittingAttempts, (unsigned long)kills,
                       (unsigned long)hittingErrors,
                       ((float)kills - hittingErrors) / hittingAttempts,
                       (unsigned long)passStat];
}

- (void)updateStats {
  self.linesView.stats = self.filters.filteredStats;
  self.statsTextView.text = [self basicStats];
}

@end
