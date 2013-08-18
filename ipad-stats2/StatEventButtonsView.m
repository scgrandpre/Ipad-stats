//
//  StatEventButtonsView.m
//  ipad-stats2
//
//  Created by Scott Grandpre on 7/8/13.
//  Copyright (c) 2013 RIPP Volleyball. All rights reserved.
//

#import "StatEventButtonsView.h"
#import <EventEmitter/EventEmitter.h>

static const CGFloat MAX_BUTTON_WIDTH = 150;
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
        CGFloat buttonWidth = MIN(self.bounds.size.width/([titles count]) - BUTTON_PADDING, MAX_BUTTON_WIDTH);
        for (int i = 0; i < [titles count]; i++) {
            UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
            button.frame = CGRectMake((BUTTON_PADDING + buttonWidth) * i, 0, buttonWidth, self.bounds.size.height);
            [button setTitle:titles[i] forState:UIControlStateNormal];
            [self addSubview:button];
            [button addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
        }
    }
    _buttonTitles = titles;
}

- (void) buttonPressed:(UIButton*)button {
    NSLog(@"%@", button.titleLabel.text);
    [self emit:@"button-pressed" data:button.titleLabel.text];
}

@end
