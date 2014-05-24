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
@property(readonly) UITextView *newGame;
@end

@implementation GamesMenuViewController
@synthesize newGame = _newGame;

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
    UITableView *table = [[UITableView alloc] initWithFrame:CGRectMake(0, 100, self.view.bounds.size.height, self.view.bounds.size.width)];
    [self.view addSubview:table];
    table.delegate = self;
    table.dataSource = self;
    [self.view addSubview:self.newGame];


UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect]; //3
[button setFrame:CGRectMake(self.view.bounds.size.width/2-50, 0, 100,100 )];
[button setTitle:@"New Game" forState:UIControlStateNormal];
[button addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];//2
[self.view addSubview:button]; //1
}

- (UITextView *)newGame {
    if (_newGame == nil) {
        _newGame= [[UITextView alloc] initWithFrame:CGRectMake(self.view.bounds.size.width/2-50, 100, 100,100)];
        _newGame.text = @"New Game:";
        _newGame.editable = NO;
        NSLog(@"inside of newGame");
    }
    return _newGame;
}

- (void)buttonPressed:(UIButton *)sender{
    
    self.newGame;
    [sender setTitle:@"PressMe!. Again" forState:UIControlStateNormal];
    
    
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
