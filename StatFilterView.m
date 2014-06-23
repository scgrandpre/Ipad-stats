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
static NSInteger kResultHitComponent = 2;
static NSInteger kResultServeComponent = 3;


@interface StatFilterView ()

@property(readonly) UIPickerView *picker;
@property(readonly) NSArray *skills;
@property(readonly) NSArray *resultHit;
@property(readonly) NSArray *resultServe;
@property NSMutableDictionary *filter;


@end

@implementation StatFilterView
@synthesize picker = _picker;
@synthesize stats = _stats;
@synthesize filteredStats = _filteredStats;
@synthesize skills = _skills;
@synthesize resultHit = _resultHit;
@synthesize resultServe = _resultServe;

- (void)layoutSubviews {
  self.picker.frame = CGRectMake(self.bounds.origin.x, self.bounds.origin.y,
                                 300, self.bounds.size.height);
}

- (NSArray *)skills {
  if (_skills == nil) {
    _skills = @[ @"Hit", @"Serve" ];
  }
  return _skills;
}


- (NSArray *)resultHit {
    if (_resultHit == nil) {
        _resultHit = @[ @"Kill", @"Error", @"Attempt" ];
    }
    return _resultHit;
}

- (NSArray *)resultServe {
    if (_resultServe == nil) {
        _resultServe = @[ @"0", @"1", @"2", @"3", @"4", @"ace", @"error" ];
    }
    return _resultServe;
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
    _filter = [@{} mutableCopy];
    NSInteger player = [self.picker selectedRowInComponent:0];
  if (player != 0) {
    _filter[@"player"] = [self players][player - 1];
  }

//currentSkill:(NSMutableDictionary) _filter);
    [self currentSkill:_filter];
    
//This is where current skill was, I need to call it here somehow to make the filter work


  _filteredStats = [Stat filterStats:self.stats withFilters:_filter];
  [self emit:@"filtered-stats" data:_filteredStats];
}
//current skill was made to determine what the current skill is.
-(NSString*)currentSkill:(NSMutableDictionary*)currentSkillDict {
    NSInteger skill = [self.picker selectedRowInComponent:1];
    if (skill != 0) {
        return _filter[@"skill"] = self.skills[skill - 1];
        NSLog(@"skill: %@",self.skills[skill - 1]);
    }else{
        return NULL;
    }
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
  } else if (component == kResultHitComponent) {
      return [[self resultHit] count] + 1;
  } else if (component == kResultServeComponent) {
      return [[self resultServe] count] + 1;
  } else {
    return 0;
  }
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
   // if ([self.filter objectForKey:@"skill"] == @"Hit"){
     //   return 3;
    //}else{
    return 2;
    //}
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
  } else if (component == kResultHitComponent) {
      return [self resultHit][row - 1];
  } else if (component == kResultServeComponent) {
      return [self resultServe][row - 1];
  } else {
    return @"";
  }
}

- (void)pickerView:(UIPickerView *)pickerView
      didSelectRow:(NSInteger)row
       inComponent:(NSInteger)component {
  [self recomputeFilteredStats];
    [self.picker reloadAllComponents];
}

@end
