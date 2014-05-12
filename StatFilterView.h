//
//  StatFilterView.h
//  ipad-stats2
//
//  Created by Scott Grandpre on 5/9/14.
//  Copyright (c) 2014 RIPP Volleyball. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Stat.h"

@interface StatFilterView : UIView<UIPickerViewDataSource, UIPickerViewDelegate>

@property NSArray *stats;
@property(readonly) NSArray *filteredStats;

@end
