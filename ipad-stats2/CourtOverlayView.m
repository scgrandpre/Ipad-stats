//
//  CourtOverlayView.m
//  ipad-stats2
//
//  Created by Jim Grandpre on 4/11/13.
//  Copyright (c) 2013 RIPP Volleyball. All rights reserved.
//


/*
 GAME = [PLAYS]
 PLAY = [EVENTS], WINNER
 EVENT = HIT | PASS | SERVE | DIG | BLOCK
 HIT = PLAYER, HANDS, BLOCKERS RESULT
 */

#import "CourtOverlayView.h"
#import "FancyMultipleButtonsView.h"
#import "EventEmitter.h"

@interface CourtOverlayView ()
@property NSMutableDictionary* playerButtons;
@property FancyMultipleButtonsView *activeButton;
@property NSDictionary *skills;
@property NSMutableDictionary* players;
@property NSMutableDictionary *rotation;
@property NSMutableArray *currentPlay;
@end

@implementation CourtOverlayView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.skills = @{
                         @"HIT": @[
                                 @{@"LABEL": @"BLOCKERS", @"OPTIONS": @[@"0", @"1", @"2", @"3"]},
                                 @{@"LABEL": @"HANDS", @"OPTIONS": @[@"HANDS", @"NO HANDS"]},
                                 @{@"LABEL": @"RESULT", @"OPTIONS": @[@"KILL", @"ERROR", @"US", @"THEM"]},
                                 ],
                         @"SERVE": @[
                                 @{@"LABEL": @"TYPE", @"OPTIONS": @[@"STANDING FLOAT", @"JUMP FLOAT", @"TOPSPIN"]},
                                 @{@"LABEL": @"RESULT", @"OPTIONS": @[@"ACE", @"ERROR", @"0", @"1", @"2", @"3", @"4"]},
                                 ],
                         @"PASS": @[
                                 @{@"LABEL": @"SIDE", @"OPTIONS": @[@"L", @"FL", @"F", @"FR", @"R", @"BR", @"B", @"BL"]},
                                 @{@"LABEL": @"PLATFORM", @"OPTIONS": @[@"HANDS", @"ARMS"]},
                                 ],
                         @"DIG": @[
                                 @{@"LABEL": @"SIDE", @"OPTIONS": @[@"L", @"FL", @"F", @"FR", @"R", @"BR", @"B", @"BL"]},
                                 @{@"LABEL": @"PLATFORM", @"OPTIONS": @[@"HANDS", @"ARMS"]},
                                 @{@"LABEL": @"RESULT", @"OPTIONS": @[@"ERROR", @"0", @"1", @"2", @"3", @"4"]},
                                 ],
                         @"BLOCK":@[],
                         };
        
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
        self.playerButtons = [[NSMutableDictionary alloc] initWithDictionary:@{
                              @"0": [[NSMutableArray alloc] init],
                              @"1": [[NSMutableArray alloc] init]}];
        self.players = [[NSMutableDictionary alloc] initWithDictionary: @{
                        @"0": [[NSMutableArray alloc] initWithArray:@[@0,@1,@2,@3,@4,@5]],
                        @"1": [[NSMutableArray alloc] initWithArray:@[@10,@11,@12,@13,@14,@15]]}];
        self.rotation = [[NSMutableDictionary alloc] initWithDictionary:@{@"0": @0, @"1": @3}];
        
        self.currentPlay = nil;
        
        [self makeFrontRowPlayers];
        [self makeBackRowPlayers];
    }
    return self;
}

- (void)hidePlayers {
    [self forEachPlayer:^(FancyMultipleButtonsView *player) {
        player.hidden = YES;
    }];
}

- (void)showPlayers {
    [self forEachPlayer:^(FancyMultipleButtonsView *player) {
        player.hidden = NO;
    }];
}

- (void)endPlayWithWinner:(NSString*)winner {
    if(self.currentPlay != nil) {
        NSDictionary *play = @{
                               @"winner": winner,
                               @"events": self.currentPlay
                               };
        [self emit:@"end_play" data:play];
    }
}

- (void)gatherDetailsWithSkill:(NSString*)skill player:(NSString*)player team:(NSString*)team info:(NSMutableDictionary*)info center:(CGPoint) center {
    if (info.count == [self.skills[skill] count]) {
        [self showPlayers];
        
        if([skill compare: @"SERVE"] == NSOrderedSame) {
            self.currentPlay = [[NSMutableArray alloc] init];
        }
        
        [self.currentPlay addObject:@{@"skill": skill, @"details": info}];
        NSString* result = info[@"RESULT"];
        if(result) {
            if([result compare: @"KILL"] == NSOrderedSame || [result compare:@"ACE"] == NSOrderedSame) {
                [self endPlayWithWinner:team];
            } else if([result compare:@"ERROR"] == NSOrderedSame){
                if([team compare: @"0"] == NSOrderedSame) {
                    [self endPlayWithWinner:@"1"];
                } else {
                    [self endPlayWithWinner:@"0"];
                }
            }
        }
    } else {
        __weak CourtOverlayView *this = self;
        
        NSDictionary* nextInfo = self.skills[skill][info.count];
        FancyMultipleButtonsView *newMenu = [[FancyMultipleButtonsView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width/8,self.bounds.size.height/5) label:[nextInfo objectForKey:@"LABEL"] options:nextInfo[@"OPTIONS"] choose:^(int selection, UITouch* touch) {
            
            info[[nextInfo objectForKey:@"LABEL"]] = [nextInfo objectForKey:@"OPTIONS"][selection];
            [this.activeButton removeFromSuperview];
            this.activeButton = NULL;
            CGPoint touchLocation = [touch locationInView:this];
            CGPoint v = CGPointMake(touchLocation.x - center.x, touchLocation.y - center.y);
            
            float f = 50/sqrt(v.x * v.x + v.y * v.y);
            CGPoint newCenter = CGPointMake(center.x + v.x*f , center.y + v.y*f);
            [this gatherDetailsWithSkill:skill player:player team:team info:info center:newCenter];
        }];
        newMenu.center = center;
        [self addSubview:newMenu];
        self.activeButton = newMenu;
    }
}

