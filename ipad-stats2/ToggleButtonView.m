//
//  ToggleButtonView.m
//  ipad-stats2
//
//  Created ish by Scott Grandpre on 7/24/13.
//  Copyright (c) 2013 RIPP Volleyball. All rights reserved.
//

#import "ToggleButtonView.h"
#import <EventEmitter/EventEmitter.h>

static const CGFloat BUTTON_WIDTH = 150;
static const CGFloat BUTTON_PADDING = 10;



@implementation ToggleButtonView

@synthesize buttonTitles = _buttonTitles;




- (id) initWithFrame: (CGRect) frame buttonTitles:(NSArray*)titles currentSelection:(NSString*)selection{
    self = [super initWithFrame: frame];
    _currentSelection=selection;
    _buttons = [[NSMutableArray alloc] init];
    for (int i = 0; i < [titles count]; i++) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake((BUTTON_PADDING + BUTTON_WIDTH) * i, 0, BUTTON_WIDTH, self.bounds.size.height);
        [_buttons addObject: button];
        [button setTitle:titles[i] forState:UIControlStateNormal];
        [self addSubview:button];
        [button addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
        if ([selection isEqualToString:titles[i]]){
            button.backgroundColor = [UIColor blueColor];
        }
        
    }
    
    _buttonTitles = titles;
    return self;
}

- (void) buttonPressed:(UIButton*)button {
    NSLog(@"%@", button.titleLabel.text);
    for (UIButton *b in self.buttons){
        b.backgroundColor = [UIColor yellowColor];
    }
    button.backgroundColor = [UIColor blueColor];
    [self emit:@"button-pressed" data:button.titleLabel.text];
}

@end
