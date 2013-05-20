//
//  StatAnalyzer.m
//  ipad-stats2
//
//  Created by Scott Grandpre on 5/9/13.
//  Copyright (c) 2013 RIPP Volleyball. All rights reserved.
//

#import "StatAnalyzer.h"
#import "Game.h"
#import "Play.h"
#import "Stat.h"

@interface StatAnalyzer ()
@property Game* game;
@end

@implementation StatAnalyzer

-(id)initWithGame:(Game*) game {
    self=[super init];
    //do stuff
    //look at other init with games
    //property declared
    
    
    self.game = game;
    NSLog(@"%@",self.game);
    NSLog(@"above is what a game looks like");

    return self;
}
    
@end
