//
//  ScoreView.m
//  ipad-stats2
//
//  Created by Jim Grandpre on 4/25/13.
//  Copyright (c) 2013 RIPP Volleyball. All rights reserved.
//

#import "ScoreView.h"
@interface ScoreView ()
@property int score;
@property (strong) UIButton* incrementButton;
@property (strong) void (^didIncrement)();
@end

@implementation ScoreView
@synthesize score = _score;

- (void)setScore:(int)score {
    if (score >= 0) {
        _score = score;
        [self.incrementButton setTitle:[NSString stringWithFormat:@"%d",score] forState:UIControlStateNormal];
    }
}

-(int)score {
    return _score;
}

- (id)initWithFrame:(CGRect)frame flipped:(BOOL)flipped increment:(void (^)())didIncrement {
    self = [super initWithFrame:frame];
    if (self) {
        self.didIncrement = didIncrement;
        float width = self.bounds.size.width/3.f;
        float (^flip)(float, float) =  ^(float x, float w) {
            if(flipped) {
                NSLog(@"%f, %f, %f", x, w, self.bounds.size.width - x - w);
                return (float)(self.bounds.size.width - x - w);
            } else {
                return x;
            }
        };
        
        self.incrementButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        self.incrementButton.frame = CGRectMake(self.bounds.origin.x + flip(0, width*2), self.bounds.origin.y, width*2, self.bounds.size.height);
        self.incrementButton.titleLabel.font = [UIFont systemFontOfSize:32];
        [self addSubview: self.incrementButton];
        [self.incrementButton addTarget:self action:@selector(increment) forControlEvents:UIControlEventTouchUpInside];
        
        UIButton *decr = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        decr.frame = CGRectMake(flip(width*2, width), self.bounds.origin.y, width, self.bounds.size.height/2);
        decr.titleLabel.font = [UIFont systemFontOfSize:16];
        [decr setTitle:@"-1" forState:UIControlStateNormal];
        [self addSubview: decr];
        [decr addTarget:self action:@selector(decrement) forControlEvents:UIControlEventTouchUpInside];
        

        
        self.score = 0;
    }
    return self;
}

- (void)increment {
    self.score++;
    self.didIncrement();
}

- (void)decrement {
    self.score--;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
