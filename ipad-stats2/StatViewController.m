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
#import "Serializable.h"

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

    StatEntryView *statEntryView = [[StatEntryView alloc] initWithFrame:CGRectMake(0,0,1024,700)];
    [self.view addSubview:statEntryView];
    
    [statEntryView on:@"play-added" callback:^(Play* play) {
        NSLog(@"Adding play");
        
        play.gameID = self.game.id;
        [self.game addPlay:play];
    }];
    
    [statEntryView on:@"stat-added" callback:^(Stat* stat) {
         NSLog(@"Adding stat");
        [[SerializableManager manager] SaveSerializable:self.game withCallback:^(NSObject<Serializable> *object) {
 
        }];
    }];

    self.view.backgroundColor = [UIColor clearColor];
}
- (BOOL)shouldAutorotate
{
    return NO;
}
- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait; // supports both landscape modes
}
//- (NSUInteger)supportedInterfaceOrientations {
//    return UIInterfaceOrientationMaskPortrait;
//}

@end
