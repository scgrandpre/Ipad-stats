//
//  AVPlayerView.m
//  ipad-stats2
//
//  Created by Scott Grandpre on 2/22/14.
//  Copyright (c) 2014 RIPP Volleyball. All rights reserved.
//

#import "AVPlayerView.h"
#import <AVFoundation/AVFoundation.h>

@implementation AVPlayerView

+ (Class)layerClass {
    return [AVPlayerLayer class];
}

- (AVPlayer*)player {
    return [(AVPlayerLayer*)[self layer] player];
}

- (void)setPlayer:(AVPlayer*)player {
    [(AVPlayerLayer*)[self layer] setPlayer:player];
}

/* Specifies how the video is displayed within a player layer’s bounds.
 (AVLayerVideoGravityResizeAspect is default) */
- (void)setVideoFillMode:(NSString *)fillMode {
    AVPlayerLayer *playerLayer = (AVPlayerLayer*)[self layer];
    playerLayer.videoGravity = fillMode;
}

- (void) play {
    [self.player play];
}

- (void) pause {
    [self.player pause];
}

- (void) seekToTime:(CMTime)time {
    [self.player seekToTime:time];
}

@end