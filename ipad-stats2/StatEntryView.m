//
//  StatEntryView.m
//  ipad-stats2
//
//  Created by Scott Grandpre on 5/30/13.
//  Copyright (c) 2013 RIPP Volleyball. All rights reserved.
//

#import "StatEntryView.h"
#import "DrawingView.h"
#import "Stat.h"
#import "Play.h"
#import "CourtView.h"
#import <EventEmitter.h>
#import "StatEventButtonsView.h"
#import "Serializable.h"

static NSString *kSkillServe = @"Serve";
static NSString *kSkillPass  = @"Pass";
static NSString *kSkillDig   = @"Dig";
static NSString *kSkillHit   = @"Hit";



static NSString *PlayStatePrePlay  = @"pre-play";
static NSString *PlayStateServe    = @"serve";
static NSString *PlayStatePass     = @"pass";
static NSString *PlayStateOverPass = @"overpass";
static NSString *PlayStateOverPassHit = @"overpass-hit";
static NSString *PlayStateDig      = @"dig";
static NSString *PlayStateHit      = @"hit";





typedef enum CourtArea : NSUInteger {
    CourtAreaIn = 0,
    CourtAreaOutWide,
    CourtAreaServeZone
} CourtArea;

typedef enum CourtSide : NSUInteger {
    CourtSideLeft = 0,
    CourtSideRight
} CourtSide;


@interface StatEntryView ()
@property NSString* state;
@property CourtSide currentSide;
@property CourtSide servingTeam;
@property Play *play;
@property NSDictionary *stateMachine;
@property UILabel *stateLabel;
@property StatEventButtonsView* buttonsView;
@property NSDictionary *buttonsForState;
@property CourtView *courtView;
@end


@implementation StatEntryView
@synthesize state = _state;

- (NSString*) state {
    return _state;
}

- (void) setState:(NSString *)state {
    _state = state;
    self.stateLabel.text = state;
    self.buttonsView.buttonTitles = self.buttonsForState[state];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        CGFloat courtAspectRatio = 8/5.f;
        
        CGFloat height = self.bounds.size.height - 200;
        CGFloat width = self.bounds.size.width;
        
        if (height * courtAspectRatio > width) {
            height = width/courtAspectRatio;
        } else {
            width = height * courtAspectRatio;
        }
        
        _courtView = [[CourtView alloc] initWithFrame:CGRectMake(self.bounds.origin.x, self.bounds.origin.y + 200, width, height)];
        [self addSubview:_courtView];
        
        [_courtView on:@"drew-line" callback:^(NSDictionary* data){
            [self advanceStateForLine:data[@"line"] player:data[@"player"]];
            
        }];
        
        _stateLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,40,200, 50)];
        _stateLabel.text = _state;
        [self addSubview:_stateLabel];
        
        _buttonsView = [[StatEventButtonsView alloc] initWithFrame:CGRectMake(0, 150, self.bounds.size.width, 50)];
        [self addSubview:_buttonsView];
        _buttonsView.buttonTitles = @[@"FOO:", @"BAR", @"BAZ"];
        
        [_buttonsView on:@"button-pressed" callback:^(NSString* buttonName) {
            [self advanceStateForButton:buttonName];
        }];
        
        StatEventButtonsView *subsView = [[StatEventButtonsView alloc] initWithFrame:CGRectMake(0, 75, self.bounds.size.width, 50)];
        [self addSubview:subsView];
        subsView.buttonTitles = @[@"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", @"10", @"11", @"12", @"13", @"14", @"15", @"16", @"17", @"18"];
        
        [subsView on:@"button-pressed" callback:^(NSString* player) {
            [_courtView subPlayer: player];
        }];

        for(int team = 0; team < 2; team++) {
            StatEventButtonsView *rotationButtons = [[StatEventButtonsView alloc]
                                                     initWithFrame:CGRectMake(85 + 450*team, self.bounds.size.height - 55,
                                                                              100, 50)];
            [self addSubview:rotationButtons];
            rotationButtons.buttonTitles = @[@"<--", @"-->"];
            
            [rotationButtons on:@"button-pressed" callback:^(NSString* buttonName) {
                if ([buttonName isEqualToString:@"<--"]) {
                    [self.courtView unrotateTeam:team];
                } else {
                    [self.courtView rotateTeam:team];
                }
            }];
        }
        
        StatEventButtonsView *changeStateView = [[StatEventButtonsView alloc] initWithFrame:CGRectMake(350, 0, self.bounds.size.width, 50)];
        [self addSubview:changeStateView];
        changeStateView.buttonTitles = @[@"Hit Left",@"Hit Right"];
        
        [changeStateView on:@"button-pressed" callback:^(NSString* buttonName) {
            if ([buttonName isEqualToString:@"Hit Left"]) {
                self.state = PlayStateDig;
                self.currentSide = CourtSideLeft;
            }
            else {
                self.state = PlayStateDig;
                self.currentSide = CourtSideRight;
            }
        }];
        
        
        [self makeStateMachine];
        [self makeStateButtons];
        
        self.state = PlayStatePrePlay;
    }
    return self;
}

