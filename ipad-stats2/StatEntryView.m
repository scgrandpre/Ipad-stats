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
static NSString *kSkillBlock   = @"Block";

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
@property (readonly) UIButton *toughServeButton;
@property (readonly) UIButton *passiveServeButton;
@property (readonly) UIButton *handsButton;
@property (readonly) UIButton *noHandsButton;
@property (readonly) UIButton *goodBlockTouchButton;
@property (readonly) UIButton *badBlockTouchButton;
@property (readonly) UIButton *passedByButton;
@property (readonly) UIButton *aggressivePassButton;
@property (readonly) UIButton *passivePassButton;
@property (readonly) UIButton *digErrorButton;
@property (readonly) UIButton *digButton;
@property (readonly) UIButton *upButton;
@property (readonly) UIButton *coverErrorButton;
@property (readonly) UIButton *coverDigButton;
@property (readonly) UIButton *coverUpButton;
//game buttons
@property (readonly) UIButton *gameButton;
@property (readonly) UIButton *gameButton1;
@property (readonly) UIButton *gameButton2;
@property (readonly) UIButton *gameButton3;
@property (readonly) UIButton *gameButton4;
@property (readonly) UIButton *gameButton5;

//game details
@property NSInteger currentGame;
@property NSInteger currentRotation;

@end


@implementation StatEntryView
@synthesize state = _state;
@synthesize toughServeButton = _toughServeButton;
@synthesize passiveServeButton = _passiveServeButton;
@synthesize handsButton = _handsButton;
@synthesize noHandsButton = _noHandsButton;
@synthesize goodBlockTouchButton = _goodBlockTouchButton;
@synthesize badBlockTouchButton = _badBlockTouchButton;
//passing
@synthesize passedByButton = _passedByButton;
@synthesize aggressivePassButton = _aggressivePassButton;
@synthesize passivePassButton = _passivePassButton;
//Digging
@synthesize digErrorButton = _digErrorButton;
@synthesize digButton = _digButton;
@synthesize upButton = _upButton;
//covering
@synthesize coverErrorButton = _coverErrorButton;
@synthesize coverDigButton = _coverDigButton;
@synthesize coverUpButton = _coverUpButton;

@synthesize gameButton = _gameButton;
@synthesize gameButton1 = _gameButton1;
@synthesize gameButton2 = _gameButton2;
@synthesize gameButton3 = _gameButton3;
@synthesize gameButton4 = _gameButton4;
@synthesize gameButton5 = _gameButton5;


- (NSString*) state {
    return _state;
}
- (UIButton *)makeButton {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    button.layer.backgroundColor = [UIColor colorWithRed:218.0/255 green:223.0/255 blue:225.0/255.0 alpha:.4].CGColor;
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [button.layer setBorderWidth:2.0];
    [button.layer setBorderColor:[[UIColor blackColor] CGColor]];
    [button setHidden:YES];
    return button;
}

//Serving
-(UIButton *)toughServeButton {
    
    if (_toughServeButton == nil){
        _toughServeButton = [self makeButton];
        [_toughServeButton addTarget:self
                    action:@selector(toughServeButtonTapped:)
              forControlEvents:UIControlEventTouchUpInside];
        [_toughServeButton setTitle:@"Tough Serve" forState:UIControlStateNormal];
        return _toughServeButton;
    }
    else{
        return _toughServeButton;
    }
}

-(UIButton *)passiveServeButton {
    
    if (_passiveServeButton == nil){
        _passiveServeButton = [self makeButton];
        [_passiveServeButton addTarget:self
                         action:@selector(passiveServeButtonTapped:)
               forControlEvents:UIControlEventTouchUpInside];
        [_passiveServeButton setTitle:@"Passive Serve" forState:UIControlStateNormal];
        return _passiveServeButton;
    }
    else{
        return _passiveServeButton;
    }
}
//Attacking
-(UIButton *)handsButton {
    
    if (_handsButton == nil){
        _handsButton = [self makeButton];
        [_handsButton addTarget:self
                         action:@selector(handsButtonTapped:)
               forControlEvents:UIControlEventTouchUpInside];
        [_handsButton setTitle:@"Hands" forState:UIControlStateNormal];
        return _handsButton;
    }
    else{
        return _handsButton;
    }
}

