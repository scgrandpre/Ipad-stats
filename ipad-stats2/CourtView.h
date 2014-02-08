//
//  CourtView.h
//  ipad-stats
//
//  Created by Jim Grandpre on 4/11/13.
//  Copyright (c) 2013 RIPP Volleyball. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CourtView : UIView

- (void)rotateTeam:(int)team;
- (void)unrotateTeam:(int)team;
- (void)subPlayer:(NSString*)player;

- (CGRect)courtRect;
@end
