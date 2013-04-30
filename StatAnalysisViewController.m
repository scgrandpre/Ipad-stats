//
//  StatAnalysisViewController.m
//  ipad-stats2
//
//  Created by Jim Grandpre on 4/25/13.
//  Copyright (c) 2013 RIPP Volleyball. All rights reserved.
//

#import "StatAnalysisViewController.h"

@interface StatAnalysisViewController ()
@property UITextView *text;
@property NSMutableArray *stats;

@end

@implementation StatAnalysisViewController

-(id)initWithStats:(NSMutableArray*) stats {
    self = [super init];
    self.stats = stats;
    return self;
}

-(void)loadView {
    [super loadView];
    self.text = [[UITextView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview: self.text];
    
}

-(void)viewDidAppear:(BOOL)animated {
    self.text.text = [self basicStats];
}

-(void)forEachEvent:(void (^)(NSDictionary*))each {
    for(NSDictionary* play in self.stats) {
        for(NSDictionary* event in play[@"events"]) {
            each(event);
        }
    }
}

-(BOOL)event:(NSDictionary*)event matchesFilter:(NSDictionary*)filter {
    if(filter[@"skill"] != nil && filter[@"skill"] != event[@"skill"]) return NO;
    
    if(filter[@"details"] != nil) {
        for(NSString* detail in [filter[@"details"] allKeys]) {
            if(filter[@"details"][detail] != event[@"details"][detail]) return NO;
        }
    }
    return YES;
}

-(NSArray*)filterEventsBy:(NSDictionary*) filter {
    NSMutableArray *filtered = [[NSMutableArray alloc] init];
    [self forEachEvent:^(NSDictionary* event){
        if([self event:event matchesFilter:filter]) {
            [filtered addObject: event];
        }
    }];
    return filtered;
}

- (NSString*)basicStats {
    ///kills by team 0
    int kills = [self filterEventsBy:@{@"skill": @"HIT", @"details": @{@"RESULT":@"KILL"}}].count;
    int hittingAttempts = [self filterEventsBy:@{@"skill": @"HIT"}].count;
    int hittingErrors = [self filterEventsBy:@{@"skill": @"HIT", @"details": @{@"RESULT":@"ERROR"}}].count;
    return [NSString stringWithFormat:@"Attempts: %i\nKills: %i\nErrors: %i\nHitting %%:%f", hittingAttempts, kills, hittingErrors, ((float)kills - hittingErrors)/hittingAttempts];
}

@end
