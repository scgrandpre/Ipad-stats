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
@property UIView *addResultView;
@property StatEventButtonsView *addResultButtons;

@property NSString* selectedPlayer;
@property StatEventButtonsView *addDetailButtons;
@property (readonly)  UIButton *toughButton;
@property (readonly) UIButton *passiveButton;
@property (readonly) UIButton *handsButton;
@property (readonly) UIButton *nohandsButton;
@end


@implementation StatEntryView
@synthesize state = _state;
@synthesize toughButton = _toughButton;
@synthesize passiveButton = _passiveButton;

- (NSString*) state {
    return _state;
}
-(UIButton *)toughButton {
    
    if (_toughButton == nil){
        //_toughButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_toughButton addTarget:self
                    action:@selector(toughButtonTapped:)
              forControlEvents:UIControlEventTouchUpInside];
        [_toughButton setTitle:@"Tough Serve" forState:UIControlStateNormal];
        [self addSubview:_toughButton];
        return _toughButton;
        
    }
    
    else{
        
        return _toughButton;
    }
}
-(UIButton *)passiveButton {
    
    if (_passiveButton == nil){
        
        return _passiveButton;
        
    }
    
    else{
        
        return nil;
    }
}


- (void) setState:(NSString *)state {
    _state = state;
    self.stateLabel.text = state;
    self.buttonsView.buttonTitles = self.buttonsForState[state];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.toughButton.frame = CGRectMake(80.0, self.bounds.size.height - 20, 160.0, 40.0);
}

- (id)initWithFrame:(CGRect)frame
{
    
    [self addSubview:self.toughButton];
    self = [super initWithFrame:frame];
    if (self) {
        CGFloat courtAspectRatio = 8/5.f;
        
        
        StatEventButtonsView *subsView = [[StatEventButtonsView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, 200)];
        [self addSubview:subsView];
        subsView.buttonTitles = @[@"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", @"10", @"11", @"12", @"13", @"14", @"15", @"16", @"17", @"18", @"19", @"20"];
        subsView.selectedButton = subsView.buttonTitles[0];
        self.selectedPlayer = subsView.buttonTitles[0];
        [subsView on:@"button-pressed" callback:^(NSString* player) {
            subsView.selectedButton = player;
            self.selectedPlayer = player;
        }];
        
        CGFloat height = self.bounds.size.height - subsView.frame.size.height;
        CGFloat width = self.bounds.size.width;
        
        if (height * courtAspectRatio > width) {
            height = width/courtAspectRatio;
        } else {
            width = height * courtAspectRatio;
        }
        
        _courtView = [[CourtView alloc] initWithFrame:CGRectMake(self.bounds.origin.x + self.bounds.size.width/2 - width/2,
                                                                 CGRectGetMaxY(subsView.frame) + (self.bounds.size.height - subsView.frame.size.height)/2 - height/2, width, height)];
        [self addSubview:_courtView];
        
        [_courtView on:@"drew-line" callback:^(NSDictionary* data){
            [self advanceStateForLine:data[@"line"] player:data[@"player"]];
            
        }];
        
        _addResultView = [[UIView alloc] initWithFrame:_courtView.frame];
        [self addSubview:_addResultView];
        _addResultView.hidden = YES;
        _addResultView.backgroundColor = [UIColor whiteColor];
        
        _addResultButtons = [[StatEventButtonsView alloc] initWithFrame:_addResultView.bounds];
        [_addResultView addSubview:_addResultButtons];
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
    //self.toughButton.hidden = YES;
    
    CourtSide startSide, endSide;
    CourtArea startArea, endArea;
    [self locationsForLine:line startSide:&startSide startArea:&startArea endSide:&endSide endArea:&endArea];
    
    self.play = [[Play alloc] init];
    self.play.rotation = @{};

    
    Stat *stat;
    if (startArea == CourtAreaServeZone) {
        //self.toughButton.hidden = YES;
        // Serve
        stat = [[Stat alloc] initWithSkill:kSkillServe details:[[NSMutableDictionary alloc] init] player:player id:nil];
        [_toughButton setHidden:NO];
        
            
        
        
        
        UIButton *passiveButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [passiveButton addTarget:self
                        action:@selector(aMethod:)
              forControlEvents:UIControlEventTouchUpInside];
        [passiveButton setTitle:@"Passive Serve" forState:UIControlStateNormal];
        passiveButton.frame = CGRectMake(250,self.bounds.size.height - 20 , 160.0, 40.0);
        [self addSubview:passiveButton];
        
        
    } else {
        //Hit
        stat = [[Stat alloc] initWithSkill:kSkillHit details:[[NSMutableDictionary alloc] init] player:player id:nil];
        UIButton *handsButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [handsButton addTarget:self
                        action:@selector(toughButtonTapped:)
              forControlEvents:UIControlEventTouchUpInside];
        [handsButton setTitle:@"Hands" forState:UIControlStateNormal];
        handsButton.frame = CGRectMake(420.0, self.bounds.size.height - 20, 160.0, 40.0);
        [self addSubview:handsButton];
        
        
        UIButton *nohandsButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [nohandsButton addTarget:self
                        action:@selector(toughButtonTapped:)
              forControlEvents:UIControlEventTouchUpInside];
        [nohandsButton setTitle:@"No Hands" forState:UIControlStateNormal];
        nohandsButton.frame = CGRectMake(590.0, self.bounds.size.height - 20, 160.0, 40.0);
        [self addSubview:nohandsButton];
        
    }
    stat.details[@"line"] = line;
    [self.play.stats addObject:stat];

    [self addResultForStat:stat];
}
-(IBAction)toughButtonTapped:(UIButton *)sender
{
    NSLog(@"Tough Button Tapped!");
//    _toughButton.hidden = YES;

    //sender.hidden = YES;
    
    
    
}

- (void)addResultForStat:(Stat *)stat {
    if (stat.skill == kSkillServe) {
        self.addResultButtons.buttonTitles = @[@"ace", @"0", @"1", @"2", @"3", @"4", @"err"];
    } else {
        self.addResultButtons.buttonTitles = @[@"kill", @"error", @"us", @"them"];
    }
    self.addResultView.hidden = YES;
    
    [self.addResultButtons once:@"button-pressed" callback:^(NSString* result) {
        stat.details[@"result"] = result;
        stat.player = self.selectedPlayer;
        self.addResultView.hidden = YES;
        
        [self emit:@"play-added" data:self.play];
        [self emit:@"stat-added" data:stat];
        
    }];
}

- (void)addDetailForStat:(Stat *)stat {
    if (stat.skill == kSkillServe) {
        self.addResultButtons.buttonTitles = @[@"ace", @"0", @"1", @"2", @"3", @"4", @"err"];
    } else {
        self.addResultButtons.buttonTitles = @[@"kill", @"error", @"us", @"them"];
    }
    self.addResultView.hidden = NO;
    
    [self.addResultButtons once:@"button-pressed" callback:^(NSString* result) {
        stat.details[@"result"] = result;
        stat.player = self.selectedPlayer;
        self.addResultView.hidden = YES;
        
        [self emit:@"play-added" data:self.play];
        [self emit:@"stat-added" data:stat];

        
        
    }];
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
