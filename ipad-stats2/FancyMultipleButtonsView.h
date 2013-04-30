//
//  FancyMultipleButtonsView.h
//  ipad-stats2
//
//  Created by Jim Grandpre on 4/11/13.
//  Copyright (c) 2013 RIPP Volleyball. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FancyMultipleButtonsView : UIView
@property(strong) NSString* label;

- (id)initWithFrame:(CGRect)frame label:(NSString*)label options:(NSArray*)options choose:(void (^)(int, UITouch*)) choose;
- (void)select;
- (void)processTouch:(UITouch*) touch;
@end