-(UIButton *)noHandsButton {
    
    if (_noHandsButton == nil){
        _noHandsButton = [self makeButton];
        [_noHandsButton addTarget:self
                         action:@selector(noHandsButtonTapped:)
               forControlEvents:UIControlEventTouchUpInside];
        [_noHandsButton setTitle:@"No Hands" forState:UIControlStateNormal];
        return _noHandsButton;
    }
    else{
        return _noHandsButton;
    }
}

//blocking
-(UIButton *)badBlockTouchButton {
    
    if (_badBlockTouchButton == nil){
        _badBlockTouchButton = [self makeButton];
        [_badBlockTouchButton addTarget:self
                              action:@selector(badBlockTouchButtonTapped:)
                    forControlEvents:UIControlEventTouchUpInside];
        [_badBlockTouchButton setTitle:@"Bad Touch" forState:UIControlStateNormal];
        return _badBlockTouchButton;
    }
    else{
        return _badBlockTouchButton;
    }
}
-(UIButton *)goodBlockTouchButton {
    
    if (_goodBlockTouchButton == nil){
        _goodBlockTouchButton = [self makeButton];
        [_goodBlockTouchButton addTarget:self
                              action:@selector(goodBlockTouchButtonTapped:)
                    forControlEvents:UIControlEventTouchUpInside];
        [_goodBlockTouchButton setTitle:@"Good Touch" forState:UIControlStateNormal];
        return _goodBlockTouchButton;
    }
    else{
        return _goodBlockTouchButton;
    }
}
//Passing
-(UIButton *)passedByButton {
    
    if (_passedByButton == nil){
        _passedByButton = [self makeButton];
        [_passedByButton addTarget:self
                              action:@selector(passedByButtonTapped:)
                    forControlEvents:UIControlEventTouchUpInside];
        [_passedByButton setTitle:@"Passed By" forState:UIControlStateNormal];
        return _passedByButton;
    }
    else{
        return _passedByButton;
    }
}
-(UIButton *)aggressivePassButton {
    
    if (_aggressivePassButton == nil){
        _aggressivePassButton = [self makeButton];
        [_aggressivePassButton addTarget:self
                                 action:@selector(aggressivePassButtonTapped:)
                       forControlEvents:UIControlEventTouchUpInside];
        [_aggressivePassButton setTitle:@"Aggressive Pass" forState:UIControlStateNormal];
        return _aggressivePassButton;
    }
    else{
        return _aggressivePassButton;
    }
}
-(UIButton *)passivePassButton {
    
    if (_passivePassButton == nil){
        _passivePassButton = [self makeButton];
        [_passivePassButton addTarget:self
                            action:@selector(passivePassButtonTapped:)
                  forControlEvents:UIControlEventTouchUpInside];
        [_passivePassButton setTitle:@"Passive Pass" forState:UIControlStateNormal];
        return _passivePassButton;
    }
    else{
        return _passivePassButton;
    }
}

-(UIButton *)digErrorButton {
    
    if (_digErrorButton == nil){
        _digErrorButton = [self makeButton];
        [_digErrorButton addTarget:self
                              action:@selector(digErrorButtonTapped:)
                    forControlEvents:UIControlEventTouchUpInside];
        [_digErrorButton setTitle:@"Dig Error" forState:UIControlStateNormal];
        [_digErrorButton setHidden:NO];
        return _digErrorButton;
    }
    else{
        return _digErrorButton;
    }
}
-(UIButton *)digButton {
    
    if (_digButton == nil){
        _digButton = [self makeButton];
        [_digButton addTarget:self
                         action:@selector(digButtonTapped:)
               forControlEvents:UIControlEventTouchUpInside];
        [_digButton setTitle:@"Dig" forState:UIControlStateNormal];
        [_digButton setHidden:NO];
        return _digButton;
    }
    else{
        return _digButton;
    }
}
-(UIButton *)upButton {
    
    if (_upButton == nil){
        _upButton = [self makeButton];
        [_upButton addTarget:self
                         action:@selector(upButtonTapped:)
               forControlEvents:UIControlEventTouchUpInside];
        [_upButton setTitle:@"Up" forState:UIControlStateNormal];
        [_upButton setHidden:NO];
        return _upButton;
    }
    else{
        return _upButton;
    }
}

