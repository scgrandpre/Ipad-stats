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
static NSString *PlayStateDig      = @"dig";
static NSString *PlayStateHit      = @"hit";



typedef enum CourtLocation : NSUInteger {
    CourtLocationLeftSide = 0,
    CourtLocationRightSide,
    CourtLocationLeftServeZone,
    CourtLocationRightServeZone,
    CourtLocationOutWideLeft,
    CourtLocationOutWideRight,
} CourtLocation;

typedef enum CurrentSide : NSUInteger {
    CurrentSideLeft = 0,
    CurrentSideRight
} CurrentSide;



@interface StatEntryView ()
@property NSString* state;
@property CurrentSide currentSide;
@property CourtLocation lineZero;
@property CourtLocation lineLast;
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
        
        _currentSide = CurrentSideLeft;
        
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
        
        _stateLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,0,200, 50)];
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

        
        [self makeStateMachine];
        [self makeStateButtons];
        
        self.state = PlayStatePrePlay;
    }
    return self;
}

- (void) makeStateButtons {
    self.buttonsForState = @{
                             PlayStateServe: @[@"Ace", @"Serve Error"],
                             PlayStatePass: @[@"Pass Error"],
                             PlayStateDig: @[@"Dig Error"],
                             PlayStateHit: @[@"Kill", @"Hit Error"],
                             PlayStateOverPass: @[@"FB Error"]
                             };
}

