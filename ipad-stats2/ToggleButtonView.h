//
//  ToggleButtonView.h
//  ipad-stats2
//
//  Created by Scott Grandpre on 7/24/13.
//  Copyright (c) 2013 RIPP Volleyball. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ToggleButtonView : UIView

@property NSArray* buttonTitles;
@property NSString* currentSelection;
@property NSMutableArray* buttons;

-(id) initWithFrame: (CGRect) frame buttonTitles:(NSArray*)titles currentSelection:(NSString*)selection;

@end
