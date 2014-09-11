//
//  Stat.h
//  ipad-stats2
//
//  Created by Jim Grandpre on 4/30/13.
//  Copyright (c) 2013 RIPP Volleyball. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Serializable.h"

@interface Stat : NSObject <Serializable>

@property (strong) NSString* id;
@property (strong) NSString* team;
@property (strong) NSString* skill;
@property (strong) NSString* player;
@property (strong) NSMutableDictionary* details;
@property NSDate* timestamp;


- (id)initWithSkill:(NSString*)skill details:(NSDictionary*)details team:(NSString*)team player:(NSString*)player id:(NSString*)id;

+ (Stat*)stub;
+ (NSArray *)filterStats:(NSArray*)stats withFilters:(NSDictionary*)filters;
+ (NSArray *)filterMultipleStats:(NSArray*)stats withFilters:(NSArray*)filterArray;

@end
