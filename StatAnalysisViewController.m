//
//  StatAnalysisViewController.m
//  ipad-stats2
//
//  Created by Jim Grandpre on 4/25/13.
//  Copyright (c) 2013 RIPP Volleyball. All rights reserved.
//

#import "StatAnalysisViewController.h"
#import "Game.h"
#import "Play.h"
#import "Stat.h"
#import "StatFilterView.h"
#import "CourtView.h"
#import "AnalysisLinesView.h"
#import "StatEventButtonsView.h"
#import "StatEntryView.h"
#import "StatEventButtonsView.h"
#import "StatAnalysisVideoPlayer.h"
#import <EventEmitter/EventEmitter.h>
#import <MediaPlayer/MediaPlayer.h>

@interface StatAnalysisViewController ()
@property Game *game;

@property(readonly) UITextView *statsTextView;
@property(readonly) AnalysisLinesView *linesView;
@property(readonly) CourtView *courtView;
@property(readonly) UITextField *field;
@property(readonly) UITextView *offset;
@property(readonly) StatFilterView *filters;
@property(readonly) StatAnalysisVideoPlayer *videoPlayer;
@property(readonly) Stat* currentStat;
@property(readonly) StatEntryView *allPlayers;
@property(readonly) StatFilterView *filter;
//@property(readonly) NSMutableDictionary* statDict;
@end

@implementation StatAnalysisViewController
@synthesize statsTextView = _statsTextView;
@synthesize linesView = _linesView;
@synthesize courtView = _courtView;
@synthesize field = _field;
@synthesize offset = _offset;
@synthesize videoPlayer = _videoPlayer;
@synthesize filters = _filters;
@synthesize currentStat = _currentStat;
@synthesize allPlayers = _allPlayers;
@synthesize filter = _filter;


//@synthesize statDict = _statDict;

- (id)initWithGame:(Game *)game {
    self = [super init];
    self.game = game;
//    _statDict = [[NSMutableDictionary alloc]init];
    
    [game on:@"play-added"
    callback:^(id arg0) {
        [self updateStats];
        self.filters.stats = [[self game] allStats];
    }];
    
    return self;
}

- (void)loadView {
    [super loadView];
    [self.view addSubview:self.statsTextView];
    [self.view addSubview:self.field];
    [self.view addSubview:self.offset];
    [self.view addSubview:self.filters];
    [self.view addSubview:self.courtView];
    [self.view addSubview:self.videoPlayer];
    [self.view addSubview:self.linesView];
    self.videoPlayer.hidden = YES;
}

- (void)viewWillLayoutSubviews {
    CGFloat courtAspectRatio = 8 / 5.f;
    CGFloat courtWidth = self.view.bounds.size.width;
    CGFloat courtHeight = courtWidth / courtAspectRatio;
    self.courtView.frame =
    CGRectMake(self.view.bounds.origin.x,
               CGRectGetMaxY(self.view.bounds) - courtHeight - 20, courtWidth,
               courtHeight);
    self.linesView.frame = [self.courtView courtRect];
    
    self.filters.frame =
    CGRectMake(self.view.bounds.origin.x, self.view.bounds.origin.y,
               self.view.bounds.size.width / 2,
               self.view.bounds.size.height - courtHeight - 20);
    
    self.videoPlayer.frame =
    CGRectMake(self.view.bounds.origin.x, self.view.bounds.origin.y,
               self.view.bounds.size.width,
               self.view.bounds.size.height - courtHeight - 20);
}

- (UITextView *)statsTextView {
    CGFloat courtAspectRatio = 8 / 5.f;
    CGFloat courtWidth = self.view.bounds.size.width;
    CGFloat courtHeight = courtWidth / courtAspectRatio;
    if (_statsTextView == nil) {
        _statsTextView = [[UITextView alloc]
                          initWithFrame:CGRectMake(
                                                   self.view.bounds.size.width / 2,
                                                   self.view.bounds.origin.y,
                                                   self.view.bounds.size.width / 2,
                                                   self.view.bounds.size.height - courtHeight - 20)];
        _statsTextView.editable = NO;
        _statsTextView.backgroundColor = [UIColor colorWithRed:218.0/255 green:223.0/255 blue:225.0/255.0 alpha:.4];
        

    }
    return _statsTextView;
}

