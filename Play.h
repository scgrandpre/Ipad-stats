//
//  Play.h
//  ipad-stats2
//
//  Created by Jim Grandpre on 4/30/13.
//  Copyright (c) 2013 RIPP Volleyball. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Serializable.h"

@interface Play : NSObject <Serializable>

@property (strong) NSArray *stats;
@property (strong) NSString *winner;
@property (strong) NSString *id;
@property (strong) NSDictionary *rotation;
@property (strong) NSString *gameID;
    
- initWithStats:(NSArray*)stats winner:(NSString*)winner rotation:(NSDictionary*)rotation gameID:(NSString*)gameID id:(NSString*)id;
@end
