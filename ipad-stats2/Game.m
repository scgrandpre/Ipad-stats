//
//  Game.m
//  ipad-plays2
//
//  Created by Jim Grandpre on 4/30/13.
//  Copyright (c) 2013 RIPP Volleyball. All rights reserved.
//

#import "Game.h"
#import "Serializable.h"
#import "Play.h"
#import "CommonUtil.h"
#import "Stat.h"

@implementation Game

- (id)init {
    return [self initWithPlays:[[NSMutableArray alloc] init] date:[NSDate date] id:nil];
}

- (id)initWithPlays:(NSMutableArray*)plays date:(NSDate*)date id:(NSString*)id {
    self = [super init];
    self.plays = plays;
    self.date = date;
    self.id = id;
    return self;
}

- (void)addPlay:(Play*)play {
    play.gameID = self.id;
    [self.plays addObject:play];
    [[SerializableManager manager] SaveSerializable:play withCallback:^(NSObject<Serializable> *object) {
        NSLog(@"SAVED A PLAY");
    }];
}

+ (Game*) fromDict: (NSDictionary*) dict {
    NSDate *date = [[SerializableManager manager] DeserializeNSDate:dict[@"date"]];
    NSMutableArray *plays = map(dict[@"plays"], ^(NSDictionary* play){
        return [Play fromDict:play];
    });
    
    return [[Game alloc] initWithPlays:plays
                                  date:date
                                    id:dict[@"id"]];
}

- (NSDictionary*) asDict {
    NSArray *plays = map([self plays], ^(Play* play){ return [play asDict];});
    NSMutableDictionary* dict = [[NSMutableDictionary alloc] initWithDictionary: @{
                                 @"date": [[SerializableManager manager] SerializeNSDate:self.date],
                                 @"plays": plays
                                 }];
    if(self.id) {
        dict[@"id"] = self.id;
    }
    return dict;
}

- (void) uploadsCompleted: (void (^)()) completion {
    completion();
}

+ (Game*)stub {
    return [[Game alloc] init];
}

//from stats


-(void)forEachEvent:(void (^)(Stat*))each {
    for(Play* play in self.plays) {
        for(Stat* stat in play.stats) {
            each(stat);
        }
    }
}

-(BOOL)stat:(Stat*)stat matchesFilter:(NSDictionary*)filter {
    NSString* filter_skill = filter[@"skill"];
    if(filter_skill != nil && [filter_skill compare:stat.skill] != NSOrderedSame) return NO;
    
    if(filter[@"details"] != nil) {
        for(NSString* detail in [filter[@"details"] allKeys]) {
            NSString* filter_detail = filter[@"details"][detail];
            if([filter_detail compare:stat.details[detail]] != NSOrderedSame) return NO;
        }
    }
    return YES;
}


-(NSArray*)filterEventsBy:(NSDictionary*) filter {
    NSMutableArray *filtered = [[NSMutableArray alloc] init];
    [self forEachEvent:^(Stat* stat){
        if([self stat:stat matchesFilter:filter]) {
            [filtered addObject: stat];
        }
    }];
    return filtered;
}




@end
