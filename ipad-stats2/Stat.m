//
//  Stat.m
//  ipad-stats2
//
//  Created by Jim Grandpre on 4/30/13.
//  Copyright (c) 2013 RIPP Volleyball. All rights reserved.
//

#import "Stat.h"

@implementation Stat

- (id)initWithSkill:(NSString*)skill details:(NSMutableDictionary*)details team:(NSString*)team player:(NSString*)player id:(NSString*)id {
    self = [super init];
    self.details = details;
    self.skill = skill;
    self.player = player;
    self.timestamp = [NSDate date];
    self.team = team;
    self.id = id;
    return self;
}

+ (Stat*) fromDict:(NSDictionary*) dict {
    if (dict[@"details"][@"line"]) {
        NSMutableDictionary *mdict = [dict mutableCopy];
        dict = mdict;
        NSMutableArray *line = [[NSMutableArray alloc] init];
        for (NSString *point in dict[@"details"][@"line"]) {
            CGPoint p = CGPointFromString(point);
            [line addObject:[NSValue valueWithCGPoint:p]];
        }
        mdict[@"details"] = [mdict[@"details"] mutableCopy];
        mdict[@"details"][@"line"] = line;
        
    }

    Stat* stat = [[Stat alloc] initWithSkill:dict[@"skill"]
                               details:dict[@"details"]
                                team:dict[@"team"]
                                player:dict[@"player"]
                                    id:dict[@"id"]];
    stat.timestamp = [NSDate dateWithTimeIntervalSince1970:[dict[@"timestamp"] doubleValue]];
    return stat;
    
}

- (NSDictionary*) asDict {
    NSMutableDictionary *details = [self.details mutableCopy];
    if (details[@"line"]) {
        NSMutableArray *line = [[NSMutableArray alloc] init];
        for (NSValue *point in details[@"line"]) {
            CGPoint p = [point CGPointValue];
            [line addObject:NSStringFromCGPoint(p)];
        }
        details[@"line"] = line;
    }
    NSMutableDictionary* dict = [[NSMutableDictionary alloc] initWithDictionary: @{
                                 @"skill": self.skill,
                                 @"details": details,
                                 @"team": self.team,
                                 @"player": self.player,
                                 @"timestamp": [NSNumber numberWithDouble:[self.timestamp timeIntervalSince1970]]
                                 }];
    
    if(self.id) {
        dict[@"id"] = self.id;
    }
    return dict;
}

- (void) uploadsCompleted: (void (^)()) completion {
    completion();
}

-(BOOL) matchesFilter:(NSDictionary*)filter {
    NSString* filter_skill = filter[@"skill"];
    if (([filter_skill isEqual:@"Hit"]) || ([filter_skill isEqual:@"Serve"])){
        if(filter_skill != nil && [filter_skill compare:self.skill] != NSOrderedSame) return NO;
    }else if ([filter_skill isEqual:@"Pass"]){
        if(filter_skill != nil && [_skill compare:@"Serve"] != NSOrderedSame) return NO;
    }else if ([filter_skill isEqual:@"Dig"] || [filter_skill isEqual:@"Cover"] || [filter_skill isEqual:@"Block"]){
        if(filter_skill != nil && [_skill compare:@"Hit"] != NSOrderedSame) return NO;
    }
    
    NSString* filter_team = filter[@"team"];
    if(filter_team != nil && [filter_team compare:self.team] != NSOrderedSame) return NO;
    
    NSString* filter_player = filter[@"player"];
    if ([filter_skill isEqual:@"Hit"]){
        if(filter_player != nil && [filter_player compare:self.player] != NSOrderedSame) return NO;
    }else if ([filter_skill isEqual:@"Serve"]){
        if(filter_player != nil && [filter_player compare:self.player] != NSOrderedSame) return NO;
    }else if ([filter_skill isEqual:@"Pass"]){
        if(filter_player != nil && [filter_player compare:[self details][@"Passed By"]] != NSOrderedSame) return NO;
    }else if ([filter_skill isEqual:@"Dig"]){
        if(filter_player != nil && [filter_player compare:[self details][@"Dug By"]] != NSOrderedSame) return NO;
    }else if ([filter_skill isEqual:@"Cover"]){
        if(filter_player != nil && [filter_player compare:[self details][@"Covered By"]] != NSOrderedSame) return NO;
    }else if ([filter_skill isEqual:@"Block"]){
        if(filter_player != nil && [filter_player compare:[self details][@"Blocked By"]] != NSOrderedSame) return NO;
    }
    NSString* filter_game = filter[@"game"];
    if(filter_game != nil && [filter_game compare:self.details[@"game"]] != NSOrderedSame) return NO;
    
    if(filter[@"details"] != nil) {
        for(NSString* detail in [filter[@"details"] allKeys]) {
            NSString* filter_detail = filter[@"details"][detail];
            if([filter_detail compare:self.details[detail]] != NSOrderedSame) return NO;
        }
    }
    return YES;
}

+ (NSArray *)filterStats:(NSArray*)stats withFilters:(NSDictionary*)filter {
    NSMutableArray *filtered = [[NSMutableArray alloc] init];
    for(Stat *stat in stats) {
       if([stat matchesFilter:filter]) {
            [filtered addObject: stat];
        }
    }
    return filtered;
}

+ (NSArray *)filterMultipleStats:(NSArray*)stats withFilters:(NSArray*)filterArray {
    NSMutableArray *filtered = [[NSMutableArray alloc] init];
    NSDictionary*currentFilter;
    for (currentFilter in filterArray){
    for(Stat *stat in stats) {
        if([stat matchesFilter:currentFilter]) {
            [filtered addObject: stat];
        }
    }
    }
    return filtered;
}

+ (Stat*)stub {
    return [[Stat alloc] initWithSkill:@"HIT"
                               details:@{@"BLOCKERS":@"3", @"HANDS":@"HANDS", @"RESULT":@"KILL"}
                                  team:@"SHU"
                                player:@"nobody"
                                    id:nil];
}


@end
