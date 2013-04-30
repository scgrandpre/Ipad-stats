//
//  DrawingView.h
//  ipad-stats2
//
//  Created by Jim Grandpre on 4/23/13.
//  Copyright (c) 2013 RIPP Volleyball. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DrawingView : UIView
- (id)initWithFrame:(CGRect)frame choose:(void (^)(NSArray*))choose;
@end
