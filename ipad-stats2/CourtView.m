//
//  CourtView.m
//  ipad-stats
//
//  Created by Jim Grandpre on 4/11/13.
//  Copyright (c) 2013 RIPP Volleyball. All rights reserved.
//

#import "CourtView.h"
#import "DrawingView.h"
#import <EventEmitter.h>
#import "Play.h"

static float PADDING_RATIO = 1/8.f;

@interface CourtView ()
@property bool showPlayers;
@property NSArray *players;

@property (readonly) int* rotation;
@property int selectedPlayer; //Hash of team, position, front

@end

@implementation CourtView
@synthesize selectedPlayer = _selectedPlayer;

int _rotation[2];
- (int *)rotation {
    return _rotation;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        _showPlayers = YES;
        NSMutableArray *players = [[NSMutableArray alloc] initWithArray:@[@"OH0", @"L", @"S", @"OH1", @"MH0",@"RS"]];
        NSMutableArray *otherPlayers = [[NSMutableArray alloc] initWithArray:players];
        _players = @[players, otherPlayers];
        _selectedPlayer = -1;
        
        DrawingView *drawingView = [[DrawingView alloc] initWithFrame:self.bounds];
        [self addSubview:drawingView];
        
        [drawingView on:@"drew-line" callback:^(NSArray* line) {
            if ([line count] > 4) {
                NSMutableArray *normalized = [[NSMutableArray alloc] init];

                
                for (NSValue *pointValue in line) {
                    CGPoint point = [pointValue CGPointValue];
                    
                    point.x = (point.x*2 - 1) / (1 - 2*PADDING_RATIO);
                    point.y = (point.y - .5) / (1 - 2*PADDING_RATIO);
                    
                    [normalized addObject:[NSValue valueWithCGPoint:point]];
                }
                
                
                [self emit:@"drew-line" data:@{
                    @"line": normalized,
                    @"player": [self selectedPlayerForHash:self.selectedPlayer]
                 }];
                 self.selectedPlayer = -1;
            } else {
                CGPoint point = [line[0] CGPointValue];
                point.x = self.bounds.size.width * point.x;
                point.y = self.bounds.size.height * point.y;
                [self selectPlayerAtPoint: point];
            }
        }];
    }
    return self;
}

- (int)selectedPlayer {
    return _selectedPlayer;
}

- (void)setSelectedPlayer:(int)selectedPlayer {
    _selectedPlayer = selectedPlayer;
    [self setNeedsDisplay];
}

- (void)rotateTeam:(int)team {
    self.rotation[team]++;
    self.rotation[team] %= 6;
    [self setNeedsDisplay];
}

- (void)unrotateTeam:(int)team {
    self.rotation[team]--;
    self.rotation[team] = (self.rotation[team] + 6) % 6;
    [self setNeedsDisplay];
}

- (int) offsetForTeam:(int)team position:(int)position front:(int)front {
    int pos = position;
    if (!front && position < 2) {
        pos = 1 - pos;
    }
    int offset = 3 * (self.rotation[team]/3) + pos;
    if (self.rotation[team] % 3 > pos) {
        offset += 3;
    }
    offset += 3 * front;
    return offset % 6;
}

- (NSString*) playerForTeam:(int)team position:(int)position front:(int)front {
    int offset = [self offsetForTeam:team position:position front:front];
    return self.players[team][offset];
}

- (int) hashPositionWithTeam:(int)team position:(int)position front:(int)front {
    return (position<<1 | team)<<1 | front;
}
    
- (void) unpackPlayerHash:(int)hash team:(int*)team position:(int*)position front:(int*)front {
    *front = hash & 1;
    *team = (hash >> 1) & 1;
    *position = hash >> 2;
}

- (NSString*) selectedPlayerForHash:(int)hash {
    if (self.selectedPlayer >= 0) {
        int front, team, position;
        [self unpackPlayerHash:hash team:&team position:&position front:&front];
        return [self playerForTeam:team position:position front:front];
    } else {
        return @"nobody";
    }
}