- (UITextField *)field {
    if (_field == nil) {
        _field = [[UITextField alloc] init];
        _field.backgroundColor = [UIColor grayColor];
    }
    return _field;
}

- (UITextView *)offset {
    if (_offset == nil) {
        _offset = [[UITextView alloc] init];
        _offset.text = @"Offset:";
        _offset.editable = NO;
    }
    return _offset;
}

- (StatFilterView *)filters {
    if (_filters == nil) {
        _filters = [[StatFilterView alloc] init];
        _filters.stats = [[self game] allStats];
        
        [_filters on:@"filtered-stats"
            callback:^(NSArray *stats) { [self updateStats]; }];
    }
    return _filters;
}

- (CourtView *)courtView {
    if (_courtView == nil) {
        _courtView = [[CourtView alloc] init];
    }
    return _courtView;
};



- (AnalysisLinesView *)linesView {
    if (_linesView == nil) {
        _linesView = [[AnalysisLinesView alloc] init];
        [_linesView on:@"selected-stat"
              callback:^(Stat *stat) {
                  // NSLog(@"%@", stat);
                  self.videoPlayer.hidden = NO;
                  [self.videoPlayer seekTo:stat];
              }];
    }
    return _linesView;
}

- (StatAnalysisVideoPlayer *)videoPlayer {
    
    if (_videoPlayer == nil) {
        NSString* acsString = @"http://acsvolleyball.com/videos/";
        NSString* dotMPfour = @".mp4";
        
        NSString* videoUrlString = [NSString stringWithFormat:@"%@%@%@",acsString,self.game.videoUrl,dotMPfour];
        NSURL *videoUrlUrl = [NSURL URLWithString:videoUrlString];

      //  acsvolleyball.com/%@.com,videoURL
        //http://acsvolleyball.com/videos/shu_liu_a_smaller.mp4
        _videoPlayer = [[StatAnalysisVideoPlayer alloc] initWithURL:videoUrlString];
    }
    return _videoPlayer;
}

- (void)viewDidAppear:(BOOL)animated {
    [self updateStats];
    }
- addStatToDictionary:(NSMutableDictionary*)dict withPlayer:(NSString*)player category:(NSString*) category result:(NSString*)result{
    if (dict[player] == nil) {
        dict[player] = [[NSMutableDictionary alloc] init];
    }
    
    if (dict[player][category] == nil) {
        dict[player][category] = [[NSMutableDictionary alloc] init];
    }
    
    if (dict[player][category][result] == nil) {
        dict[player][category][result] = @0;
    }
    dict[player][category][result] = [NSNumber numberWithInteger:([dict[player][category][result] integerValue] + 1)];
    return dict;
}

