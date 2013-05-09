//
//  AppDelegate.m
//  ipad-stats2
//
//  Created by Jim Grandpre on 4/11/13.
//  Copyright (c) 2013 RIPP Volleyball. All rights reserved.
//
/*
~/redis/redis-2.6.13/src/redis-server

cd ~/Video Stats/ipad-stats2/server
cake go
*/
#import "AppDelegate.h"
#import "StatViewController.h"
#import "DrawnStatViewController.h"
#import "StatAnalysisViewController.h"
#import "Game.h"
#import "Play.h"
#import "GamesMenuViewController.h"
#import "Serializable.h"
#import <SocketIO.h>
#import <SocketIOPacket.h>

@interface AppDelegate ()

@property (strong) UINavigationController *navigationController;
@property (strong) SocketIO *socket;
@property (strong) NSMutableDictionary *games;

@end

@implementation AppDelegate

- (void)openGame:(Game*) game {
    UIViewController *mainViewController = [[StatViewController alloc] initWithGame: game];
    UIViewController *otherViewController = [[DrawnStatViewController alloc] initWithGame: game];
    UIViewController *analysisViewController = [[StatAnalysisViewController alloc] initWithGame: game];
    UITabBarController *tabBar = [[UITabBarController alloc] init];
    tabBar.viewControllers = @[mainViewController, otherViewController, analysisViewController];
    tabBar.selectedViewController = mainViewController;
    mainViewController.title = @"Main View";
    otherViewController.title = @"Other View";
    analysisViewController.title = @"Analysis";
    
    [self.navigationController pushViewController:tabBar animated:YES];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    UINavigationController *root = [[UINavigationController alloc] init];
    root.navigationBar.hidden = YES;
    self.navigationController = root;
    SerializableManager *manager = [SerializableManager manager];
    //[manager SaveSerializable:[Game stub] withCallback:^(NSObject<Serializable> *object) {}];
    self.games = [[NSMutableDictionary alloc] init];
    [manager GetAllSerializable:[Game class] callback:^(NSArray *games) {
        GamesMenuViewController *gamesMenu = [[GamesMenuViewController alloc] initWithGames:games];
        for(Game* game in games) {
            self.games[game.id] = game;
        }
        [root pushViewController:gamesMenu animated:NO];
    }];
    
    
    [self.window setRootViewController:root];
    
    
    self.window.backgroundColor = [UIColor whiteColor];

    [self.window makeKeyAndVisible];
    
    
    SocketIO *socketIO = [[SocketIO alloc] initWithDelegate:self];
    [socketIO connectToHost:@"localhost" onPort:8338];
    [socketIO sendMessage:@"hello world"];
    self.socket = socketIO;
    
    return YES;
}

- (void) socketIODidConnect:(SocketIO *)socket {
    NSLog(@"CONNECT!");
}

- (void) socketIODidDisconnect:(SocketIO *)socket disconnectedWithError:(NSError *)error {
    NSLog(@"DIS!");
}
- (void) socketIO:(SocketIO *)socket didReceiveJSON:(SocketIOPacket *)packet {
    NSLog(@"JSON: %@", packet);
}

- (void) socketIO:(SocketIO *)socket didReceiveMessage:(SocketIOPacket *)packet {
    NSLog(@"MESSAGE: %@", packet);
}

- (void) socketIO:(SocketIO *)socket didReceiveEvent:(SocketIOPacket *)packet {
    if([packet.name compare: @"add-play"] == NSOrderedSame) {
        NSLog(@"EVENT: %@", packet);
        Play *newPlay = (Play*)[Play fromDict:packet.args[0]];
        NSLog(@"%@", newPlay);
        Game* game = self.games[newPlay.gameID];
        if(game) {
            for(Play *play in game.plays) {
                if([play.id compare:newPlay.id] == NSOrderedSame) {
                    return;
                }
            }
            [game.plays addObject: newPlay];
        }
    }
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
