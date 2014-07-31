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
static NSInteger kResultComponent = 2;


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
        _resultHit = @[ @"kill", @"error", @"us", @"them" ];
    }
    return _resultHit;
}

- (NSArray *)resultServe {
    if (_resultServe == nil) {
        _resultServe = @[ @"ace", @"0", @"1", @"2", @"3", @"4", @"err", @"Overpass" ];
    }
    return _resultServe;
}

- (UIPickerView *)picker {
  if (_picker == nil) {
    _picker = [[UIPickerView alloc] init];
    _picker.delegate = self;
    _picker.dataSource = self;
    _picker.backgroundColor = [UIColor clearColor];
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
    NSInteger player = [self.picker selectedRowInComponent:kPlayerComponent];
  if (player != 0) {
    filter[@"player"] = [self players][player - 1];
      NSLog(@"selected player: %@",[self players][player - 1]);
  }
    NSInteger skill = [self.picker selectedRowInComponent:kSkillComponent];
    if (skill != 0) {
        filter[@"skill"] = [self skills][skill- 1];
            }
    NSInteger result = [self.picker selectedRowInComponent:kResultComponent];
    
    if (result != 0) {
        if (skill == 1) {
            if (result > self.resultHit.count){
                result = self.resultHit.count;
            }
                
            filter[@"details"]= @{@"result":self.resultHit[result - 1]} ;
        }
        else if (skill == 2){
            filter[@"details"]= @{@"result":self.resultServe[result - 1]} ;
        }
    }
   
    //@"details": @{@"result": ....}
  _filteredStats = [Stat filterStats:self.stats withFilters:filter];
  [self emit:@"filtered-stats" data:_filteredStats];
}
//current skill was made to determine what the current skill is.
-(NSString*)currentSkill {
    NSInteger skill = [self.picker selectedRowInComponent:kSkillComponent];
    if (skill != 0) {
        NSLog(@"skill: %@",self.skills[skill - 1]);
            return self.skills[skill - 1];
    }else{
        return nil;
        
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
  } else if (component == kResultComponent && [[self currentSkill]  isEqual: @"Hit"]) {
      return [[self resultHit] count] + 1;
  } else if (component == kResultComponent && [[self currentSkill] isEqual: @"Serve"]) {
      return [[self resultServe] count] + 1;
  } else {
    return 0;
  }
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    if (self.picker.numberOfComponents == 0){
        return 3;
    }else if ([[self currentSkill]  isEqual: @"Hit"] || [[self currentSkill]  isEqual: @"Serve"]){
        NSLog(@"should be 3:");
      return 3;
   }else {
    return 2;
    }
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
  } else if (component == kResultComponent && [[self currentSkill]  isEqual: @"Hit"]) {
      return [self resultHit][row - 1];
  } else if (component == kResultComponent && [[self currentSkill]  isEqual: @"Serve"]) {
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
