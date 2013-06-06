//
//  StatEntryView.m
//  ipad-stats2
//
//  Created by Scott Grandpre on 5/30/13.
//  Copyright (c) 2013 RIPP Volleyball. All rights reserved.
//

#import "StatEntryView.h"
#import "DrawnStatViewController.h"
#import "DrawingView.h"



@implementation StatEntryView
@synthesize currentStateTest;



- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    currentStateTest = [[NSMutableString alloc] init];
    [self.currentStateTest setString:(@"Serve")];

    if (self) {
        // Initialization code
    }
    //[self currentState:@"Serve"];
    
    return self;
}
//This is where we change the state
//I am working on getting it to change based on location
//it is currently not a miracle
- (NSString*)nextStateForLine:(NSArray*)line{
    NSLog(@"%@",@"in currentState");
    NSLog(@"%@",currentStateTest);
    NSLog(@"%@",line);
    

    if ([@"Serve" isEqualToString:(self.currentStateTest)])
    {
        NSLog(@"it worked!!");
        NSLog(@"%@",line[[line count]-1]);
        CGPoint pointZero = [line[0] CGPointValue];
        CGPoint pointLast = [line[[line count]-1] CGPointValue];
        NSLog(@"%f%f",pointZero.x,pointZero.y);
        if ((pointZero.x <.1) && (pointZero.y >.5))
        {
            NSLog(@"Its a miracle!");
            
        }
        //NSValue *val = [points objectAtIndex:0];
        //CGPoint p = [val CGPointValue];

        
        
        [self.currentStateTest setString:(@"Pass")];
    }
    
    else if ([@"Pass" isEqualToString:(self.currentStateTest)])
    {
        NSLog(@"Changed State!!");
        [self.currentStateTest setString:(@"Hit")];
    }
    
    else if ([@"Hit" isEqualToString:(self.currentStateTest)])
    {
        NSLog(@"it worked!!");
        [self.currentStateTest setString:(@"Dig")];
    }
    
    NSLog(@"%@", currentStateTest);
    
    NSLog(@"%@",currentStateTest);
    return currentStateTest;
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
