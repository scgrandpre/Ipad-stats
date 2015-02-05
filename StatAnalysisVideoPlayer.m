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
#import "Game.h"


@interface StatAnalysisVideoPlayer ()
@property(readonly) AVPlayerView *videoPlayer;
@property(readonly) AVPlayer *video;
@property(readonly) UIButton *previous;
@property(readonly) UIButton *replay;
@property(readonly) UIButton *next;
@property(readonly) UIButton *done;
@property(readonly) UIButton *sync;
@property(readonly) UIButton *syncPlus;
@property(readonly) UIButton *syncMinus;
@property(readonly) UIButton *editUrl;
@property(readonly) UISlider *seek;
@property float     offset;
@property NSInteger index;
@property NSString *videoUrlString;
@property(readonly) UITextField *videoUrlNew;

@end

@implementation StatAnalysisVideoPlayer
@synthesize videoPlayer = _videoPlayer;
@synthesize video = _video;
@synthesize previous = _previous;
@synthesize replay = _replay;
@synthesize next = _next;
@synthesize done = _done;
@synthesize sync = _sync;
@synthesize syncPlus = _syncPlus;
@synthesize syncMinus = _syncMinus;
@synthesize editUrl = _editUrl;
@synthesize index = _index;
@synthesize seek = _seek;
@synthesize videoUrlString = _videoUrlString;
@synthesize videoUrlNew = _videoUrlNew;

- (id)initWithFrame:(CGRect)frame {
  self = [super initWithFrame:frame];
  if (self) {
    
    [self addSubview:self.videoPlayer];
    [self addSubview:self.previous];
    [self addSubview:self.next];
    [self addSubview:self.replay];
    [self addSubview:self.done];
    [self addSubview:self.sync];
    [self addSubview:self.syncPlus];
    [self addSubview:self.syncMinus];
    [self addSubview:self.seek];
    [self addSubview:self.editUrl];
    [self addSubview:self.videoUrlNew];
      _offset = -1000000000000;
    self.backgroundColor = [UIColor blackColor];
    self.videoUrlNew.hidden = YES;
      
      
      
  }
  return self;
}

-(id)initWithURL:(NSString*) videoUrlString{
    _videoUrlString = videoUrlString;
    self = [super init];
    if (self){
        _videoUrlString = videoUrlString;
    }
    return self;
}

- (void)layoutSubviews {
  CGRect buttonsRect, videoRect, seekRect;
  CGFloat buttonHeight = 50;
  CGRectDivide(self.bounds, &buttonsRect, &videoRect, buttonHeight,
               CGRectMaxYEdge);
  CGRectDivide(videoRect, &seekRect, &videoRect, 20,
               CGRectMaxYEdge);
  self.videoPlayer.frame = videoRect;

  CGFloat buttonWidth = buttonsRect.size.width / 7;

  self.previous.frame = CGRectMake(buttonsRect.origin.x, buttonsRect.origin.y,
                                   buttonWidth, buttonHeight);
  self.replay.frame =
      CGRectMake(buttonsRect.origin.x + 1 * buttonWidth, buttonsRect.origin.y,
                 buttonWidth, buttonHeight);
  self.next.frame = CGRectMake(buttonsRect.origin.x + 2 * buttonWidth,
                               buttonsRect.origin.y, buttonWidth, buttonHeight);
  self.done.frame = CGRectMake(buttonsRect.origin.x + 6 * buttonWidth,
                               buttonsRect.origin.y, buttonWidth, buttonHeight);
  self.sync.frame = CGRectMake(buttonsRect.origin.x + 4 * buttonWidth,
                               buttonsRect.origin.y, buttonWidth, buttonHeight);
    self.syncPlus.frame = CGRectMake(buttonsRect.origin.x + 3 * buttonWidth,
                                 buttonsRect.origin.y, buttonWidth/2, buttonHeight);
    self.syncMinus.frame = CGRectMake(buttonsRect.origin.x + 3.5 * buttonWidth,
                                 buttonsRect.origin.y, buttonWidth/2, buttonHeight);
    self.editUrl.frame = CGRectMake(buttonsRect.origin.x + 5 * buttonWidth,
                                      buttonsRect.origin.y, buttonWidth, buttonHeight);
    self.videoUrlNew.frame = CGRectMake(buttonsRect.origin.x + 5 * buttonWidth,
                                    buttonsRect.origin.y, buttonWidth*2, buttonHeight);

  self.seek.frame = seekRect;
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
- (UIButton *)syncPlus {
    if (_syncPlus == nil) {
        _syncPlus = [UIButton buttonWithType:UIButtonTypeCustom];
        [_syncPlus setTitle:@"+2" forState:UIControlStateNormal];
        [_syncPlus addTarget:self
                  action:@selector(doSyncPlus)
        forControlEvents:UIControlEventTouchUpInside];
    }
    return _syncPlus;
}
- (UIButton *)syncMinus {
    if (_syncMinus == nil) {
        _syncMinus = [UIButton buttonWithType:UIButtonTypeCustom];
        [_syncMinus setTitle:@"-2" forState:UIControlStateNormal];
        [_syncMinus addTarget:self
                  action:@selector(doSyncMinus)
        forControlEvents:UIControlEventTouchUpInside];
    }
    return _syncMinus;
}
- (UIButton *)editUrl {
    if (_editUrl == nil) {
        _editUrl = [UIButton buttonWithType:UIButtonTypeCustom];
        [_editUrl setTitle:@"URL" forState:UIControlStateNormal];
        [_editUrl addTarget:self
                       action:@selector(doEditUrl)
             forControlEvents:UIControlEventTouchUpInside];
    }
    return _editUrl;
}

- (UITextField *)videoUrlNew  {
    if (_videoUrlNew == nil) {
        _videoUrlNew = [[UITextField alloc] init];
        _videoUrlNew.backgroundColor = [UIColor grayColor];
        _videoUrlNew.hidden = YES;
        _videoUrlNew.placeholder = @"Enter New Url";
        _videoUrlNew.returnKeyType = UIReturnKeyDone;
        _videoUrlNew.delegate = self;

    }
    return _videoUrlNew;
}


- (UISlider *)seek {
    if (_seek == nil) {
        _seek = [[UISlider alloc] init];
        _seek.minimumValue = 0;
        _seek.maximumValue = 1;
        _seek.continuous = NO;
        [_seek addTarget:self action:@selector(seekSliderChanged) forControlEvents:UIControlEventValueChanged];
    }
    return _seek;
}

- (void)seekTo:(Stat *)stat {
    self.index = 0;
    for (NSInteger i = 0; i < self.playlist.count; i++) {
        if (self.playlist[i] == stat) {
            self.index = i;
        }
    }
  CGFloat seconds = MAX(0, [self secondsForStat:stat]);
  [self.video seekToTime:CMTimeMake(seconds, 1) toleranceBefore:CMTimeMake(0,1) toleranceAfter: CMTimeMake(0,1)];
  [self.video play];
}

- (CGFloat)secondsForStat:(Stat *)stat {
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd"];
    NSString* offsetDate=@"2014-01-01";
    NSDate *mydate = [dateFormat dateFromString:offsetDate];
  return [stat.timestamp timeIntervalSinceDate:mydate] + self.offset;
}

- (void)seekToNext {
  self.index += 1;
  if (self.index >= [self.playlist count]) {
    self.index = 0;
  }
  [self seekToStatAtIndex:self.index];
}

- (void)seekToPrevious {
  self.index  -= 1;
  if (self.index < 0) {
    self.index = [self.playlist count] - 1;
  }
  [self seekToStatAtIndex:self.index];
}

- (void)seekToReplay {
  [self seekToStatAtIndex:self.index];
}

- (void)seekToStatAtIndex:(int)index {
  if ([self.playlist count] <= index) {
    return;
  }
  Stat *stat = self.playlist[index];
  [self seekTo:stat];
}

- (AVPlayerView *)videoPlayer  {
    
  if (_videoPlayer == nil) {
    _video = [[AVPlayer alloc]
        initWithURL:[NSURL URLWithString:_videoUrlString]];
    _videoPlayer = [[AVPlayerView alloc] init];
    _videoPlayer.player = _video;
      
    __weak StatAnalysisVideoPlayer *weakSelf = self;
    [_video addPeriodicTimeObserverForInterval:CMTimeMake(5,1) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
          weakSelf.seek.value = CMTimeGetSeconds(time)/CMTimeGetSeconds(weakSelf.video.currentItem.asset.duration);
    }];
  }
  return _videoPlayer;
}