-(NSMutableDictionary*)createStatDict{
    NSMutableDictionary*statDict = [[NSMutableDictionary alloc]init];
    
    for (_currentStat in self.filters.filteredStats){
        //Hitting
        if ([_currentStat.skill isEqual:@"Hit"]){
            NSString*currentPlayer = _currentStat.player;
            NSString*currentSkill = _currentStat.skill;
            
            NSString*result = _currentStat.details[@"result"];
            [self addStatToDictionary:statDict withPlayer:currentPlayer category:currentSkill result:result];
            [self addStatToDictionary:statDict withPlayer:@"All" category:currentSkill result:result];
            
            //blocking
            if ([_currentStat.details objectForKey:@"Blocked By"]!= nil) {
                
                
                currentPlayer = _currentStat.details[@"Blocked By"];
                currentSkill = @"Block";
                result = _currentStat.details[@"result"];
                [self addStatToDictionary:statDict withPlayer:currentPlayer category:currentSkill result:result];
                [self addStatToDictionary:statDict withPlayer:@"All" category:currentSkill result:result];
                
            }
            if ([_currentStat.details objectForKey:@"Dug By"] != nil) {
                
                currentPlayer = _currentStat.details[@"Dug By"];
                currentSkill = @"Dig";
                result = _currentStat.details[@"Dig Quality"];
                [self addStatToDictionary:statDict withPlayer:currentPlayer category:currentSkill result:result];
                [self addStatToDictionary:statDict withPlayer:@"All" category:currentSkill result:result];
                
            }
            
        }else if ([_currentStat.skill isEqual:@"Serve"]){
            NSString*currentPlayer = _currentStat.player;
            NSString*currentSkill = _currentStat.skill;
            NSString*result = _currentStat.details[@"result"];
            [self addStatToDictionary:statDict withPlayer:currentPlayer category:currentSkill result:result];
            [self addStatToDictionary:statDict withPlayer:@"All" category:currentSkill result:result];
            if ([_currentStat.details objectForKey:@"Passed By"] !=nil) {
                currentPlayer = _currentStat.details[@"Passed By"];
                currentSkill = @"Pass";
                result = _currentStat.details[@"result"];
                [self addStatToDictionary:statDict withPlayer:currentPlayer category:currentSkill result:result];
                [self addStatToDictionary:statDict withPlayer:@"All" category:@"Pass" result:result];
                
            }
        }
    };
    
    return statDict;
}

- (NSString *)hittingStats{
     NSMutableDictionary* statDict = [self createStatDict];
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setMaximumFractionDigits:3];
    [formatter setMinimumFractionDigits:3];
    //hitting
    NSInteger hittingKills = [statDict [@"All"][@"Hit"][@"Kill"] integerValue];
    NSInteger hittingErrors = [statDict [@"All"][@"Hit"][@"Error"] integerValue];
    NSInteger hittingThem = [statDict [@"All"][@"Hit"][@"Them"] integerValue];
    NSInteger hittingUs = [statDict [@"All"][@"Hit"][@"Us"] integerValue];
    
    NSUInteger hittingAttempts = hittingThem + hittingKills + hittingUs + hittingErrors;
    NSNumber *hitPercent = [NSNumber numberWithDouble:((float)hittingKills - hittingErrors) / hittingAttempts];
    NSString*hitPercentString = [formatter stringFromNumber:hitPercent];
    
    NSNumber *killPercent = [NSNumber numberWithDouble:((float)hittingKills) / hittingAttempts];
    NSString*killPercentString = [formatter stringFromNumber:killPercent];
    
    return [NSString stringWithFormat:
            @"##Hitting##\n    K    |    E    |    A    | Kill Per | Hit Per |\n    %lu    |    %lu    |    %lu     | %@ | %@ |\n\n",
            (unsigned long)hittingKills, (unsigned long)hittingErrors,(unsigned long)hittingAttempts, killPercentString, hitPercentString];
}