- (void) makeStateButtons {
    self.buttonsForState = @{
                             PlayStateServe: @[@"Ace", @"Serve Error"],
                             PlayStatePass: @[@"Ace",@"0",@"1",@"2",@"3",@"4",],
                             PlayStateDig: @[@"Dig Error"],
                             PlayStateHit: @[@"Hands", @"Kill", @"Hit Error"],
                             PlayStateOverPass: @[@"FB Error", @"Overpass Attacked"],
                             PlayStateOverPassHit: @[],
                             };
}

- (void) makeStateMachine {
    NSLog(@"%s%u","current side: ",self.currentSide);

    self.stateMachine = @{
        PlayStatePrePlay: ^(NSArray *line, NSString* player){
            self.play = [[Play alloc] init];
            self.play.rotation = @{};
            [self emit:@"play-added" data:self.play];

            Stat *stat = [[Stat alloc] initWithSkill:kSkillServe details:[[NSMutableDictionary alloc] init] player:player id:nil];
            [self.play.stats addObject:stat];
            
            [self emit:@"stat-added" data:stat];
            
            
            CourtSide startSide, endSide;
            CourtArea startArea, endArea;
            [self locationsForLine:line startSide:&startSide startArea:&startArea endSide:&endSide endArea:&endArea];
            
            if (startArea == CourtAreaServeZone) {
                self.currentSide = startSide;
                self.state = PlayStateServe;
                self.servingTeam = self.currentSide;
            } else {
                NSLog(@"why aren't you serving?");
            }
        },
        PlayStateServe: ^(NSArray *line, NSString* player){
            CourtSide startSide, endSide;
            CourtArea startArea, endArea;
            [self locationsForLine:line startSide:&startSide startArea:&startArea endSide:&endSide endArea:&endArea];
            
            self.currentSide = 1 - self.currentSide;
            
            if (endSide == self.currentSide) {
                self.state = PlayStatePass;
            } else {
                self.state = PlayStateOverPass;
            }
            
            Stat *stat = [[Stat alloc] initWithSkill:kSkillPass details:[[NSMutableDictionary alloc] init] player:player id:nil];
            [self.play.stats addObject:stat];
            [self emit:@"stat-added" data:stat];
        },
        PlayStatePass: ^(NSArray *line, NSString* player) {
            Stat *stat = [[Stat alloc] initWithSkill:kSkillHit details:[[NSMutableDictionary alloc] init] player:player id:nil];
            [self.play.stats addObject:stat];
            [stat.details setObject:@"no hands" forKey:@"hands"];
            [self emit:@"stat-added" data:stat];
            self.state = PlayStateHit;
        },
        PlayStateHit: ^(NSArray *line, NSString* player) {
            Stat *stat = [[Stat alloc] initWithSkill:kSkillDig details:[[NSMutableDictionary alloc] init] player:player id:nil];
            [self.play.stats addObject:stat];

            [self emit:@"stat-added" data:stat];
            
            CourtSide startSide, endSide;
            CourtArea startArea, endArea;
            [self locationsForLine:line startSide:&startSide startArea:&startArea endSide:&endSide endArea:&endArea];
            
            if (self.currentSide == startSide) {
                NSLog(@"Blocked!");
            } else {
                self.currentSide = 1 - self.currentSide;
            }
            
            if (self.currentSide == endSide) {
                self.state = PlayStateDig;
            } else {
                self.state = PlayStateOverPass;
            }
        },
        PlayStateOverPass: ^(NSArray *line, NSString* player) {
            Stat *stat = [[Stat alloc] initWithSkill:kSkillDig details:[[NSMutableDictionary alloc] init] player:player id:nil];
            [self.play.stats addObject:stat];
            [self emit:@"stat-added" data:stat];
            
            CourtSide startSide, endSide;
            CourtArea startArea, endArea;
            [self locationsForLine:line startSide:&startSide startArea:&startArea endSide:&endSide endArea:&endArea];
            
            self.currentSide = 1 - self.currentSide;
            if (self.currentSide == endSide) {
                self.state = PlayStateDig;
            } else {
                self.state = PlayStateOverPass;
            };
        },
        PlayStateOverPassHit: ^(NSArray *line, NSString* player) {
            Stat *stat = [[Stat alloc] initWithSkill:kSkillHit details:[[NSMutableDictionary alloc] init] player:player id:nil];
            [self.play.stats addObject:stat];
            [self emit:@"stat-added" data:stat];
            self.state = PlayStateHit;
            self.currentSide = 1 - self.currentSide;
            Stat* currentStat = self.play.stats[self.play.stats.count-1];
            [currentStat.details setObject:@"no hands" forKey:@"hands"];
            
        },
        PlayStateDig: ^(NSArray *line, NSString* player) {
            Stat *stat = [[Stat alloc] initWithSkill:kSkillHit details:[[NSMutableDictionary alloc] init]
                                                  player:player id:nil];
            [self.play.stats addObject:stat];
            [self emit:@"stat-added" data:stat];
            self.state = PlayStateHit;
        }

        
      };
}

