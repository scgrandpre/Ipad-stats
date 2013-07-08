//
//  Play.m
//  ipad-stats2
//
//  Created by Jim Grandpre on 4/30/13.
//  Copyright (c) 2013 RIPP Volleyball. All rights reserved.
//

#import "Play.h"
#import "Stat.h"
#import "CommonUtil.h"

@implementation Play

- init {
    return [self initWithStats:[[NSMutableArray alloc] init] winner:nil rotation:nil gameID:nil id:nil];
}

- initWithStats:(NSMutableArray*)stats winner:(NSString*)winner rotation:(NSDictionary*)rotation gameID:(NSString*)gameID id:(NSString*)id {
    self = [super init];
    self.stats = stats;
    self.winner = winner;
    self.id = id;
    self.rotation = rotation;
    self.gameID = gameID;
    return self;
}

+ (Play*) fromDict: (NSDictionary*) dict {
    NSMutableArray *stats = map(dict[@"stats"], ^(NSDictionary* stat){
        return [Stat fromDict:stat];
    });
    
    return [[Play alloc] initWithStats:stats
                                winner:dict[@"winner"]
                              rotation:dict[@"rotation"]
                                gameID:dict[@"game"]
                                    id:dict[@"id"]];
}

- (NSDictionary*) asDict {
    NSArray *stats = map([self stats], ^(Stat* stat){ return [stat asDict];});
    NSMutableDictionary* dict = [[NSMutableDictionary alloc] initWithDictionary: @{
             @"stats": stats,
             @"winner":self.winner,
             @"rotation":self.rotation,
             @"game":self.gameID
                                 }];
    if(self.id) {
        dict[@"id"] = self.id;
    }
    return dict;
}

- (void) uploadsCompleted: (void (^)()) completion {
    completion();
}

+ (Play*)stub {
    return [[Play alloc] initWithStats:[[NSMutableArray alloc] initWithArray:@[[Stat stub]]] winner:@"0" rotation:@{@"0":@0, @"1":@1} gameID:@"0" id:nil];
}

@end