-(UIButton *)coverErrorButton {
    
    if (_coverErrorButton == nil){
        _coverErrorButton = [self makeButton];
        [_coverErrorButton addTarget:self
                              action:@selector(coverErrorButtonTapped:)
                    forControlEvents:UIControlEventTouchUpInside];
        [_coverErrorButton setTitle:@"Cover Error" forState:UIControlStateNormal];
        [_coverErrorButton setHidden:NO];
        return _coverErrorButton;
    }
    else{
        return _coverErrorButton;
    }
}
-(UIButton *)coverDigButton {
    
    if (_coverDigButton == nil){
        _coverDigButton = [self makeButton];
        [_coverDigButton addTarget:self
                             action:@selector(coverDigButtonTapped:)
                   forControlEvents:UIControlEventTouchUpInside];
        [_coverDigButton setTitle:@"Cover Dig" forState:UIControlStateNormal];
        [_coverDigButton setHidden:NO];
        return _coverDigButton;
    }
    else{
        return _coverDigButton;
    }
}
-(UIButton *)coverUpButton {
    
    if (_coverUpButton == nil){
        _coverUpButton = [self makeButton];
        [_coverUpButton addTarget:self
                             action:@selector(coverUpButtonTapped:)
                   forControlEvents:UIControlEventTouchUpInside];
        [_coverUpButton setTitle:@"Cover Up" forState:UIControlStateNormal];
        [_coverUpButton setHidden:NO];
        return _coverUpButton;
    }
    else{
        return _coverUpButton;
    }
}
-(UIButton *)gameButton {
    
    if (_gameButton == nil){
        _gameButton = [self makeButton];
        [_gameButton addTarget:self
                           action:@selector(gameButtonTapped:)
                 forControlEvents:UIControlEventTouchUpInside];
        [_gameButton setTitle:@"Change Game" forState:UIControlStateNormal];
        [_gameButton setHidden:NO];
        return _gameButton;
    }
    else{
        return _gameButton;
    }
}

-(UIButton *)gameButton1 {
    
    if (_gameButton1 == nil){
        _gameButton1 = [self makeButton];
        [_gameButton1 addTarget:self
                        action:@selector(gameButton1Tapped:)
              forControlEvents:UIControlEventTouchUpInside];
        [_gameButton1 setTitle:@"Game 1" forState:UIControlStateNormal];
        [_gameButton1 setHidden:YES];
        return _gameButton1;
    }
    else{
        return _gameButton1;
    }
}


-(UIButton *)gameButton2 {
    
    if (_gameButton2 == nil){
        _gameButton2 = [self makeButton];
        [_gameButton2 addTarget:self
                        action:@selector(gameButton2Tapped:)
              forControlEvents:UIControlEventTouchUpInside];
        [_gameButton2 setTitle:@"Game 2" forState:UIControlStateNormal];
        [_gameButton2 setHidden:YES];
        return _gameButton2;
    }
    else{
        return _gameButton2;
    }
}


-(UIButton *)gameButton3 {
    
    if (_gameButton3 == nil){
        _gameButton3 = [self makeButton];
        [_gameButton3 addTarget:self
                        action:@selector(gameButton3Tapped:)
              forControlEvents:UIControlEventTouchUpInside];
        [_gameButton3 setTitle:@"Game 3" forState:UIControlStateNormal];
        [_gameButton3 setHidden:YES];
        return _gameButton3;
    }
    else{
        return _gameButton3;
    }
}


-(UIButton *)gameButton4 {
    
    if (_gameButton4 == nil){
        _gameButton4 = [self makeButton];
        [_gameButton4 addTarget:self
                        action:@selector(gameButton4Tapped:)
              forControlEvents:UIControlEventTouchUpInside];
        [_gameButton4 setTitle:@"Game 4" forState:UIControlStateNormal];
        [_gameButton4 setHidden:YES];
        return _gameButton4;
    }
    else{
        return _gameButton4;
    }
}


