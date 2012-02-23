//
//  ViewController.m
//  FastPhotoTweet
//
//  Created by @peace3884 on 12/02/23.
//

#import "ViewController.h"

@implementation ViewController
@synthesize postButton;

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

- (IBAction)pushPostButton:(id)sender {
    
}

- (void)sendTweet {
    
    NSString *twittertext = @"Test";
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 5.0) {
        
        NSLog(@"Twitter API not available, please upgrade to iOS 5");
    
    }else{
        
    }
    
    NSDictionary *tparam = [NSDictionary dictionaryWithObject:twittertext forKey:@"status"];
    NSURL *turl = [NSURL URLWithString:@"https://api.twitter.com/1/statuses/update.json"];
    TWRequest *updateProfile = [[TWRequest alloc] initWithURL:turl parameters:tparam
                                                requestMethod:TWRequestMethodPOST];
    
    if (twAccount == nil) {
        
        NSLog(@"Can’t tweet");
        return;
    }
    
    updateProfile.account = twAccount;
    
    TWRequestHandler requestHandler = ^(NSData *responseData, 
                                        NSHTTPURLResponse *urlResponse, 
                                        NSError *error) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if (error != nil) {
                //error
            } else {
                //success
            }
        });
    };
    
    [updateProfile performRequestWithHandler:requestHandler];
}

- (void)viewDidUnload {
    [self setPostButton:nil];
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

- (void)dealloc {
    [postButton release];
    [super dealloc];
}
@end