-(NSString*) servingStats{
    
NSMutableDictionary* statDict = [self createStatDict];
//formatting
NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
[formatter setMaximumFractionDigits:3];
[formatter setMinimumFractionDigits:3];

NSInteger servingAces = [statDict [@"All"][@"Serve"][@"Ace"] integerValue];
NSInteger serving0 = [statDict [@"All"][@"Serve"][@"0"] integerValue];
NSInteger serving1 = [statDict [@"All"][@"Serve"][@"1"] integerValue];
NSInteger serving2 = [statDict [@"All"][@"Serve"][@"2"] integerValue];

NSInteger serving3 = [statDict [@"All"][@"Serve"][@"3"] integerValue];
NSInteger serving4 = [statDict [@"All"][@"Serve"][@"4"] integerValue];
NSInteger servingErrors = [statDict [@"All"][@"Serve"][@"Error"] integerValue];
NSInteger servingOverpass = [statDict [@"All"][@"Serve"][@"Overpass"] integerValue];
NSInteger servingAttempts = servingAces + serving0 + serving1 + serving2 + serving3 + serving4 + servingErrors + servingOverpass;
NSNumber* serveStat = [NSNumber numberWithDouble:((serving1 *1 +
                                                   serving2 *2 +
                                                   serving3 *3 +
                                                   serving4 *4+
                                                   servingErrors *4)/(float)(servingAttempts))];
NSString*serveStatString = [formatter stringFromNumber:serveStat];
    
NSNumber* expectedWin = [NSNumber numberWithDouble:((  servingOverpass * .65+
                                                       serving1 *.6 +
                                                       serving2 *.55 +
                                                       serving3 *.35 +
                                                       serving4 *.3+
                                                       servingAces * 1
                                                     )/(float)(servingAttempts))];
NSString*expectedWinString = [formatter stringFromNumber:expectedWin];
    

    return [NSString
            stringWithFormat:@"##Serving## \n  Aces | Errors | Atts | SStat | EW |\n    %lu    |    %ld    |    %ld     | %@ | %@ |\n\n",(long)servingAces,(long)servingErrors,(long)servingAttempts,serveStatString,expectedWinString];
}
-(NSString*) passingStats{
    NSMutableDictionary* statDict = [self createStatDict];
    //formatting
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setMaximumFractionDigits:3];
    [formatter setMinimumFractionDigits:3];
    
    NSInteger passingAces = [statDict [@"All"][@"Pass"][@"Ace"] integerValue];
    NSInteger passing0 = [statDict [@"All"][@"Pass"][@"0"] integerValue];
    NSInteger passing1 = [statDict [@"All"][@"Pass"][@"1"] integerValue];
    NSInteger passing2 = [statDict [@"All"][@"Pass"][@"2"] integerValue];
    NSInteger passing3 = [statDict [@"All"][@"Pass"][@"3"] integerValue];
    NSInteger passing4 = [statDict [@"All"][@"Pass"][@"4"] integerValue];
    NSInteger passingErrors = [statDict [@"All"][@"Pass"][@"Error"] integerValue];
    NSInteger passingOverpass = [statDict [@"All"][@"Pass"][@"Overpass"] integerValue];
    NSInteger passingAttempts = passingAces + passing0 + passing1 + passing2 + passing3 + passing4 + passingErrors + passingOverpass;
    NSNumber* passStat = [NSNumber numberWithDouble:(4 - (passing1 *1 +
                                                       passing2 *2 +
                                                       passing3 *3 +
                                                       passing4 *4+
                                                       passingErrors *4)/(float)(passingAttempts))];
    
    NSString*passStatString = [formatter stringFromNumber:passStat];
    
    NSNumber* expectedLoss = [NSNumber numberWithDouble:((  passingOverpass * .65+
                                                         passing1 *.6 +
                                                         passing2 *.55 +
                                                         passing3 *.35 +
                                                         passing4 *.3+
                                                         passingAces * 1
                                                         )/(float)(passingAttempts))];
    double expectedLossVar = [expectedLoss doubleValue];
    double expectedWinVar = 1 - expectedLossVar;
    NSNumber* expectedWin = [NSNumber numberWithDouble: expectedWinVar];
    
    NSString*expectedWinString = [formatter stringFromNumber:expectedWin];
    NSNumber* inSystem = [NSNumber numberWithDouble:(  (passing3+passing4)/
                                                         (float)(passingAttempts))];
    NSString*inSystemString = [formatter stringFromNumber:inSystem];
    
    
    return [NSString
            stringWithFormat:@"##Passing## \n  Aces | inSys | Atts | PStat | EW |\n    %lu    |    %@    |    %ld     | %@ | %@ |\n\n",(long)passingAces,inSystemString,(long)passingAttempts,passStatString,expectedWinString];
}