- (void)addPlayerWithX:(int)xPosition Y:(int)yPosition label:(NSString*)label options:(NSArray*)options team:(NSString*)team {
    __weak CourtOverlayView *this = self;
    FancyMultipleButtonsView *menu = [[FancyMultipleButtonsView alloc] initWithFrame:CGRectMake(xPosition, yPosition, self.bounds.size.width/8,self.bounds.size.height/5) label:label options:options choose:^(int selection, UITouch* touch) {
        [this hidePlayers];
        NSString *skill = options[selection];
        [this gatherDetailsWithSkill:skill player:label team:team info:[[NSMutableDictionary alloc] init] center:[touch locationInView:this]];
    }];
    [self addSubview:menu];
    [self.playerButtons[team] addObject:menu];
}

- (void)makeFrontRowPlayers {
    NSArray *options = @[@"BLOCK", @"HIT", @"DIG", @"PASS", ];
    CGFloat xPosition = self.bounds.origin.x + self.bounds.size.width*3/8;
    for(int y=0; y < 3; y++) {
        CGFloat yPosition = self.bounds.origin.y + self.bounds.size.height * (1/5.f + y/5.f);
        [self addPlayerWithX:xPosition Y:yPosition label:[NSString stringWithFormat:@"%@", self.players[@"0"][y]] options:options team:@"0"];
        [self addPlayerWithX:(self.bounds.size.width - xPosition - self.bounds.size.width/8) Y:yPosition label:[NSString stringWithFormat:@"%@", self.players[@"1"][y]] options:options team:@"1"];
    }
}


- (void)makeBackRowPlayers {
    NSArray *options = @[@"SERVE", @"HIT", @"DIG", @"PASS"];
    CGFloat xPosition = self.bounds.origin.x + self.bounds.size.width*1.5/8;
    for(int y=0; y < 3; y++) {
        CGFloat yPosition = self.bounds.origin.y + self.bounds.size.height * (1/5.f + y/5.f);
        [self addPlayerWithX:xPosition Y:yPosition label:[NSString stringWithFormat:@"%@", self.players[@"0"][y + 3]] options:options team:@"0"];
        [self addPlayerWithX:(self.bounds.size.width - xPosition - self.bounds.size.width/8) Y:yPosition label:[NSString stringWithFormat:@"%@", self.players[@"1"][y + 3]] options:options team:@"1"];
    }
}

- (void)forEachPlayer: (void (^)(FancyMultipleButtonsView*)) each {
    for(NSString* team in @[@"0", @"1"]) {
        for (FancyMultipleButtonsView* button in self.playerButtons[team]) {
            each(button);
        }
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = touches.anyObject;
    if(self.activeButton) {
        [self.activeButton processTouch:touch];
    } else {
        [self forEachPlayer:^(FancyMultipleButtonsView* button) {
            [button processTouch:touch];
        }];
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = touches.anyObject;
    if(self.activeButton) {
        [self.activeButton processTouch:touch];
    } else {
        [self forEachPlayer:^(FancyMultipleButtonsView* button) {
            [button processTouch:touch];
        }];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = touches.anyObject;
    if(self.activeButton) {
        [self.activeButton processTouch:touch];
        [self.activeButton select];
    } else {
        [self forEachPlayer:^(FancyMultipleButtonsView* button) {
            [button processTouch:touch];
            [button select];
        }];
    }
}

- (void)relabelPlayers {
    for(NSString *team in @[@"0", @"1"]) {
        int rotation = [self.rotation[team] intValue];
        for(int i=0; i < [self.playerButtons[team] count]; i++) {
            int idx = ((rotation + i) % 6)/3;
            [self.playerButtons[team][i] setLabel:[NSString stringWithFormat:@"%@", self.players[team][(idx * 3 + (i%3)) % [self.players[team] count]]]];
            [self.playerButtons[team][i] setNeedsDisplay];
        }
        
    }
}

- (void)rotateWithTeam:(NSString*)team increment:(int)increment {
    self.rotation[team] = [NSNumber numberWithInt:[self.rotation[team] intValue] + increment];
    [self relabelPlayers];
}

@end
