//
//  StatAnalysisViewController.m
//  ipad-stats2
//
//  Created by Jim Grandpre on 4/25/13.
//  Copyright (c) 2013 RIPP Volleyball. All rights reserved.
//

#import "StatAnalysisViewController.h"
#import "Game.h"
#import "Play.h"
#import "Stat.h"

@interface StatAnalysisViewController ()
@property UITextView *text;
@property Game *game;

@end

@implementation StatAnalysisViewController

-(id)initWithGame:(Game*) game {
    self = [super init];
    self.game = game;
    return self;
}

-(void)loadView {
    [super loadView];
    self.text = [[UITextView alloc] initWithFrame:self.view.bounds];
    self.text.editable = NO;
    [self.view addSubview: self.text];
    
}

-(void)viewDidAppear:(BOOL)animated {
    self.text.text = [self basicStats];
}

-(void)forEachEvent:(void (^)(Stat*))each {
    for(Play* play in self.game.plays) {
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

- (NSString*)basicStats {
    ///kills by team 0
    int kills = [self filterEventsBy:@{@"skill": @"HIT", @"details": @{@"RESULT":@"KILL"}}].count;
    int hittingAttempts = [self filterEventsBy:@{@"skill": @"HIT"}].count;
    int hittingErrors = [self filterEventsBy:@{@"skill": @"HIT", @"details": @{@"RESULT":@"ERROR"}}].count;
    return [NSString stringWithFormat:@"Attempts: %i\nKills: %i\nErrors: %i\nHitting Average: %f", hittingAttempts, kills, hittingErrors, ((float)kills - hittingErrors)/hittingAttempts];
}

@end
