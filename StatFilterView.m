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

static NSInteger kTeamComponent = 0;
static NSInteger kPlayerComponent = 1;
static NSInteger kSkillComponent = 2;
static NSInteger kResultComponent = 3;

static NSInteger kGameComponent = 0;
static NSInteger kRotationComponent = 1;




@interface StatFilterView ()

@property(readonly) UIPickerView *picker;
@property(readonly) UIPickerView *gamePicker;

@property(readonly) NSArray *skills;
@property(readonly) NSArray *resultHit;
@property(readonly) NSArray *resultServe;
@property(readonly) NSArray *team;

@property(readonly) NSArray *game;
@property(readonly) NSArray *rotation;




@property NSMutableDictionary *filter;

@end

@implementation StatFilterView
@synthesize picker = _picker;
@synthesize gamePicker = _gamePicker;
@synthesize stats = _stats;
@synthesize filteredStats = _filteredStats;
@synthesize skills = _skills;
@synthesize resultHit = _resultHit;
@synthesize resultServe = _resultServe;
@synthesize team = _team;
@synthesize game = _game;
@synthesize rotation = _rotation;
- (void)layoutSubviews {
  self.picker.frame = CGRectMake(self.bounds.origin.x, self.bounds.origin.y,
                                 300, self.bounds.size.height);
    self.gamePicker.frame = CGRectMake(self.bounds.origin.x, self.bounds.origin.y+200,
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
        _resultServe = @[@"ace", @"0", @"1", @"2", @"3", @"4", @"err", @"Overpass"];
    }
    return _resultServe;
}

- (NSArray *)team {
    if (_team == nil) {
        _team = @[@"SHU",@"Other"];
    }
    return _team;
}
- (NSArray *)game {
    if (_game == nil) {
        _game = @[@"Game 1",@"Game 2",@"Game 3",@"Game 4",@"Game 5"];
    }
    return _game;
}
- (NSArray *)rotation {
    if (_rotation == nil) {
        _rotation = @[@"Rot 1",@"Rot 2",@"Rot 3",@"Rot 4",@"Rot 5",@"Rot 6"];
    }
    return _rotation;
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
- (UIPickerView *)gamePicker {
    if (_gamePicker == nil) {
        _gamePicker = [[UIPickerView alloc] init];
        _gamePicker.delegate = self;
        _gamePicker.dataSource = self;
        _gamePicker.backgroundColor = [UIColor clearColor];
        [self addSubview:_gamePicker];
    }
    return _gamePicker;
}


- (NSArray *)stats {
  return _stats;
}

- (void)setStats:(NSArray *)stats {
  _stats = stats;
  [_picker reloadAllComponents];
    [_gamePicker reloadAllComponents];
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
    NSInteger team = [self.picker selectedRowInComponent:kTeamComponent];
    if (team != 0) {
        filter[@"team"] = [self team][team- 1];
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
    
    NSInteger game = [self.gamePicker selectedRowInComponent:kGameComponent];
    if (game != 0) {
        filter[@"game"] = [self game][game- 1];
    }
    NSInteger rotation = [self.gamePicker selectedRowInComponent:kRotationComponent];
    if (rotation != 0) {
        filter[@"rotation"] = [self rotation][rotation- 1];
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
    if ([pickerView isEqual: self.picker]){
  if (component == kPlayerComponent) {
    return [[self players] count] + 1;
  } else if (component == kSkillComponent) {
    return [[self skills] count] + 1;
  } else if (component == kTeamComponent) {
      return [[self team] count] + 1;
  } else if (component == kResultComponent && [[self currentSkill]  isEqual: @"Hit"]) {
      return [[self resultHit] count] + 1;
  } else if (component == kResultComponent && [[self currentSkill] isEqual: @"Serve"]) {
      return [[self resultServe] count] + 1;
  }else {
    return 0;
  }
    }
    else if ([pickerView isEqual: self.gamePicker]){
        if (component == kGameComponent) {
            return [[self game] count] + 1;
        } else if (component == kRotationComponent) {
            return [[self rotation] count] + 1;
            
        } else {
            return 0;
        }
    }
    else{
        return 0;
    }
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    if ([pickerView isEqual:self.picker]){
        
        if (self.picker.numberOfComponents == 0){
            return 4;
        }else if ([[self currentSkill]  isEqual: @"Hit"] || [[self currentSkill]  isEqual: @"Serve"]){
            NSLog(@"should be 3:");
          return 4;
       }else {
        return 3;
        }
    }
    else if ([pickerView isEqual:self.gamePicker]){
        return 2;
    }else{
        return 0;
    }
}
        

- (NSString *)pickerView:(UIPickerView *)pickerView
             titleForRow:(NSInteger)row
            forComponent:(NSInteger)component {
  if (row == 0) {
    return @"ALL";
  }
  if ([pickerView isEqual:self.picker]){
        if (component == kPlayerComponent) {
        return [self players][row - 1];
      } else if (component == kSkillComponent) {
        return [self skills][row - 1];
      } else if (component == kTeamComponent) {
          return [self team][row - 1];
      } else if (component == kResultComponent && [[self currentSkill]  isEqual: @"Hit"]) {
          return [self resultHit][row - 1];
      } else if (component == kResultComponent && [[self currentSkill]  isEqual: @"Serve"]) {
          return [self resultServe][row - 1];
      } else {
        return @"";
      }
}
    else if (row == 0) {
        return @"Match";
    }else if (component == kGameComponent) {
        return [self game][row - 1];
    } else if (component == kRotationComponent) {
        return [self rotation][row - 1];
    } else {
        return @"";
    }

    
}

- (NSString *)gamePickerView:(UIPickerView *)pickerView
             titleForRow:(NSInteger)row
            forComponent:(NSInteger)component {
    if (row == 0) {
        return @"ALL";
    }else if (component == kGameComponent) {
            return [self game][row - 1];
        } else if (component == kRotationComponent) {
            return [self rotation][row - 1];
        } else {
            return @"";
        }
}

- (void)pickerView:(UIPickerView *)pickerView
      didSelectRow:(NSInteger)row
       inComponent:(NSInteger)component {
  [self recomputeFilteredStats];
    [self.picker reloadAllComponents];
    [self.gamePicker reloadAllComponents];
    
}

@end
