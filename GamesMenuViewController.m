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
@property (readonly) UITextField *homeTeam;
@end

@implementation GamesMenuViewController
@synthesize newGame = _newGame;
@synthesize homeTeam = _homeTeam;

- (id)initWithGames:(NSArray*) games {
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
    }
    return _homeTeam;
}

- (void)loadView {
    [super loadView];
    UITableView *table = [[UITableView alloc] initWithFrame:CGRectMake(0, 100, self.view.bounds.size.width/2-50, self.view.bounds.size.height-50)];
    [self.view addSubview:table];
    table.delegate = self;
    table.dataSource = self;
    [self.view addSubview:self.newGame];


UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect]; //3
[button setFrame:CGRectMake(50, 0, 100, 150 )];
[button setTitle:@"New Game" forState:UIControlStateNormal];
[button addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];//2
[self.view addSubview:button]; //1
    
}





- (UITextView *)newGame {
    if (_newGame == nil) {
        _newGame= [[UITextView alloc] initWithFrame:CGRectMake(self.view.bounds.size.width/2-50, 75, 50,50)];
        _newGame.text = @"Main Menu";
        _newGame.editable = NO;
        NSLog(@"inside of newGame");
    }
    return _newGame;
}

- (void)buttonPressed:(UIButton *)sender{
    
    self.newGame;
    
    //NSLog(@"textField1: %@",addTextField1);
    [self addTextField1];
    [self addTextField];
    [sender setTitle:@"PressMe!. Again" forState:UIControlStateNormal];
    
    
}

-(NSString*)addTextField{
    // This allocates a label
    UILabel *prefixLabel = [[UILabel alloc]initWithFrame:CGRectZero];
    //This sets the label text
    prefixLabel.text =@"## ";
    // This sets the font for the label
    [prefixLabel setFont:[UIFont boldSystemFontOfSize:14]];
    // This fits the frame to size of the text
    [prefixLabel sizeToFit];
	
    // This allocates the textfield and sets its frame
    UITextField *textField = [[UITextField  alloc] initWithFrame:
                              CGRectMake(20, 50, 280, 30)];
    
    // This sets the border style of the text field
    textField.borderStyle = UITextBorderStyleRoundedRect;
    textField.contentVerticalAlignment =
    UIControlContentVerticalAlignmentCenter;
    [textField setFont:[UIFont boldSystemFontOfSize:12]];
    
    //Placeholder text is displayed when no text is typed
    textField.placeholder = @"Simple Text field";
    
    //Prefix label is set as left view and the text starts after that
    textField.leftView = prefixLabel;
    
    //It set when the left prefixLabel to be displayed
    textField.leftViewMode = UITextFieldViewModeAlways;
    
    // Adds the textField to the view.
    [self.view addSubview:textField];
    
    // sets the delegate to the current class
    textField.delegate = self;
    return self.addTextField.text;
}

-(void)addTextField1{
    // This allocates a label
    UILabel *prefixLabel = [[UILabel alloc]initWithFrame:CGRectZero];
    //This sets the label text
    prefixLabel.text =@"## ";
    // This sets the font for the label
    [prefixLabel setFont:[UIFont boldSystemFontOfSize:14]];
    // This fits the frame to size of the text
    [prefixLabel sizeToFit];
	
    // This allocates the textfield and sets its frame
    UITextField *textField1 = [[UITextField  alloc] initWithFrame:
                              CGRectMake(20, 90, 280, 30)];
    
    // This sets the border style of the text field
    textField1.borderStyle = UITextBorderStyleRoundedRect;
    textField1.contentVerticalAlignment =
    UIControlContentVerticalAlignmentCenter;
    [textField1 setFont:[UIFont boldSystemFontOfSize:12]];
    
    //Placeholder text is displayed when no text is typed
    textField1.placeholder = @"Simple Text field";
    
    //Prefix label is set as left view and the text starts after that
    textField1.leftView = prefixLabel;
    
    //It set when the left prefixLabel to be displayed
    textField1.leftViewMode = UITextFieldViewModeAlways;
    
    // Adds the textField to the view.
    [self.view addSubview:textField1];
    
    // sets the delegate to the current class
    textField1.delegate = self;
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