- (void)locationsForLine:(NSArray*)line
               startSide:(CourtSide*)startSide
               startArea:(CourtArea*)startArea
                 endSide:(CourtSide*)endSide
                 endArea:(CourtArea*)endArea {
    CGPoint startPoint = [line[0] CGPointValue];
    CGPoint endPoint = [line[[line count]-1] CGPointValue];
    [self locationInCourt:startPoint Side:startSide Area:startArea];
    [self locationInCourt:endPoint Side:endSide Area:endArea];
}

- (void) locationInCourt:(CGPoint)point Side:(CourtSide*)side Area:(CourtArea*)area {
    if (point.x < 0) {
        *side = CourtSideLeft;
    } else {
        *side = CourtSideRight;
    }
    
    if (fabs(point.x) > 1) {
        *area = CourtAreaServeZone;
    } else if (fabs(point.y) > .5f) {
        *area = CourtAreaOutWide;
    } else {
        *area = CourtAreaIn;
    }
}

//This is where we change the state
- (void)advanceStateForLine:(NSArray*)line player:(NSString*)player {
    NSLog(@"%s%u","current side: ",self.currentSide);
    void (^advanceStateMachine)(NSArray*, NSString*) = self.stateMachine[self.state];
    advanceStateMachine(line, player);
}

- (void)advanceStateForButton:(NSString*)button {
    if (self.state == PlayStateServe){
        if ([button isEqual: @"Ace"]){
            [self endPointWithResult:@"ace" winner:self.currentSide];
        } else if ([button isEqual: @"Serve Error"]){
            [self endPointWithResult:@"error" winner:1 - self.currentSide];
        }
    }
    
    if (self.state == PlayStatePass){
        if ([button isEqual: @"Ace"]){
            [self endPointWithResult:@"error" winner:1 - self.currentSide];
        } else{
            Stat* currentStat = self.play.stats[self.play.stats.count-1];
            [currentStat.details setObject:button forKey:@"result"];
            
        }
    }

    if (self.state == PlayStateOverPass){
        if ([button isEqual: @"FB Error"]){
            [self endPointWithResult:@"error" winner:self.currentSide];
        } else if ([button isEqual: @"Overpass Attacked"]){
            self.state = PlayStateOverPassHit;
        }
    }
    if (self.state == PlayStateDig){
        if ([button isEqual: @"Dig Error"]){
            [self endPointWithResult:@"error" winner:1 - self.currentSide];
        }
    }
    
    if (self.state == PlayStateHit){
        if ([button isEqual: @"Hit Error"]){
            [self endPointWithResult:@"error" winner:1 - self.currentSide];
        } else if ([button isEqual: @"Kill"]){
            [self endPointWithResult:@"kill" winner:self.currentSide];
        } else if ([button isEqual: @"Hands"]){
            Stat* currentStat = self.play.stats[self.play.stats.count-1];
            [currentStat.details setObject:@"hands" forKey:@"hands"];
            
        }
        
    
    }
}

- (void) endPointWithResult:(NSString*)result winner:(CourtSide)winner {
    Stat* currentStat = self.play.stats[self.play.stats.count-1];
    [currentStat.details setObject:result forKey:@"result"];
    
    self.play.winner = winner;
    self.state = PlayStatePrePlay;
    [self emit:@"stat-added" data:currentStat];
    
    if (winner != self.servingTeam) {
        self.servingTeam = winner;
        [self.courtView rotateTeam:winner];
    }
    
}

@end
