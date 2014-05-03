//
//  AVPlayerView.h
//  ipad-stats2
//
//  Created by Scott Grandpre on 2/22/14.
//  Copyright (c) 2014 RIPP Volleyball. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface AVPlayerView : UIView

@property (nonatomic, retain) AVPlayer* player;

- (void)setPlayer:(AVPlayer*)player;
- (void)setVideoFillMode:(NSString *)fillMode;

- (void) play;

- (void) pause;
- (void) seekToTime:(CMTime)time;

@end