- (void) makeStateMachine {
    NSLog(@"%s%u","current side: ",self.currentSide);

    self.stateMachine = @{
        PlayStatePrePlay: ^(NSArray *line, NSString* player){
            self.play = [[Play alloc] init];
            self.play.rotation = @{};
            [self emit:@"play-added" data:self.play];
            
            [self.courtView rotateTeam:0];
            Stat *stat = [[Stat alloc] initWithSkill:kSkillServe details:[[NSMutableDictionary alloc] init] player:player id:nil];
            [self.play.stats addObject:stat];
            
            [self emit:@"stat-added" data:stat];
            CGPoint pointZero = [line[0] CGPointValue];
            CGPoint pointLast = [line[[line count]-1] CGPointValue];
            self.lineZero = [self locationInCourt:pointZero];
            self.lineLast = [self locationInCourt:pointLast];
            if (self.lineZero == 2){
                NSLog(@"left team just served");
                if (self.lineLast != 1){
                    NSLog(@"Missed Serve");
                    self.State = PlayStatePrePlay;
                }
                else{
                    self.state = PlayStateServe;
                    self.currentSide = CurrentSideLeft;
                    NSLog(@"%s%u","currentSide: " ,self.currentSide);
                }
                    
            } else if (self.lineZero == 3){
                NSLog(@"Right team just served");
                if (self.lineLast != 0){
                    NSLog(@"Missed Serve");
                    self.State = PlayStatePrePlay;
                }
                else{
                    self.state = PlayStateServe;
                    self.currentSide = CurrentSideRight;
                }
            } else{
                NSLog(@"why aren't you serving?");
            }
            
        },
        PlayStateServe: ^(NSArray *line, NSString* player){
                        CGPoint pointZero = [line[0] CGPointValue];
            CGPoint pointLast = [line[[line count]-1] CGPointValue];
            self.lineZero = [self locationInCourt:pointZero];
            self.lineLast = [self locationInCourt:pointLast];
            if (self.currentSide == CurrentSideRight){
                NSLog(@"passing from the left side");
            
                if (self.lineLast == 0 || self.lineLast == 2 || self.lineLast == 4) {
                    NSLog(@"left team just passed on their own side");
                    self.state = PlayStatePass;
                    self.currentSide = CurrentSideLeft;
                    Stat *stat = [[Stat alloc] initWithSkill:kSkillPass details:[[NSMutableDictionary alloc] init] player:player id:nil];
                    [self.play.stats addObject:stat];
                    [self emit:@"stat-added" data:stat];
                    
                }
                else{
                    NSLog(@"Left side team just overpassed");
                    self.state = PlayStateOverPass;
                    Stat *stat = [[Stat alloc] initWithSkill:kSkillPass details:[[NSMutableDictionary alloc] init] player:player id:nil];
                    [self.play.stats addObject:stat];
                    [self emit:@"stat-added" data:stat];
                    self.currentSide = CurrentSideRight;
                    
                }
            }
            else{
                if (self.lineLast == 1 || self.lineLast == 3 || self.lineLast == 5){
                    NSLog(@"Right team just passed on their own side");
                    self.state = PlayStatePass;
                    Stat *stat = [[Stat alloc] initWithSkill:kSkillPass details:[[NSMutableDictionary alloc] init] player:player id:nil];
                    [self.play.stats addObject:stat];
                    [self emit:@"stat-added" data:stat];
                    
                }
                else{
                    NSLog(@"Right side team just overpassed");
                    self.state = PlayStateOverPass;
                    Stat *stat = [[Stat alloc] initWithSkill:kSkillPass details:[[NSMutableDictionary alloc] init] player:player id:nil];
                    [self.play.stats addObject:stat];
                    [self emit:@"stat-added" data:stat];
                    self.currentSide = CurrentSideLeft;
                    
                }

            }
        },
        PlayStatePass: ^(NSArray *line, NSString* player) {
            Stat *stat = [[Stat alloc] initWithSkill:kSkillHit details:[[NSMutableDictionary alloc] init] player:player id:nil];
            [self.play.stats addObject:stat];
            [self emit:@"stat-added" data:stat];
            if (self.currentSide == CurrentSideLeft){
                if (self.lineLast == 1){
                    self.state = PlayStateHit;
                    self.currentSide = CurrentSideRight;
                }
                else{
                   [self endPlayWithWinner:@"0"];
                }
            }
            else{
                if (self.lineLast == 0){
                    self.state = PlayStateHit;
                    self.currentSide = CurrentSideLeft;
                }
                else{
                    [self endPlayWithWinner:@"1"];
                }
            }
            //[self endPlayWithWinner:@"0"];
        },
        PlayStateHit: ^(NSArray *line, NSString* player) {
            Stat *stat = [[Stat alloc] initWithSkill:kSkillDig details:[[NSMutableDictionary alloc] init] player:player id:nil];
            [self.play.stats addObject:stat];
            [self emit:@"stat-added" data:stat];
            if (self.currentSide == CurrentSideLeft){
                if (self.lineLast == 0 || self.lineLast == 2 || self.lineLast == 4){
                    self.currentSide = CurrentSideLeft;
                    self.state = PlayStateDig;
                }
                else{
                    self.currentSide = CurrentSideRight;
                    self.state = PlayStateOverPass;
                }
            }
            else{
                if (self.lineLast == 1 || self.lineLast == 3 || self.lineLast == 5){
                    self.currentSide = CurrentSideRight;
                    self.state = PlayStateDig;
                }
                else{
                    self.currentSide = CurrentSideLeft;
                    self.state = PlayStateOverPass;
                }
            }
        },
        PlayStateOverPass: ^(NSArray *line, NSString* player) {
            Stat *stat = [[Stat alloc] initWithSkill:kSkillDig details:[[NSMutableDictionary alloc] init] player:player id:nil];
            [self.play.stats addObject:stat];
            [self emit:@"stat-added" data:stat];
            self.state = PlayStateDig;
        },
        PlayStateDig: ^(NSArray *line, NSString* player) {
            Stat *stat = [[Stat alloc] initWithSkill:kSkillHit details:[[NSMutableDictionary alloc] init]
                                                  player:player id:nil];
            [self.play.stats addObject:stat];
            [self emit:@"stat-added" data:stat];
            if (self.currentSide == CurrentSideLeft){
                if (self.lineLast == 1){
                    self.state = PlayStateHit;
                    self.currentSide = CurrentSideRight;
                }
                else{
                    [self endPlayWithWinner:@"0"];
                }
            }
            else{
                if (self.lineLast == 0){
                    self.state = PlayStateHit;
                    self.currentSide = CurrentSideLeft;
                }
                else{
                    [self endPlayWithWinner:@"1"];
                }
            }
        }

        
      };
}


