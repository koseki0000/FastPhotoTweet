//
//  ViewController.h
//  FastPhotoTweet
//
//  Created by @peace3884 on 12/02/23.
//

#import <UIKit/UIKit.h>
#import <Twitter/Twitter.h>
#import <Accounts/Accounts.h>

@interface ViewController : UIViewController {
    
    ACAccountStore *accountStore;
    ACAccount *twAccount;
}

@property (retain, nonatomic) IBOutlet UIButton *postButton;

- (IBAction)pushPostButton:(id)sender;
- (void)sendTweet;
- (void)activityIndicatorVisible:(BOOL)visible;

@end
