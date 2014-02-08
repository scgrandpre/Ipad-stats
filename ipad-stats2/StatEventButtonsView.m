//
//  StatEventButtonsView.m
//  ipad-stats2
//
//  Created by Scott Grandpre on 7/8/13.
//  Copyright (c) 2013 RIPP Volleyball. All rights reserved.
//

#import "StatEventButtonsView.h"
#import <EventEmitter/EventEmitter.h>

static const CGFloat MAX_BUTTON_WIDTH = 1500;
static const CGFloat BUTTON_PADDING = 10;

@implementation StatEventButtonsView
@synthesize buttonTitles = _buttonTitles;

- (NSArray*) buttonTitles {
    return _buttonTitles;
}

- (void) setButtonTitles:(NSArray*)titles {
    for (UIView *view in self.subviews){
        [view removeFromSuperview];
    }
    if (titles != nil) {
        CGFloat buttonWidth = MIN((self.bounds.size.width/([titles count]/2) - BUTTON_PADDING), MAX_BUTTON_WIDTH);
        for (int j = 0; j < [titles count]; j++) {
            int i = j % ([titles count]/2);
            CGFloat heightOffset = 0;
            if (j >= [titles count]/2) {
                heightOffset = self.bounds.size.height/2;
            }
            UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
            button.frame = CGRectMake((BUTTON_PADDING + buttonWidth) * i, heightOffset, buttonWidth, self.bounds.size.height/2 - BUTTON_PADDING/2);
            [button setTitle:titles[j] forState:UIControlStateNormal];
            [self addSubview:button];
            [button addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
        }
    }
    _buttonTitles = titles;
}

- (void) setSelectedButton:(NSString *)selectedButton {
    for (UIView *view in self.subviews) {
        UIButton *button = (UIButton*)view;
        if([button.titleLabel.text isEqualToString:selectedButton]) {
            [button setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
        } else {
            [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        }
    }
}

- (NSString *)selectedButton {
    return @"";
}

- (void) buttonPressed:(UIButton*)button {
    NSLog(@"%@", button.titleLabel.text);
    [self emit:@"button-pressed" data:button.titleLabel.text];
}

@end
