//
//  ViewController.h
//  FastPhotoTweet
//
//  Created by @peace3884 on 12/02/23.
//

#import <UIKit/UIKit.h>
#import <Twitter/Twitter.h>
#import <Accounts/Accounts.h>

#import "Twitter/TWTwitterHeader.h"
#import "UtilityClass.h"

@interface ViewController : UIViewController {
    
    NSUserDefaults *d;
    
    ACAccount *twAccount;
}

@property (retain, nonatomic) IBOutlet UIButton *postButton;
@property (retain, nonatomic) IBOutlet UITextView *postText;
@property (retain, nonatomic) IBOutlet UILabel *callbackLabel;
@property (retain, nonatomic) IBOutlet UITextField *callbackTextField;
@property (retain, nonatomic) IBOutlet UISwitch *callbackSwitch;

- (IBAction)pushPostButton:(id)sender;
- (IBAction)callbackTextFieldEnter:(id)sender;
- (IBAction)callbackSwitchDidChage:(id)sender;

- (void)loadSettings;

@end
