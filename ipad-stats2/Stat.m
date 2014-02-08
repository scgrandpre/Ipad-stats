//
//  Stat.m
//  ipad-stats2
//
//  Created by Jim Grandpre on 4/30/13.
//  Copyright (c) 2013 RIPP Volleyball. All rights reserved.
//

#import "Stat.h"

@implementation Stat

- (id)initWithSkill:(NSString*)skill details:(NSMutableDictionary*)details player:(NSString*)player id:(NSString*)id {
    self = [super init];
    self.details = details;
    self.skill = skill;
    self.player = player;
    self.timestamp = [NSDate date];
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

+ (Stat*)stub {
    return [[Stat alloc] initWithSkill:@"HIT"
                               details:@{@"BLOCKERS":@"3", @"HANDS":@"HANDS", @"RESULT":@"KILL"}
                                player:@"nobody"
                                    id:nil];
}


@end
