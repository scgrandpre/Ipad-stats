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


@class Game;
@implementation StatAnalyzer

-(id)initWithGame:(Game*) game {
    self=[super init];
    //do stuff
    //look at other init with games
    //property declared
    
    self.details = details;
    self.skill = skill;
    self.id = id;
    return self;
}

+ (Stat*) fromDict: (NSDictionary*) dict {
    return [[Stat alloc] initWithSkill:dict[@"skill"]
                               details:dict[@"details"]
                                    id:dict[@"id"]];
}
    return self;
    
    
}
@end
