//
//  LicenseViewController.m
//  FastPhotoTweet
//
//  Created by @peace3884 on 12/04/30.
//

#import "LicenseViewController.h"

@implementation LicenseViewController
@synthesize bar;
@synthesize closeButton;
@synthesize textView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if (self) {

    }
    
    return self;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
}

- (IBAction)pushCloseButton:(id)sender {
    
    //閉じる
    [self dismissModalViewControllerAnimated:YES];
}

- (void)viewDidUnload {

    [self setBar:nil];
    [self setCloseButton:nil];
    [self setTextView:nil];
    [super viewDidUnload];
}

- (void)dealloc {
    
    [bar release];
    [closeButton release];
    [textView release];
    [super dealloc];
}

@end
