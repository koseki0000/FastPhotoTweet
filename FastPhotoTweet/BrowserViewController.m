//
//  BrowserViewController.m
//  FastPhotoTweet
//
//  Created by @peace3884 on 12/09/27.
//

#import "BrowserViewController.h"

@implementation BrowserViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if ( self ) {
        
        self.title = NSLocalizedString(@"Browser", @"Browser");
        self.tabBarItem.image = [UIImage imageNamed:@"browser.png"];
    }
    
    return self;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
}

@end
