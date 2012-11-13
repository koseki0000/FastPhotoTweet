//
//  SpecialThanksViewController.m
//  FastPhotoTweet
//
//  Created by m.s.s02968 on 12/11/04.
//
//

#import "SpecialThanksViewController.h"

@implementation SpecialThanksViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    [_mainText flashScrollIndicators];
}

- (IBAction)pushBackButton:(id)sender {
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    //閉じる
    if ( [appDelegate.firmwareVersion hasPrefix:@"6"] ) {
        
        [self dismissViewControllerAnimated:YES completion:nil];
        
    }else {
        
        [self dismissModalViewControllerAnimated:YES];
    }
}

- (void)dealloc {
    
    [_mainText release];
    [_topBar release];
    [_backButton release];
    [super dealloc];
}

- (void)viewDidUnload {
    
    [self setMainText:nil];
    [self setTopBar:nil];
    [self setBackButton:nil];
    [super viewDidUnload];
}
@end
