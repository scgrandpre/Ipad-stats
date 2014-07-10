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
@property(strong) NSArray *games;
@property(readonly) UITextView *header;
@property(readonly) UITextField *homeTeam;
@property(readonly) UITextField *awayTeam;
@property(readonly) UIButton *newGame;
@end

@implementation GamesMenuViewController
@synthesize header = _header;
@synthesize homeTeam = _homeTeam;
@synthesize awayTeam = _awayTeam;
@synthesize newGame = _newGame;
@synthesize label;



- (id)initWithGames:(NSArray *)games {
  self = [super init];
  if (self) {
    // Custom initialization
    self.games = games;
  }
  return self;
}

- (UITextField *)homeTeam {
  if (_homeTeam == nil) {
    _homeTeam = [[UITextField alloc] init];
    _homeTeam.backgroundColor = [UIColor grayColor];
    _homeTeam.hidden = YES;
    _homeTeam.delegate = self;
  }
  return _homeTeam;
}

- (UITextField *)awayTeam {
  if (_awayTeam == nil) {
    _awayTeam = [[UITextField alloc] init];
    _awayTeam.backgroundColor = [UIColor grayColor];
    _awayTeam.hidden = YES;
    _awayTeam.delegate = self;
  }
  return _awayTeam;
}

- (UITextView *)header {
  if (_header == nil) {
    _header = [[UITextView alloc]
        initWithFrame:CGRectMake(self.view.bounds.size.width / 2 - 50, 75, 50,
                                 50)];
    _header.text = @"Main Menu";
    _header.editable = NO;
  }
  return _header;
}

- (UIButton *)newGame {
  if (_newGame == nil) {
    _newGame = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [_newGame setTitle:@"New Game" forState:UIControlStateNormal];
    [_newGame addTarget:self
                  action:@selector(makeNewGame:)
        forControlEvents:UIControlEventTouchUpInside];
  }
  return _newGame;
}

- (void)loadView {
  [super loadView];
  UITableView *table = [[UITableView alloc]
      initWithFrame:CGRectMake(0, 100, self.view.bounds.size.width / 2 - 50,
                               self.view.bounds.size.height - 50)];
  [self.view addSubview:table];
  table.delegate = self;
  table.dataSource = self;

  [self.view addSubview:self.header];
  [self.view addSubview:self.newGame];
  [self.view addSubview:self.homeTeam];
  [self.view addSubview:self.awayTeam];
}

- (void)viewWillLayoutSubviews {
  self.newGame.frame = CGRectMake(10, 0, 300, 150);
  self.homeTeam.frame = CGRectMake(10, 5, 300, 65);
  self.awayTeam.frame = CGRectMake(10, 75, 300, 65);
}

- (void)makeNewGame:(UIButton *)sender {
  self.awayTeam.hidden = NO;
  self.homeTeam.hidden = NO;
  // Make a game?
  [sender setTitle:@"PressMe!. Again" forState:UIControlStateNormal];
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
  if (!cell) {
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                  reuseIdentifier:@"cell"];
  }
  Game *game = self.games[indexPath.row];
  cell.textLabel.text = [NSString stringWithFormat:@"%@", game.date];
  return cell;
}

- (NSInteger)tableView:(UITableView *)tableView
    numberOfRowsInSection:(NSInteger)section {
  return [self.games count];
}

- (void)tableView:(UITableView *)tableView
    didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  Game *game = self.games[indexPath.row];
  AppDelegate *delegate = [UIApplication sharedApplication].delegate;

  [delegate openGame:game];
}

- (void)viewDidLoad {
  [super viewDidLoad];
  // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
  if (textField == self.homeTeam) {
    [self.awayTeam becomeFirstResponder];
      NSLog(@"%@",self.homeTeam.text);
  } else if (textField == self.awayTeam) {
    [self.awayTeam resignFirstResponder];
      NSLog(@"%@", self.awayTeam.text);

    // create game
    Game *game = [[Game alloc] init];
    game.awayTeam = self.awayTeam.text;
    game.homeTeam = self.homeTeam.text;

    SerializableManager *manager = [SerializableManager manager];
    [manager SaveSerializable:game
                 withCallback:^(NSObject<Serializable> *object) {}];

    AppDelegate *delegate =
        (AppDelegate *)[UIApplication sharedApplication].delegate;
    [delegate openGame:game];
  }
  return NO;
}

@end
