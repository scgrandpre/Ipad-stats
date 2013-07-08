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

static NSString *CurrentSideLeft  = @"Left";
static NSString *CurrentSideRight = @"Right";


typedef enum CourtLocation : NSUInteger {
    CourtLocationLeftSide = 0,
    CourtLocationRightSide,
    CourtLocationLeftServeZone,
    CourtLocationRightServeZone,
    CourtLocationOutWideLeft,
    CourtLocationOutWideRight,
} CourtLocation;
//
//typedef enum CurrentSide : NSUInteger {
//    CurrentSideLeft = 0,
//    CurrentSideRIght
//} CurrentSide;



@interface StatEntryView ()
@property NSString* state;
@property NSString* currentSide;
@property CourtLocation lineZero;
@property CourtLocation lineLast;
@property Play *play;
@property NSDictionary *stateMachine;
@property UILabel *stateLabel;
@end


@implementation StatEntryView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _state = PlayStatePrePlay;
        _currentSide = CurrentSideLeft;
        
        CGFloat courtAspectRatio = 8/5.f;
        
        CGFloat height = self.bounds.size.height - 200;
        CGFloat width = self.bounds.size.width;
        
        if (height * courtAspectRatio > width) {
            height = width/courtAspectRatio;
        } else {
            width = height * courtAspectRatio;
        }
        
        CourtView *courtView = [[CourtView alloc] initWithFrame:CGRectMake(self.bounds.origin.x, self.bounds.origin.y + 200, width, height)];
        [self addSubview:courtView];
        
        [courtView on:@"drew-line" callback:^(NSArray* line){
            [self advanceStateForLine:line];
        }];
        
        _stateLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,0,200, 50)];
        _stateLabel.text = _state;
        [self addSubview:_stateLabel];
        
        [self makeStateMachine];
    }
    return self;
}

- (void) makeStateMachine {

    self.stateMachine = @{
        PlayStatePrePlay: ^(NSArray *line){
            self.play = [[Play alloc] init];
            Stat *stat = [[Stat alloc] initWithSkill:kSkillServe details:@{} id:nil];
            [self.play.stats addObject:stat];
            [self emit:@"play-added" data:self.play];
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
                    NSLog(@"%s%@","currentSide: " ,self.currentSide);
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
        PlayStateServe: ^(NSArray *line){
                        CGPoint pointZero = [line[0] CGPointValue];
            CGPoint pointLast = [line[[line count]-1] CGPointValue];
            self.lineZero = [self locationInCourt:pointZero];
            self.lineLast = [self locationInCourt:pointLast];
            if ([self.currentSide isEqual: @"Right"]){
                NSLog(@"passing from the left side");
            
                if (self.lineLast == 0 || self.lineLast == 2 || self.lineLast == 4) {
                    NSLog(@"left team just passed on their own side");
                    self.state = PlayStatePass;
                    self.currentSide = CurrentSideLeft;
                    Stat *stat = [[Stat alloc] initWithSkill:kSkillPass details:@{} id:nil];
                    [self.play.stats addObject:stat];
                    [self emit:@"stat-added" data:stat];
                    
                }
                else{
                    NSLog(@"Left side team just overpassed");
                    self.state = PlayStateOverPass;
                    Stat *stat = [[Stat alloc] initWithSkill:kSkillPass details:@{} id:nil];
                    [self.play.stats addObject:stat];
                    [self emit:@"stat-added" data:stat];
                    self.currentSide = CurrentSideRight;
                    
                }
            }
            else{
                if (self.lineLast == 1 || self.lineLast == 3 || self.lineLast == 5){
                    NSLog(@"Right team just passed on their own side");
                    self.state = PlayStatePass;
                    Stat *stat = [[Stat alloc] initWithSkill:kSkillPass details:@{} id:nil];
                    [self.play.stats addObject:stat];
                    [self emit:@"stat-added" data:stat];
                    
                }
                else{
                    NSLog(@"Right side team just overpassed");
                    self.state = PlayStateOverPass;
                    Stat *stat = [[Stat alloc] initWithSkill:kSkillPass details:@{} id:nil];
                    [self.play.stats addObject:stat];
                    [self emit:@"stat-added" data:stat];
                    
                }

            }
        },
        PlayStatePass: ^(NSArray *line) {
            Stat *stat = [[Stat alloc] initWithSkill:kSkillHit details:@{} id:nil];
            [self.play.stats addObject:stat];
            [self emit:@"stat-added" data:stat];
            [self endPlayWithWinner:@"0"];
        },
        PlayStateHit: ^(NSArray *line) {
            Stat *stat = [[Stat alloc] initWithSkill:kSkillDig details:@{} id:nil];
            [self.play.stats addObject:stat];
            [self emit:@"stat-added" data:stat];
            self.state = PlayStateDig;
        },
        PlayStateOverPass: ^(NSArray *line) {
            Stat *stat = [[Stat alloc] initWithSkill:kSkillDig details:@{} id:nil];
            [self.play.stats addObject:stat];
            [self emit:@"stat-added" data:stat];
            self.state = PlayStateDig;
        },
        PlayStateDig: ^(NSArray *line) {
            Stat *stat = [[Stat alloc] initWithSkill:kSkillHit details:@{} id:nil];
            [self.play.stats addObject:stat];
            [self emit:@"stat-added" data:stat];
            self.state = PlayStateDig;
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
- (void)advanceStateForLine:(NSArray*)line {
    // TODO: Add line to stats, make sure all of these stats are init'd with their line.
    Stat *stat;
    
    void (^advanceStateMachine)(NSArray*) = self.stateMachine[self.state];
    advanceStateMachine(line);
    self.stateLabel.text = _state;
    
}

- (void)endPlayWithWinner:(NSString*)winner {
    self.state = PlayStatePrePlay;
    self.play.winner = winner;
    //[self emit:@"play-ended" data:self.play];
    self.play = nil;
}

@end
