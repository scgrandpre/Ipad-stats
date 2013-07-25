//
//  Stat.m
//  ipad-stats2
//
//  Created by Jim Grandpre on 4/30/13.
//  Copyright (c) 2013 RIPP Volleyball. All rights reserved.
//

#import "Stat.h"

@implementation Stat

- (id)initWithSkill:(NSString*)skill details:(NSMutableDictionary*)details id:(NSString*)id {
    self = [super init];
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

- (NSDictionary*) asDict {
    NSMutableDictionary* dict = [[NSMutableDictionary alloc] initWithDictionary: @{
                                 @"skill": self.skill,
                                 @"details": self.details
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
                                    id:nil];
}


@end
