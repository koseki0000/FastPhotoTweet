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
    
    NSString *buildNum = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    NSString *bundleVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
    
    textView.text = [NSString stringWithFormat:@"FastPhotoTweet v%@, build-%@\n\n%@",buildNum , bundleVersion,textView.text];
}

- (IBAction)pushCloseButton:(id)sender {
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    //閉じる
    if ( [appDelegate.firmwareVersion hasPrefix:@"6"] ) {
        
        [self dismissViewControllerAnimated:YES completion:nil];
        
    }else {
        
        [self dismissModalViewControllerAnimated:YES];
    }
}

- (void)viewDidUnload {

    [self setBar:nil];
    [self setCloseButton:nil];
    [self setTextView:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotate {
    
    if ( [[UIDevice currentDevice] orientation] == UIDeviceOrientationPortrait ) return YES;
    
    return NO;
}

- (NSUInteger)supportedInterfaceOrientations {
    
    return UIInterfaceOrientationMaskPortrait;
}

- (void)dealloc {
    
    [bar release];
    [closeButton release];
    [textView release];
    [super dealloc];
}

@end
