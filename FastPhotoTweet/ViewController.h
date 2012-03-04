//
//  ViewController.h
//  FastPhotoTweet
//
//  Created by @peace3884 on 12/02/23.
//

#import <UIKit/UIKit.h>
#import <UIKit/UITextChecker.h>
#import <Twitter/Twitter.h>
#import <Accounts/Accounts.h>
#import "JSON.h"
#import <SystemConfiguration/SystemConfiguration.h>
#import "Reachability.h"
#import "Twitter/TWTwitterHeader.h"
#import "UtilityClass.h"

@interface ViewController : UIViewController <UINavigationControllerDelegate, UIImagePickerControllerDelegate> {
    
    NSUserDefaults *d;
    ACAccount *twAccount;
}

@property (retain, nonatomic) IBOutlet UIScrollView *sv;
@property (retain, nonatomic) IBOutlet UIButton *postButton;
@property (retain, nonatomic) IBOutlet UIButton *dicButton;
@property (retain, nonatomic) IBOutlet UIButton *imageSettingButton;
@property (retain, nonatomic) IBOutlet UITextView *postText;
@property (retain, nonatomic) IBOutlet UILabel *callbackLabel;
@property (retain, nonatomic) IBOutlet UILabel *fastPostLabel;
@property (retain, nonatomic) IBOutlet UILabel *postCharLabel;
@property (retain, nonatomic) IBOutlet UITextField *callbackTextField;
@property (retain, nonatomic) IBOutlet UISwitch *callbackSwitch;
@property (retain, nonatomic) IBOutlet UISwitch *fastPostSwitch;
@property (retain, nonatomic) IBOutlet UIImageView *imagePreview;

- (IBAction)pushPostButton:(id)sender;
- (IBAction)pushDicButton:(id)sender;
- (IBAction)pushImageSettingButton:(id)sender;
- (IBAction)callbackTextFieldEnter:(id)sender;
- (IBAction)callbackSwitchDidChage:(id)sender;
- (IBAction)fastPostSwitchDidChage:(id)sender;
- (IBAction)textFieldStartEdit:(id)sender;

- (void)loadSettings;
- (BOOL)ios5Check;

@end
