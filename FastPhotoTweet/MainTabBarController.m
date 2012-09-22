//
//  MainTabBarController.m
//  FastPhotoTweet
//
//  Created by @peace3884 on 12/09/22.
//

#import "MainTabBarController.h"

@implementation MainTabBarController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if ( self ) {
    }
    
    return self;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
}

- (BOOL)shouldAutorotate {
    
    NSLog(@"ViewController shouldAutorotate");
    return NO;
}

- (NSUInteger)supportedInterfaceOrientations {
    
    NSLog(@"ViewController supportedInterfaceOrientations");
    return UIInterfaceOrientationMaskPortrait;
}

@end
