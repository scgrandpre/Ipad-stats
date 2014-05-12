//
//  StatFilterView.m
//  ipad-stats2
//
//  Created by Scott Grandpre on 5/9/14.
//  Copyright (c) 2014 RIPP Volleyball. All rights reserved.
//

#import "StatFilterView.h"
#import <EventEmitter/EventEmitter.h>
#import "StatEventButtonsView.h"

static NSInteger kPlayerComponent = 0;
static NSInteger kSkillComponent = 1;

@interface StatFilterView ()

@property(readonly) UIPickerView *picker;
@property(readonly) NSArray *skills;

@end

@implementation StatFilterView
@synthesize picker = _picker;
@synthesize stats = _stats;
@synthesize filteredStats = _filteredStats;
@synthesize skills = _skills;

- (void)layoutSubviews {
  self.picker.frame = CGRectMake(self.bounds.origin.x, self.bounds.origin.y,
                                 200, self.bounds.size.height);
}

- (NSArray *)skills {
  if (_skills == nil) {
    _skills = @[ @"Hit", @"Serve" ];
  }
  return _skills;
}

- (UIPickerView *)picker {
  if (_picker == nil) {
    _picker = [[UIPickerView alloc] init];
    _picker.delegate = self;
    _picker.dataSource = self;
    [self addSubview:_picker];
  }
  return _picker;
}

- (NSArray *)stats {
  return _stats;
}

- (void)setStats:(NSArray *)stats {
  _stats = stats;
  [_picker reloadAllComponents];
  [self recomputeFilteredStats];
}

- (void)recomputeFilteredStats {
  NSMutableDictionary *filter = [@{} mutableCopy];
  NSInteger player = [self.picker selectedRowInComponent:0];
  if (player != 0) {
    filter[@"player"] = [self players][player - 1];
  }

  NSInteger skill = [self.picker selectedRowInComponent:1];
  if (skill != 0) {
    filter[@"skill"] = self.skills[skill - 1];
  }

  _filteredStats = [Stat filterStats:self.stats withFilters:filter];
  [self emit:@"filtered-stats" data:_filteredStats];
}

- (NSArray *)players {
  NSMutableDictionary *players = [[NSMutableDictionary alloc] init];
  for (Stat *stat in self.stats) {
    players[stat.player] = stat.player;
  }
  return [players
      keysSortedByValueUsingComparator:^NSComparisonResult(NSString *obj1,
                                                           NSString *obj2) {
        return [obj1 integerValue] > [obj2 integerValue];
      }];
}

- (NSInteger)pickerView:(UIPickerView *)pickerView
    numberOfRowsInComponent:(NSInteger)component {
  if (component == kPlayerComponent) {
    return [[self players] count] + 1;
  } else if (component == kSkillComponent) {
    return [[self skills] count] + 1;
  } else {
    return 0;
  }
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
  return 2;
}

- (NSString *)pickerView:(UIPickerView *)pickerView
             titleForRow:(NSInteger)row
            forComponent:(NSInteger)component {
  if (row == 0) {
    return @"ALL";
  }
  if (component == kPlayerComponent) {
    return [self players][row - 1];
  } else if (component == kSkillComponent) {
    return [self skills][row - 1];
  } else {
    return @"";
  }
}

- (void)pickerView:(UIPickerView *)pickerView
      didSelectRow:(NSInteger)row
       inComponent:(NSInteger)component {
  [self recomputeFilteredStats];
}

@end
