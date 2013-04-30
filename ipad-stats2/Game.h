//
//  Game.h
//  ipad-stats2
//
//  Created by Jim Grandpre on 4/30/13.
//  Copyright (c) 2013 RIPP Volleyball. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Serializable.h"

@class Play;

@interface Game : NSObject <Serializable>

@property (strong) NSDate* date;
@property (strong) NSString* id;
@property (strong) NSMutableArray* plays;

- (void)addPlay:(Play*)play;
+ (Game*)stub;
@end