-(UIButton *)gameButton5 {
    
    if (_gameButton5 == nil){
        _gameButton5 = [self makeButton];
        [_gameButton5 addTarget:self
                        action:@selector(gameButton5Tapped:)
              forControlEvents:UIControlEventTouchUpInside];
        [_gameButton5 setTitle:@"Game 5" forState:UIControlStateNormal];
        [_gameButton5 setHidden:YES];
        return _gameButton5;
    }
    else{
        return _gameButton5;
    }
}



//end button creation

-(void) setState:(NSString *)state {
    _state = state;
    self.stateLabel.text = state;
    self.buttonsView.buttonTitles = self.buttonsForState[state];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _toughServeButton.frame = CGRectMake(self.bounds.origin.x, 6*self.bounds.size.height/16, self.bounds.size.width/10, self.bounds.size.height/16);
    _passiveServeButton.frame = CGRectMake(self.bounds.origin.x, 7*self.bounds.size.height/16, self.bounds.size.width/10, self.bounds.size.height/16);
    _handsButton.frame = CGRectMake(self.bounds.origin.x, 6*self.bounds.size.height/16, self.bounds.size.width/10, self.bounds.size.height/16);
    _noHandsButton.frame = CGRectMake(self.bounds.origin.x, 7*self.bounds.size.height/16, self.bounds.size.width/10, self.bounds.size.height/16);
    _goodBlockTouchButton.frame = CGRectMake(self.bounds.origin.x, 6*self.bounds.size.height/16, self.bounds.size.width/10, self.bounds.size.height/16);
    _badBlockTouchButton.frame = CGRectMake(self.bounds.origin.x, 7*self.bounds.size.height/16, self.bounds.size.width/10, self.bounds.size.height/16);
    _passedByButton.frame = CGRectMake(self.bounds.origin.x, 9*self.bounds.size.height/16, self.bounds.size.width/10, self.bounds.size.height/16);
    _aggressivePassButton.frame = CGRectMake(self.bounds.origin.x, 10*self.bounds.size.height/16, self.bounds.size.width/10, self.bounds.size.height/16);
    _passivePassButton.frame = CGRectMake(self.bounds.origin.x, 11*self.bounds.size.height/16, self.bounds.size.width/10, self.bounds.size.height/16);
    _digButton.frame = CGRectMake(self.bounds.size.width-self.bounds.size.width/10,
                                        6*self.bounds.size.height/16, self.bounds.size.width/10, self.bounds.size.height/16);
    _upButton.frame = CGRectMake(self.bounds.size.width-self.bounds.size.width/10,
                                        7*self.bounds.size.height/16, self.bounds.size.width/10, self.bounds.size.height/16);
    _digErrorButton.frame = CGRectMake(self.bounds.size.width-self.bounds.size.width/10,
                                       8*self.bounds.size.height/16, self.bounds.size.width/10, self.bounds.size.height/16);
    _coverDigButton.frame = CGRectMake(self.bounds.size.width-self.bounds.size.width/10,
                                       11*self.bounds.size.height/16, self.bounds.size.width/10, self.bounds.size.height/16);
    _coverUpButton.frame = CGRectMake(self.bounds.size.width-self.bounds.size.width/10,
                                      12*self.bounds.size.height/16, self.bounds.size.width/10, self.bounds.size.height/16);
    _coverErrorButton.frame = CGRectMake(self.bounds.size.width-self.bounds.size.width/10,
                                         13*self.bounds.size.height/16, self.bounds.size.width/10, self.bounds.size.height/16);
    _gameButton.frame = CGRectMake(self.bounds.origin.x, 14*self.bounds.size.height/16, self.bounds.size.width/10, 2*self.bounds.size.height/16);
    _gameButton1.frame = CGRectMake(self.bounds.origin.x, 9*self.bounds.size.height/16, self.bounds.size.width/10, self.bounds.size.height/16);
    _gameButton2.frame = CGRectMake(self.bounds.origin.x, 10*self.bounds.size.height/16, self.bounds.size.width/10, self.bounds.size.height/16);
    _gameButton3.frame = CGRectMake(self.bounds.origin.x, 11*self.bounds.size.height/16, self.bounds.size.width/10, self.bounds.size.height/16);
    _gameButton4.frame = CGRectMake(self.bounds.origin.x, 12*self.bounds.size.height/16, self.bounds.size.width/10, self.bounds.size.height/16);
    _gameButton5.frame = CGRectMake(self.bounds.origin.x, 13*self.bounds.size.height/16, self.bounds.size.width/10, self.bounds.size.height/16);
    
}