- (CourtLocation) locationInCourt:(CGPoint)point {
    if (point.x < -1){
        return CourtLocationLeftServeZone;
    } else if (point.x > 1){
        return CourtLocationRightServeZone;
    } else if (point.y > .5 && point.x > 0){
        return CourtLocationOutWideRight;
    } else if (point.y < -.5 && point.x > 0){
        return CourtLocationOutWideRight;
    } else if (point.y > .5 && point.x < 0){
        return CourtLocationOutWideLeft;
    } else if (point.y < -.5 && point.x < 0){
        return CourtLocationOutWideLeft;
    } else if ((point.x < 1) && (point.x > 0)){
        return CourtLocationRightSide;
    } else if ((point.x > -1) && (point.x < 0)){
        return CourtLocationLeftSide;
    } else {
        return CourtLocationLeftServeZone;
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
            NSLog(@"There was an ace!");
            self.state = PlayStatePrePlay;
            Stat* CurrentStatPlay = self.play.stats[self.play.stats.count-1];
            NSLog(@"%@",CurrentStatPlay.details[@"result"]);
            [CurrentStatPlay.details setObject:@"Ace" forKey:@"Result"];
            [self emit:@"stat-added" data:CurrentStatPlay];
            NSLog(@"%@",CurrentStatPlay.details);
            }
        }
    
    if (self.state == PlayStatePass){
        if ([button isEqual: @"Pass Error"]){
            NSLog(@"There was an Error!");
            self.state = PlayStatePrePlay;
            Stat* CurrentStatPlay = self.play.stats[self.play.stats.count-1];
            NSLog(@"%@",CurrentStatPlay.details[@"result"]);
            [CurrentStatPlay.details setObject:@"Error" forKey:@"Result"];
            [self emit:@"stat-added" data:CurrentStatPlay];
            NSLog(@"%@",CurrentStatPlay.details);
        }
    }

    
    if (self.state == PlayStateOverPass){
        if ([button isEqual: @"FB Error"]){
            NSLog(@"There was an Overpass FB Error!");
            self.state = PlayStatePrePlay;
            Stat* CurrentStatPlay = self.play.stats[self.play.stats.count-1];
            NSLog(@"%@",CurrentStatPlay.details[@"result"]);
            [CurrentStatPlay.details setObject:@"Error" forKey:@"Result"];
            [self emit:@"stat-added" data:CurrentStatPlay];
            NSLog(@"%@",CurrentStatPlay.details);
        }
    }
    if (self.state == PlayStateDig){
        if ([button isEqual: @"Dig Error"]){
            NSLog(@"There was an Error!");
            self.state = PlayStatePrePlay;
            Stat* CurrentStatPlay = self.play.stats[self.play.stats.count-1];
            NSLog(@"%@",CurrentStatPlay.details[@"result"]);
            [CurrentStatPlay.details setObject:@"Error" forKey:@"Result"];
            [self emit:@"stat-added" data:CurrentStatPlay];
            NSLog(@"%@",CurrentStatPlay.details);
        }
    }
    
        if (self.state == PlayStateServe){
            if ([button isEqual: @"Serve Error"]){
                NSLog(@"There was Serving Error!");
                self.state = PlayStatePrePlay;
                Stat* CurrentStatPlay = self.play.stats[self.play.stats.count-1];
                [CurrentStatPlay.details setObject:@"Error" forKey:@"Result"];
                [self emit:@"stat-added" data:CurrentStatPlay];
                NSLog(@"%@",CurrentStatPlay.details);
            }
        }
        
        if (self.state == PlayStateHit){
            if ([button isEqual: @"Hit Error"]){
                NSLog(@"There was a Hitting Error!");
                self.state = PlayStatePrePlay;
                Stat* CurrentStatPlay = self.play.stats[self.play.stats.count-1];
                NSLog(@"%@",CurrentStatPlay.details[@"result"]);
                [CurrentStatPlay.details setObject:@"Error" forKey:@"Result"];
                [self emit:@"stat-added" data:CurrentStatPlay];
                NSLog(@"%@",CurrentStatPlay.details);
            }
        }
    
        if (self.state == PlayStateHit){
            if ([button isEqual: @"Kill"]){
                NSLog(@"There was a Kill!");
                self.state = PlayStatePrePlay;
                Stat* CurrentStatPlay = self.play.stats[self.play.stats.count-1];
                NSLog(@"%@",CurrentStatPlay.details[@"result"]);
                [CurrentStatPlay.details setObject:@"Error" forKey:@"Result"];
                [self emit:@"stat-added" data:CurrentStatPlay];
                NSLog(@"%@",CurrentStatPlay.details);
                self.play.winner = self.currentSide;
            }
        }
    }
    
    
//    self.stateMachine = @{
//    PlayStatePass: ^(NSArray *button) {
//        Stat *stat = [[Stat alloc] initWithSkill:kSkillHit details:[[NSMutableDictionary alloc] init] id:nil];
//        [self.play.stats addObject:stat];
//        [self emit:@"stat-added" data:stat];
//        NSLog(@"%s%@","which button?: ", button);
//        
//
//    
//    }
//    };



- (void)endPlayWithWinner:(NSString*)winner {
    self.state = PlayStatePrePlay;
    self.play.winner = winner;
    //[self emit:@"play-ended" data:self.play];
    self.play = nil;
}

@end
