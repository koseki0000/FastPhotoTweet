//
//  SpecialThanksViewController.m
//  FastPhotoTweet
//
//  Created by @peace3884 on 12/11/04.
//
//

#import "SpecialThanksViewController.h"

@implementation SpecialThanksViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    [_mainText flashScrollIndicators];
}

- (IBAction)pushBackButton:(id)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
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
