//
//  StatEntryView.h
//  ipad-stats2
//
//  Created by Scott Grandpre on 5/30/13.
//  Copyright (c) 2013 RIPP Volleyball. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface StatEntryView : UIView
- (id)initWithFrame:(CGRect)frame;
//- (NSString*)nextStateForLine:(NSArray*)line;
@property NSMutableString* currentStateTest;
@property (strong) NSMutableDictionary* currentPlay;
@property NSArray* allPlayers;
//-(IBAction)toughButtonTapped:(UIButton*)sender;

@end
