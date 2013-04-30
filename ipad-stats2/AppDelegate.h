//
//  AppDelegate.h
//  ipad-stats2
//
//  Created by Jim Grandpre on 4/11/13.
//  Copyright (c) 2013 RIPP Volleyball. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SocketIO.h>

@class Game;

@interface AppDelegate : UIResponder <UIApplicationDelegate, SocketIODelegate>

@property (strong, nonatomic) UIWindow *window;

- (void)openGame:(Game*) game;

@end
