//
//  FullScreenChoiceViewController.h
//  ipad-stats2
//
//  Created by Jim Grandpre on 4/23/13.
//  Copyright (c) 2013 RIPP Volleyball. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FullScreenChoiceViewController : UIViewController
- (id)initWithChoices:(NSArray*)choices choose:(void (^)(int)) choose;
    
@end