- (NSString *)basicStats:(NSString*)playerForStats {
    NSMutableDictionary* statDict = [self createStatDict];
    //formatting
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setMaximumFractionDigits:3];
    [formatter setMinimumFractionDigits:3];
   
    /// passing stat team 0
    
    NSArray *passingOptions = [NSArray
                               arrayWithObjects:@"4", @"3", @"2", @"1", @"0", @"Ace", @"Err", nil];
    NSString *currentPassingOption;
    NSMutableDictionary *passValue = [[NSMutableDictionary alloc] init];
    
    for (currentPassingOption in passingOptions) {
        //    NSLog(@"%@", currentPassingOption);
        
        NSUInteger pass =
        [Stat filterStats:self.filters.filteredStats
              withFilters:@{
                            @"skill" : @"Serve",
                            @"details" : @{@"result" : currentPassingOption}
                            }].count;
        
        passValue[currentPassingOption] = [NSNumber numberWithUnsignedInt:pass];
        NSLog(@"pass value:%@%@",currentPassingOption,passValue);
    }
   
    NSUInteger passingAttempts = [Stat filterStats:self.filters.filteredStats
                                       withFilters:@{@"skill" : @"Serve"}].count;
    
    NSNumber *passStat = [NSNumber numberWithDouble:(
                                                     ([passValue[@"1"] integerValue] *1 +
                                                      [passValue[@"2"] integerValue] *2 +
                                                      [passValue[@"3"] integerValue] *3 +
                                                      [passValue[@"4"] integerValue] *4 +
                                                      [passValue[@"Err"] integerValue] *4
                                                      )/(float)(passingAttempts))];
    NSString*passStatString = [formatter stringFromNumber:passStat];
    
    NSLog(@"passingattempts: %lu\n%lu", (unsigned long)passingAttempts,
          (unsigned long)passValue[passingOptions[1]]);
        //digging
    
    NSInteger digs = [statDict [@"All"][@"Dig"][@"Dig"] integerValue];
    NSInteger ups = [statDict [@"All"][@"Dig"][@"Up"] integerValue];
    NSInteger digErrors = [statDict [@"All"][@"Dig"][@"Dig Error"] integerValue];
   
    //coverage
    
    NSUInteger covers = [Stat filterStats:self.filters.filteredStats
                            withFilters:@{@"details" : @{@"Cover Quality" : @"Cover"}}].count;
    NSUInteger coverUps = [Stat filterStats:self.filters.filteredStats
                           withFilters:@{@"details" : @{@"Cover Quality" : @"Cover Up"}}].count;
    NSUInteger coverErrors = [Stat filterStats:self.filters.filteredStats
                                 withFilters:@{@"details" : @{@"Cover Quality" : @"Cover Error"}}].count;

    //[@"Cover Quality"] = @"Dig"
    
    
//    return [NSString
//            stringWithFormat:@"STATS\n\n##Hitting##\n    K    |    E    |    A    | Kill Per | Hit Per |\n    %lu    |    %lu    |    %lu     | %@ | %@ |\n\n\n##Serving##\n Serve Average: %@\n Serve Aces: %@\n Serve Errors: %@ \n\n##Defense##\n Digs: %lu \n Ups: %lu \n Dig Errors: %lu \n " ,
//
//            (unsigned long)hittingKills, (unsigned long)hittingErrors,
//            (unsigned long)hittingAttempts, killPercentString, hitPercentString,
//            passStatString,passValue[@"Ace"],passValue[@"Err"], (unsigned long)digs, (unsigned long)ups, (unsigned long)digErrors];
//    
}

- (void)updateStats {
    self.linesView.stats = self.filters.filteredStats;
    NSString  *hittingText = [self hittingStats];
    NSString *servingText = [self servingStats];
    NSString *passingText = [self passingStats];
    
    
    
    NSString *test = [hittingText stringByAppendingString:servingText];
    NSString *addedPassing = [test stringByAppendingString:passingText];
    self.statsTextView.text =addedPassing;
    
    self.videoPlayer.playlist = self.filters.filteredStats;
}

@end
