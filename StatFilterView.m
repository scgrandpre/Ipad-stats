//
//  StatFilterView.m
//  ipad-stats2
//
//  Created by Scott Grandpre on 5/9/14.
//  Copyright (c) 2014 RIPP Volleyball. All rights reserved.
//

#import "StatFilterView.h"
#import <EventEmitter/EventEmitter.h>

@interface StatFilterView ()

@property (readonly) UIPickerView *picker;


@end

@implementation StatFilterView
@synthesize picker = _picker;
@synthesize stats = _stats;
@synthesize filteredStats = _filteredStats;

- (void)layoutSubviews {
    self.picker.frame = self.bounds;
}

- (UIPickerView *)picker {
    if(_picker == nil) {
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
}

- (void)recomputeFilteredStats {
    NSMutableDictionary *filter = [@{} mutableCopy];
    NSInteger player = [self.picker selectedRowInComponent:0];
    if (player != 0) {
        filter[@"player"] = [self players][player];
    }
    
    _filteredStats = [Stat filterStats:self.stats withFilters:filter];
    [self emit:@"filtered-stats" data:_filteredStats];
}

- (NSArray*)players {
    NSMutableDictionary *players = [[NSMutableDictionary alloc] init];
    for (Stat *stat in self.stats) {
        players[stat.player] = stat.player;
    }
    return [players keysSortedByValueUsingSelector:@selector(integerValue)];
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return [[self players] count] + 1;
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    if (row == 0) {
        return @"ALL";
    }
    return [self players][row - 1];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    [self recomputeFilteredStats];
}

@end
