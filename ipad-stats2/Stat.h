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
@property (strong) NSString* skill;
@property (strong) NSDictionary* details;

- (id)initWithSkill:(NSString*)skill details:(NSDictionary*)details id:(NSString*)id;

+ (Stat*)stub;
@end