- (id)initWithFrame:(CGRect)frame
{
    
self = [super initWithFrame:frame];
    if (self) {
        CGFloat courtAspectRatio = 8/5.f;
        [self addSubview:self.toughServeButton];
        [self addSubview:self.passiveServeButton];
        [self addSubview:self.handsButton];
        [self addSubview:self.noHandsButton];
        [self addSubview:self.goodBlockTouchButton];
        [self addSubview:self.badBlockTouchButton];
        [self addSubview:self.passedByButton];
        [self addSubview:self.aggressivePassButton];
        [self addSubview:self.passivePassButton];
        [self addSubview:self.digErrorButton];
        [self addSubview:self.digButton];
        [self addSubview:self.upButton];
        [self addSubview:self.coverErrorButton];
        [self addSubview:self.coverDigButton];
        [self addSubview:self.coverUpButton];
        [self addSubview:self.gameButton];
        [self addSubview:self.gameButton1];
        [self addSubview:self.gameButton2];
        [self addSubview:self.gameButton3];
        [self addSubview:self.gameButton4];
        [self addSubview:self.gameButton5];
        //current rotation, current game
        _currentGame = 1;
        _currentRotation = 1;
        
        
        
        
        
        
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
    NSNumber *dictCurrentGame = [NSNumber numberWithInt:_currentGame];
    stat.details[@"game"] =  dictCurrentGame;
    NSNumber *dictCurrentRotation = [NSNumber numberWithInt:_currentRotation];
    stat.details[@"rotation"] =  dictCurrentRotation;
    
    
    if ( startSide == CourtSideLeft){
        if (startArea == CourtAreaServeZone) {
            // Serve
            stat = [[Stat alloc] initWithSkill:kSkillServe details:[[NSMutableDictionary alloc] init] team:@"SHU" player:player id:nil];

            stat.details[@"line"] = line;
            [self.play.stats addObject:stat];
            [self addResultForStat:stat];
            [self.toughServeButton setHidden:NO];
            [self.passiveServeButton setHidden:NO];
        } else {
            //Hit

            stat = [[Stat alloc] initWithSkill:kSkillHit details:[[NSMutableDictionary alloc] init] team:@"SHU" player:player id:nil];

            stat.details[@"line"] = line;
            [self.play.stats addObject:stat];
            [self addResultForStat:stat];
            [self.handsButton setHidden:NO];
            [self.noHandsButton setHidden:NO];
        }
    }
        else{
            NSLog(@"right side of court");
            if (startArea == CourtAreaServeZone) {
                // Serve Other team
                stat = [[Stat alloc] initWithSkill:kSkillServe details:[[NSMutableDictionary alloc] init] team:@"Other" player:player id:nil];
                stat.details[@"line"] = line;
                [self.play.stats addObject:stat];
                [self addResultForStat:stat];
                [self.passedByButton setHidden:NO];
                [self.aggressivePassButton setHidden:NO];
                [self.passivePassButton setHidden:NO];
                
            } else {
                //Attack other team
                
                stat = [[Stat alloc] initWithSkill:kSkillHit details:[[NSMutableDictionary alloc] init] team:@"Other" player:player id:nil];
                
                stat.details[@"line"] = line;
                [self.play.stats addObject:stat];
                [self addResultForStat:stat];
                [self.handsButton setHidden:NO];
                [self.noHandsButton setHidden:NO];
            }
        
        
        }
}
-(IBAction)toughServeButtonTapped:(UIButton *)sender
{
    NSLog(@"Tough Serve Button Tapped!");
    [self.toughServeButton setHidden:YES];
    [self.passiveServeButton setHidden:YES];
    Stat* stat =self.play.stats[0];
    stat.details[@"toughServe"] = @"Tough";
}

-(IBAction)passiveServeButtonTapped:(UIButton *)sender
{
    NSLog(@"Passive ServeButton Tapped!");
    [self.toughServeButton setHidden:YES];
    [self.passiveServeButton setHidden:YES];
    Stat* stat =self.play.stats[0];
    stat.details[@"toughServe"] = @"Passive";

}

-(IBAction)handsButtonTapped:(UIButton *)sender
{
    NSLog(@"Hands Button Tapped!");
    [self.handsButton setHidden:YES];
    [self.noHandsButton setHidden:YES];
    [self.goodBlockTouchButton setHidden:NO];
    [self.badBlockTouchButton setHidden:NO];
    Stat* stat =self.play.stats[0];
    stat.details[@"Hands"] = @"Hands";
}

-(IBAction)noHandsButtonTapped:(UIButton *)sender
{
    NSLog(@"No Hands Button Tapped!");
    [self.handsButton setHidden:YES];
    [self.noHandsButton setHidden:YES];
    Stat* stat =self.play.stats[0];
    stat.details[@"Hands"] = @"No Hands";
}

-(IBAction)goodBlockTouchButtonTapped:(UIButton *)sender
{
    NSLog(@"Good Block Touch Button Tapped!");
    [self.goodBlockTouchButton setHidden:YES];
    [self.badBlockTouchButton setHidden:YES];
    Stat* stat =self.play.stats[0];
    stat.details[@"Block Touch"] = @"Good Touch";
    stat.details[@"Block Touch By"] = self.selectedPlayer;

    
//
//    Stat* stat =self.play.stats[0];
//    stat.skill = kSkillBlock;
//    stat.details[@"Block Touch"] = @"Good Touch";

}
-(IBAction)badBlockTouchButtonTapped:(UIButton *)sender
{
    NSLog(@"Bad Block Touch Button Tapped!");
    [self.goodBlockTouchButton setHidden:YES];
    [self.badBlockTouchButton setHidden:YES];
    Stat* stat =self.play.stats[0];
    stat.details[@"Block Touch"] = @"Bad Touch";
    stat.details[@"Block Touch By"] = self.selectedPlayer;
}
//passing
-(IBAction)passedByButtonTapped:(UIButton *)sender
{
    NSLog(@"Passed By Button Tapped!");
    [self.passedByButton setHidden:YES];
    [self.aggressivePassButton setHidden:YES];
    [self.passivePassButton setHidden:YES];
    Stat* stat =self.play.stats[0];
    stat.details[@"Passed By"] = self.selectedPlayer;
}

-(IBAction)aggressivePassButtonTapped:(UIButton *)sender
{
    NSLog(@"Aggressive PassButton Tapped!");
    [self.passedByButton setHidden:YES];
    [self.aggressivePassButton setHidden:YES];
    [self.passivePassButton setHidden:YES];
    Stat* stat =self.play.stats[0];
    stat.details[@"Passed By"] = self.selectedPlayer;
    stat.details[@"Pass Aggression"] = @"Aggressive";
}
-(IBAction)passivePassButtonTapped:(UIButton *)sender
{
    NSLog(@"Passive Pass Button Tapped!");
    [self.passedByButton setHidden:YES];
    [self.aggressivePassButton setHidden:YES];
    [self.passivePassButton setHidden:YES];
    Stat* stat =self.play.stats[0];
    stat.details[@"Passed By"] = self.selectedPlayer;
    stat.details[@"Pass Aggression"] = @"Passive";
}
//digging
-(IBAction)digErrorButtonTapped:(UIButton *)sender
{
    NSLog(@"Dig Error Button Tapped!");
    Stat* stat =self.play.stats[0];
    stat.details[@"Dig By"] = self.selectedPlayer;
    stat.details[@"Dig Quality"] = @"Dig Error";
}
-(IBAction)digButtonTapped:(UIButton *)sender
{
    NSLog(@"Dig Button Tapped!");
    Stat* stat =self.play.stats[0];
    stat.details[@"Dig By"] = self.selectedPlayer;
    stat.details[@"Dig Quality"] = @"Dig";
}
-(IBAction)upButtonTapped:(UIButton *)sender
{
    NSLog(@"Up Button Tapped!");
    Stat* stat =self.play.stats[0];
    stat.details[@"Dig By"] = self.selectedPlayer;
    stat.details[@"Dig Quality"] = @"Up";
}
//covering
-(IBAction)coverErrorButtonTapped:(UIButton *)sender
{
    NSLog(@"Cover Error Button Tapped!");
    Stat* stat =self.play.stats[0];
    stat.details[@"Covered By"] = self.selectedPlayer;
    stat.details[@"Cover Quality"] = @" Cover Error";
}
-(IBAction)coverDigButtonTapped:(UIButton *)sender
{
    NSLog(@"Cover Dig Button Tapped!");
    Stat* stat =self.play.stats[0];
    stat.details[@"Covered By"] = self.selectedPlayer;
    stat.details[@"Cover Quality"] = @"Cover";
}
-(IBAction)coverUpButtonTapped:(UIButton *)sender
{
    NSLog(@"Cover Up Button Tapped!");
    Stat* stat =self.play.stats[0];
    stat.details[@"Covered By"] = self.selectedPlayer;
    stat.details[@"Cover Quality"] = @"Cover Up";
}
-(IBAction)gameButtonTapped:(UIButton *)sender
{
    NSLog(@"Game Button Tapped!");
    [_gameButton1 setHidden:NO];
    [_gameButton2 setHidden:NO];
    [_gameButton3 setHidden:NO];
    [_gameButton4 setHidden:NO];
    [_gameButton5 setHidden:NO];
}
-(IBAction)gameButton1Tapped:(UIButton *)sender
{
    self.currentGame = 1;
    NSLog(@"Game Button 1 Tapped!");
    [_gameButton1 setHidden:YES];
    [_gameButton2 setHidden:YES];
    [_gameButton3 setHidden:YES];
    [_gameButton4 setHidden:YES];
    [_gameButton5 setHidden:YES];
}
-(IBAction)gameButton2Tapped:(UIButton *)sender
{
    self.currentGame = 2;
    NSLog(@"Game Button 2 Tapped!");
    [_gameButton1 setHidden:YES];
    [_gameButton2 setHidden:YES];
    [_gameButton3 setHidden:YES];
    [_gameButton4 setHidden:YES];
    [_gameButton5 setHidden:YES];
}
-(IBAction)gameButton3Tapped:(UIButton *)sender
{
    self.currentGame = 3;
    NSLog(@"Game Button 3 Tapped!");
    [_gameButton1 setHidden:YES];
    [_gameButton2 setHidden:YES];
    [_gameButton3 setHidden:YES];
    [_gameButton4 setHidden:YES];
    [_gameButton5 setHidden:YES];
}
-(IBAction)gameButton4Tapped:(UIButton *)sender
{
    self.currentGame = 4;
    NSLog(@"Game Button 4 Tapped!");
    [_gameButton1 setHidden:YES];
    [_gameButton2 setHidden:YES];
    [_gameButton3 setHidden:YES];
    [_gameButton4 setHidden:YES];
    [_gameButton5 setHidden:YES];
}

-(IBAction)gameButton5Tapped:(UIButton *)sender
{
    self.currentGame = 5;
    NSLog(@"Game Button 5 Tapped!");
    [_gameButton1 setHidden:YES];
    [_gameButton2 setHidden:YES];
    [_gameButton3 setHidden:YES];
    [_gameButton4 setHidden:YES];
    [_gameButton5 setHidden:YES];
}

//end ibaction section




-(void)addResultForStat:(Stat *)stat {
    [self.handsButton setHidden:YES];
    [self.noHandsButton setHidden:YES];
    [self.toughServeButton setHidden:YES];
    [self.passiveServeButton setHidden:YES];
    [self.passedByButton setHidden:YES];
    [self.aggressivePassButton setHidden:YES];
    [self.passivePassButton setHidden:YES];
    [self.goodBlockTouchButton setHidden:YES];
    [self.badBlockTouchButton setHidden:YES];
     
    if (stat.skill == kSkillServe) {
        self.addResultButtons.buttonTitles = @[@"ace", @"0", @"1", @"2", @"3", @"4", @"err", @"Overpass"];
    }
    else {
        self.addResultButtons.buttonTitles = @[@"kill", @"error", @"us", @"them"];
    }
    self.addResultView.hidden = NO;
    
    [self.addResultButtons once:@"button-pressed" callback:^(NSString* result) {
        stat.details[@"result"] = result;
        stat.player = self.selectedPlayer;
        self.addResultView.hidden = YES;
        [self emit:@"play-added" data:self.play];
        [self emit:@"stat-added" data:stat];
        
        NSLog(@"testing");
    }];
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