- (void)close {
  [self.videoPlayer pause];
  self.hidden = YES;
}

- (void)doSync {
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd"];
    NSString* offsetDate=@"2014-01-01";
    NSDate *mydate = [dateFormat dateFromString:offsetDate];
  self.offset =
    CMTimeGetSeconds(self.video.currentTime) -
      [((Stat *)self.playlist[0]).timestamp timeIntervalSinceDate:mydate];
    
}

- (void)doSyncPlus {
    
    self.offset = self.offset+2;
    
    NSLog(@"+2");
}

- (void)doSyncMinus {
    self.offset = self.offset-2;
    NSLog(@"-2%f",self.offset);
    
}

//- (void)makeNewGame:(UIButton *)sender {
//    
//    self.awayTeam.hidden = NO;
//    self.homeTeam.hidden = NO;
//    self.videoUrl.hidden = NO;

- (void)doEditUrl {
    self.videoUrlNew.hidden = NO;
}



- (void)seekSliderChanged {
    CMTime time = CMTimeMultiplyByFloat64(self.video.currentItem.asset.duration, self.seek.value);
    [self.videoPlayer seekToTime:time];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    NSLog(@"hi Mom!");
    self.videoUrlNew.hidden = YES;
    [self.videoPlayer pause];
    self.hidden = YES;
    NSString* acsString = @"http://acsvolleyball.com/videos/";
    NSString* dotMPfour = @".mp4";
    NSString *videoUrlNewText = _videoUrlNew.text;
    NSString* videoUrlString = [NSString stringWithFormat:@"%@%@%@",acsString,videoUrlNewText,dotMPfour];
    
    //  acsvolleyball.com/%@.com,videoURL
    //http://acsvolleyball.com/videos/shu_liu_a_smaller.mp4
    _videoPlayer = nil;
    _videoPlayer = [[StatAnalysisVideoPlayer alloc] initWithURL:videoUrlString];
    
//
//        // create game
//        Game *game = [[Game alloc] init];
//        game.awayTeam = self.awayTeam.text;
//        game.homeTeam = self.homeTeam.text;
//        game.videoUrl = self.videoUrl.text;
//        SerializableManager *manager = [SerializableManager manager];
//        [manager SaveSerializable:game
//                     withCallback:^(NSObject<Serializable> *object) {}];
//        
//        AppDelegate *delegate =
//        (AppDelegate *)[UIApplication sharedApplication].delegate;
//        [delegate openGame:game];
    
    return NO;
}

@end
