//
//  StatAnalysisVideoPlayer.m
//  ipad-stats2
//
//  Created by James Grandpre on 6/13/14.
//  Copyright (c) 2014 RIPP Volleyball. All rights reserved.
//

#import "StatAnalysisVideoPlayer.h"

#import <AVFoundation/AVFoundation.h>
#import "AVPlayerView.h"

@interface StatAnalysisVideoPlayer ()
@property(readonly) AVPlayer *video;
@property(readonly) AVPlayerView *videoPlayer;
@property(readonly) UIButton *previous;
@property(readonly) UIButton *replay;
@property(readonly) UIButton *next;
@property(readonly) UIButton *done;
@end

@implementation StatAnalysisVideoPlayer
@synthesize video = _video;
@synthesize videoPlayer = _videoPlayer;
@synthesize previous = _previous;
@synthesize replay = _replay;
@synthesize next = _next;
@synthesize done = _done;

- (id)initWithFrame:(CGRect)frame {
  self = [super initWithFrame:frame];
  if (self) {
    [self addSubview:self.videoPlayer];
    [self addSubview:self.previous];
    [self addSubview:self.next];
    [self addSubview:self.replay];
    [self addSubview:self.done];
  }
  return self;
}

- (void)layoutSubviews {
  self.videoPlayer.frame = self.bounds;

  CGFloat buttonHeight = 50;
  CGRect buttonsRect = CGRectMake(self.bounds.origin.x,
                                  CGRectGetMaxY(self.bounds) - buttonHeight,
                                  self.bounds.size.width, buttonHeight);
  CGFloat buttonWidth = buttonsRect.size.width / 5;

  self.previous.frame = CGRectMake(buttonsRect.origin.x, buttonsRect.origin.y,
                                   buttonWidth, buttonHeight);
  self.replay.frame =
      CGRectMake(buttonsRect.origin.x + 1 * buttonWidth, buttonsRect.origin.y,
                 buttonWidth, buttonHeight);
  self.next.frame = CGRectMake(buttonsRect.origin.x + 2 * buttonWidth,
                               buttonsRect.origin.y, buttonWidth, buttonHeight);
  self.done.frame = CGRectMake(buttonsRect.origin.x + 4 * buttonWidth,
                               buttonsRect.origin.y, buttonWidth, buttonHeight);
}

- (UIButton *)previous {
  if (_previous == nil) {
    _previous = [UIButton buttonWithType:UIButtonTypeCustom];
    [_previous setTitle:@"Previous" forState:UIControlStateNormal];
  }
  return _previous;
}

- (UIButton *)next {
  if (_next == nil) {
    _next = [UIButton buttonWithType:UIButtonTypeCustom];
    [_next setTitle:@"Next" forState:UIControlStateNormal];
  }
  return _next;
}

- (UIButton *)replay {
  if (_replay == nil) {
    _replay = [UIButton buttonWithType:UIButtonTypeCustom];
    [_replay setTitle:@"Replay" forState:UIControlStateNormal];
  }
  return _replay;
}

- (UIButton *)done {
  if (_done == nil) {
    _done = [UIButton buttonWithType:UIButtonTypeCustom];
    [_done setTitle:@"Done" forState:UIControlStateNormal];
    [_done addTarget:self
                  action:@selector(close)
        forControlEvents:UIControlEventTouchUpInside];
  }
  return _done;
}

- (void)seekTo:(Stat *)stat {
  CGFloat seconds = [self secondsForStat:stat];
  [self.videoPlayer seekToTime:CMTimeMakeWithSeconds(seconds, 1)];
  [self.videoPlayer play];
}

- (CGFloat)secondsForStat:(Stat *)stat {
  return [stat.timestamp timeIntervalSinceReferenceDate] - self.offset;
}

- (NSInteger)statIndexForTime:(CGFloat)seconds {
  for (int i = 0; i < [self.playlist count]; i++) {
    if ([self secondsForStat:self.playlist[i]] > seconds) {
      return i;
    }
  }
  return -1;
}

- (NSInteger)currentStatIndex {
  return [self statIndexForTime:CMTimeGetSeconds(self.video.currentTime)];
}

- (void)seekToNext {
  NSInteger index = [self currentStatIndex] + 1;
  if (index >= [self.playlist count]) {
    index = 0;
  }
  [self seekToStatAtIndex:index];
}

- (void)seekToStatAtIndex:(int)index {
  if ([self.playlist count] <= index) {
    return;
  }
  Stat *stat = self.playlist[index];
  [self seekTo:stat];
}

- (AVPlayerView *)videoPlayer {
  if (_videoPlayer == nil) {
    _video = [[AVPlayer alloc]
        initWithURL:[NSURL
                        URLWithString:
                            @"http://acsvolleyball.com/videos/shu_liu_a.mp4"]];
    _video.muted = YES;
    _videoPlayer = [[AVPlayerView alloc] init];
    _videoPlayer.backgroundColor =
        [UIColor colorWithRed:0 green:0 blue:0 alpha:.8];
    [_videoPlayer setPlayer:_video];
  }
  return _videoPlayer;
}

- (void)close {
  [self.videoPlayer pause];
  self.hidden = YES;
}

@end
