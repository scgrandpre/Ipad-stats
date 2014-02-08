//
//  GamesMenuViewController.m
//  ipad-stats2
//
//  Created by Jim Grandpre on 4/30/13.
//  Copyright (c) 2013 RIPP Volleyball. All rights reserved.
//

#import "GamesMenuViewController.h"
#import "Game.h"
#import "AppDelegate.h"

@interface GamesMenuViewController ()
@property (strong) NSArray* games;
@end

@implementation GamesMenuViewController

- (id)initWithGames:(NSArray*) games {
    self = [super init];
    if (self) {
        // Custom initialization
        self.games = games;
    }
    return self;
}

- (void)loadView {
    [super loadView];
    UITableView *table = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.height, self.view.bounds.size.width)];
    [self.view addSubview:table];
    table.delegate = self;
    table.dataSource = self;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell"];
    }
    Game *game = self.games[indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"%@", game.date];
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.games count];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    Game* game = self.games[indexPath.row];
    AppDelegate *delegate = [UIApplication sharedApplication].delegate;
    [delegate openGame:game];}


- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