- (void)drawRect:(CGRect)rect {
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    float width = self.bounds.size.width;
    float height = self.bounds.size.height;
    CGContextSetStrokeColorWithColor(ctx, [UIColor blackColor].CGColor);
    CGContextSetLineWidth(ctx, 4);
    
    CGFloat left   =          PADDING_RATIO * width;
    CGFloat top    =          PADDING_RATIO * height;
    CGFloat right  = width -  PADDING_RATIO * width;
    CGFloat bottom = height - PADDING_RATIO * height;
    
    // BORDER
    CGContextBeginPath(ctx);
    CGContextMoveToPoint(   ctx, left,  top);
    CGContextAddLineToPoint(ctx, left,  bottom);
    CGContextAddLineToPoint(ctx, right, bottom);
    CGContextAddLineToPoint(ctx, right, top);
    CGContextClosePath(ctx);
    
    // NET
    CGFloat net_x = (left + right)/2;
    CGContextMoveToPoint(   ctx, net_x, top);
    CGContextAddLineToPoint(ctx, net_x, bottom);
    
    // 10 FT Lines
    CGContextMoveToPoint(   ctx, left +   (right - left)/3.f,  top);
    CGContextAddLineToPoint(ctx, left +   (right - left)/3.f,  bottom);
    CGContextMoveToPoint(   ctx, left + 2*(right - left)/3.f,  top);
    CGContextAddLineToPoint(ctx, left + 2*(right - left)/3.f,  bottom);
    CGContextStrokePath(ctx);
    
    // Players
    if(self.showPlayers) {
        CGContextSetStrokeColorWithColor(ctx, [UIColor colorWithWhite:.6 alpha:1].CGColor);
        CGContextSetFillColorWithColor(ctx, [UIColor colorWithWhite:.6 alpha:1].CGColor);
        
        CGContextSetLineWidth(ctx, 1);
        CGFloat dashes[] = {10,10};
        
        CGContextSetLineDash(ctx, 0.0, dashes, 2);
        // Player Dividers
        CGContextMoveToPoint(   ctx, left,  top + (bottom - top)/3.f);
        CGContextAddLineToPoint(ctx, right, top + (bottom - top)/3.f);
        CGContextMoveToPoint(   ctx, left,  top + (bottom - top)*2.f/3.f);
        CGContextAddLineToPoint(ctx, right, top + (bottom - top)*2.f/3.f);
        
        CGContextMoveToPoint(   ctx, left + (right-left)/4, top);
        CGContextAddLineToPoint(ctx, left + (right-left)/4, bottom);
        CGContextMoveToPoint(   ctx, left + (right-left)*3.f/4.f, top);
        CGContextAddLineToPoint(ctx, left + (right-left)*3.f/4.f, bottom);
        
        for(int team = 0; team < 2; team++) {
            for(int front = 0; front < 2; front++) {
                for(int position = 0; position < 3; position++) {
                    NSString *player = [self playerForTeam:team position:position front:front];
                    
                    if ([self hashPositionWithTeam:team position:position front:front] == self.selectedPlayer) {
                        CGContextSetStrokeColorWithColor(ctx, [UIColor greenColor].CGColor);
                        CGContextSetFillColorWithColor(ctx, [UIColor greenColor].CGColor);
                    } else {
                        CGContextSetStrokeColorWithColor(ctx, [UIColor colorWithWhite:.6 alpha:1].CGColor);
                        CGContextSetFillColorWithColor(ctx, [UIColor colorWithWhite:.6 alpha:1].CGColor);
                    }
                    CGFloat x = (team * 2 - 1) * ((1 - front)*.5 + .5 - team * .5);
                    CGFloat y = team - (team*2 - 1)*position/3.f - team * 1.f/3.f;
                    [player drawAtPoint:CGPointMake(left + (right - left) * (x + 1)/2, top + (bottom - top) * y) withFont:[UIFont boldSystemFontOfSize:36.0f]];
                    
                }
            }
        
        }
        
        
        CGContextStrokePath(ctx);
    }
}

- (void)selectPlayerAtPoint:(CGPoint)location {
    float width = self.bounds.size.width;
    float height = self.bounds.size.height;
    
    CGFloat left   =          PADDING_RATIO * width;
    CGFloat top    =          PADDING_RATIO * height;
    CGFloat right  = width -  PADDING_RATIO * width;
    CGFloat bottom = height - PADDING_RATIO * height;
    
    CGFloat x = ((location.x - left) / (right - left)) * 2 - 1;
    CGFloat y = (location.y - top) / (bottom - top);
    
    int team = 1;
    if (x < 0) {
        team = 0;
        x = -x;
    } else {
        y = 1 - y;
    }
    
    int front = 1 - ((int)(x/.5));
    int position = y*3;
    self.selectedPlayer = [self hashPositionWithTeam:team position:position front:front];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = touches.anyObject;
    if (self.selectedPlayer == -1) {
        [self selectPlayerAtPoint:[touch locationInView:self]];
    }
}

- (void)subPlayer:(NSString*)player {
    if (self.selectedPlayer != -1) {
        int front, team, position;
        [self unpackPlayerHash:self.selectedPlayer team:&team position:&position front:&front];
        int offset = [self offsetForTeam:team position:position front:front];
        
        self.players[team][offset] = player;
        [self setNeedsDisplay];
    }
}


@end
