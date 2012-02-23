//
//  ViewController.m
//  FastPhotoTweet
//
//  Created by @peace3884 on 12/02/23.
//

#import "ViewController.h"

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //Twitter Account
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 5.0) {
        NSLog(@"Twitter API not available, please upgrade to iOS 5");
    } else {
        accountStore = [[ACAccountStore alloc] init];
        ACAccountType *accountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
        
        [accountStore requestAccessToAccountsWithType:accountType withCompletionHandler:
         ^(BOOL granted, NSError *error) {
             dispatch_async(dispatch_get_main_queue(), ^{
                 if (granted) {
                     NSArray *twitterAccounts = [accountStore accountsWithAccountType:accountType];
                     if (twitterAccounts.count > 0) {
                         twAccount = [[twitterAccounts objectAtIndex:0] retain];
                         NSLog(@"Twitter account access granted:%@", [twAccount username]);
                     } else {
                         twAccount = nil;
                         NSLog(@"Twitter account nothing");
                     }
                 } else {
                     twAccount = nil;
                     NSLog(@"Twitter account access denied");
                 }
             });
         }];
    }
}

- (void)sendTweet {
    
    TWTweetComposeViewController *Tweeter = [[TWTweetComposeViewController alloc] init];
    [Tweeter setInitialText:@"Test"];
    [self presentModalViewController:Tweeter animated:YES];
    
    Tweeter.completionHandler = ^(TWTweetComposeViewControllerResult result) {
        switch (result) {
            case TWTweetComposeViewControllerResultCancelled:
                //NSLog(@”Twitter Result: canceled”);
                break;
            case TWTweetComposeViewControllerResultDone:
                //NSLog(@”Twitter Result: sent”);
                break;
            default:
                //NSLog(@”Twitter Result: sent”);
                break;
        }
        [self dismissModalViewControllerAnimated:YES];
    };
    
    [Tweeter release];
}

- (void)viewDidUnload {
    [super viewDidUnload];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

@end
