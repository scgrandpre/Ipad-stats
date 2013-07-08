//
//  StatViewController.m
//  ipad-stats2
//
//  Created by Jim Grandpre on 4/11/13.
//  Copyright (c) 2013 RIPP Volleyball. All rights reserved.
//

#import "StatViewController.h"
#import "StatEntryView.h"
#import <EventEmitter/EventEmitter.h>
#import "Game.h"
#import "Play.h"
#import "Stat.h"
#import "PlayListView.h"

@interface StatViewController ()
@property Game* game;

@end

@implementation StatViewController

- (id)initWithGame:(Game*)game {
    self = [super init];
    if (self) {
        self.game = game;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    StatEntryView *statEntryView = [[StatEntryView alloc] initWithFrame:CGRectMake(0,0,700,592)]; //we have 324 to work with on the right side
    [self.view addSubview:statEntryView];

    
    PlayListView *playListView = [[PlayListView alloc] initWithFrame:CGRectMake(700, 00, 324, 592) game:self.game];
    [self.view addSubview:playListView];
    
    [statEntryView on:@"play-added" callback:^(Play* play) {
        NSLog(@"Adding play");
        [self.game.plays addObject:play];
    }];
    
    [statEntryView on:@"stat-added" callback:^(Stat* stat) {
         NSLog(@"Adding stat");
        [playListView refresh];
    }];

    self.view.backgroundColor = [UIColor clearColor];
    
    

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
