//
//  StatAnalysisVideoPlayer.m
//  ipad-stats2
//
//  Created by James Grandpre on 6/13/14.
//  Copyright (c) 2014 RIPP Volleyball. All rights reserved.
//

#import "StatAnalysisVideoPlayer.h"

#import <MediaPlayer/MediaPlayer.h>

@interface StatAnalysisVideoPlayer ()
@property(readonly) MPMoviePlayerController *videoPlayer;
@property(readonly) UIButton *previous;
@property(readonly) UIButton *replay;
@property(readonly) UIButton *next;
@property(readonly) UIButton *done;
@property(readonly) UIButton *sync;
@property CGFloat offset;
@end

@implementation StatAnalysisVideoPlayer
@synthesize videoPlayer = _videoPlayer;
@synthesize previous = _previous;
@synthesize replay = _replay;
@synthesize next = _next;
@synthesize done = _done;
@synthesize sync = _sync;

- (id)initWithFrame:(CGRect)frame {
  self = [super initWithFrame:frame];
  if (self) {
    [self addSubview:self.videoPlayer.view];
    [self addSubview:self.previous];
    [self addSubview:self.next];
    [self addSubview:self.replay];
    [self addSubview:self.done];
    [self addSubview:self.sync];
    self.backgroundColor = [UIColor blackColor];
  }
  return self;
}

- (void)layoutSubviews {
  CGRect buttonsRect, videoRect;
  CGFloat buttonHeight = 50;
  CGRectDivide(self.bounds, &buttonsRect, &videoRect, buttonHeight,
               CGRectMaxYEdge);
  self.videoPlayer.view.frame = videoRect;

  CGFloat buttonWidth = buttonsRect.size.width / 6;

  self.previous.frame = CGRectMake(buttonsRect.origin.x, buttonsRect.origin.y,
                                   buttonWidth, buttonHeight);
  self.replay.frame =
      CGRectMake(buttonsRect.origin.x + 1 * buttonWidth, buttonsRect.origin.y,
                 buttonWidth, buttonHeight);
  self.next.frame = CGRectMake(buttonsRect.origin.x + 2 * buttonWidth,
                               buttonsRect.origin.y, buttonWidth, buttonHeight);
  self.done.frame = CGRectMake(buttonsRect.origin.x + 5 * buttonWidth,
                               buttonsRect.origin.y, buttonWidth, buttonHeight);
  self.sync.frame = CGRectMake(buttonsRect.origin.x + 4 * buttonWidth,
                               buttonsRect.origin.y, buttonWidth, buttonHeight);
}

- (UIButton *)previous {
  if (_previous == nil) {
    _previous = [UIButton buttonWithType:UIButtonTypeCustom];
    [_previous setTitle:@"Previous" forState:UIControlStateNormal];
    [_previous addTarget:self
                  action:@selector(seekToPrevious)
        forControlEvents:UIControlEventTouchUpInside];
  }
  return _previous;
}

- (UIButton *)next {
  if (_next == nil) {
    _next = [UIButton buttonWithType:UIButtonTypeCustom];
    [_next setTitle:@"Next" forState:UIControlStateNormal];
    [_next addTarget:self
                  action:@selector(seekToNext)
        forControlEvents:UIControlEventTouchUpInside];
  }
  return _next;
}

- (UIButton *)replay {
  if (_replay == nil) {
    _replay = [UIButton buttonWithType:UIButtonTypeCustom];
    [_replay setTitle:@"Replay" forState:UIControlStateNormal];
    [_replay addTarget:self
                  action:@selector(seekToReplay)
        forControlEvents:UIControlEventTouchUpInside];
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

- (UIButton *)sync {
  if (_sync == nil) {
    _sync = [UIButton buttonWithType:UIButtonTypeCustom];
    [_sync setTitle:@"Sync" forState:UIControlStateNormal];
    [_sync addTarget:self
                  action:@selector(doSync)
        forControlEvents:UIControlEventTouchUpInside];
  }
  return _sync;
}

- (void)seekTo:(Stat *)stat {
  CGFloat seconds = [self secondsForStat:stat];
  self.videoPlayer.currentPlaybackTime = seconds;
  [self.videoPlayer play];
}

- (CGFloat)secondsForStat:(Stat *)stat {
  return [stat.timestamp timeIntervalSinceReferenceDate] + self.offset;
}

- (NSInteger)statIndexForTime:(CGFloat)seconds {
  for (int i = 1; i < [self.playlist count]; i++) {
    if ([self secondsForStat:self.playlist[i]] > seconds) {
      return i - 1;
    }
  }
  return self.playlist.count - 1;
}

- (NSInteger)currentStatIndex {
  return [self statIndexForTime:self.videoPlayer.currentPlaybackTime];
}

- (void)seekToNext {
  NSInteger index = [self currentStatIndex] + 1;
  if (index >= [self.playlist count]) {
    index = 0;
  }
  [self seekToStatAtIndex:index];
}

- (void)seekToPrevious {
  NSInteger index = [self currentStatIndex] - 1;
  if (index < 0) {
    index = [self.playlist count] - 1;
  }
  [self seekToStatAtIndex:index];
}

- (void)seekToReplay {
  NSInteger index = [self currentStatIndex];
  [self seekToStatAtIndex:index];
}

- (void)seekToStatAtIndex:(int)index {
  if ([self.playlist count] <= index) {
    return;
  }
  Stat *stat = self.playlist[index];
  [self seekTo:stat];
}

- (MPMoviePlayerController *)videoPlayer {
  if (_videoPlayer == nil) {
    _videoPlayer = [[MPMoviePlayerController alloc]
        initWithContentURL:[NSURL URLWithString:@"http://acsvolleyball.com/"
                                  @"videos/shu_liu_a.mp4"]];
    [_videoPlayer prepareToPlay];
  }
  return _videoPlayer;
}

- (void)close {
  [self.videoPlayer pause];
  self.hidden = YES;
}

- (void)doSync {
  self.offset =
      self.videoPlayer.currentPlaybackTime -
      [((Stat *)self.playlist[0]).timestamp timeIntervalSinceReferenceDate];
}

@end
