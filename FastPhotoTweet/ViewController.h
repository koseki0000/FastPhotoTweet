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
#import "IDChangeViewController.h"
#import "SettingViewController.h"
#import <MediaPlayer/MediaPlayer.h>
//#import <MediaPlayer/MPMusicPlayerController.h>

@interface ViewController : UIViewController <UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIActionSheetDelegate> {
    
    GrayView *grayView;
    
    NSUserDefaults *d;
    ACAccount *twAccount;
    
    NSString *reSendText;
    NSMutableDictionary *postedDic;
    
    UIImage *reSendImage;
    
    BOOL changeAccount;
    int actionSheetNo;
    int postedCount;
}

@property (retain, nonatomic) IBOutlet UIScrollView *sv;
@property (retain, nonatomic) IBOutlet UITextView *postText;
@property (retain, nonatomic) IBOutlet UILabel *callbackLabel;
@property (retain, nonatomic) IBOutlet UILabel *fastPostLabel;
@property (retain, nonatomic) IBOutlet UILabel *postCharLabel;
@property (retain, nonatomic) IBOutlet UITextField *callbackTextField;
@property (retain, nonatomic) IBOutlet UISwitch *callbackSwitch;
@property (retain, nonatomic) IBOutlet UISwitch *fastPostSwitch;
@property (retain, nonatomic) IBOutlet UIImageView *imagePreview;
@property (retain, nonatomic) IBOutlet UIToolbar *topBar;
@property (retain, nonatomic) IBOutlet UIToolbar *bottomBar;
@property (retain, nonatomic) IBOutlet UIBarButtonItem *trashButton;
@property (retain, nonatomic) IBOutlet UIBarButtonItem *postButton;
@property (retain, nonatomic) IBOutlet UIBarButtonItem *imageSettingButton;
@property (retain, nonatomic) IBOutlet UIBarButtonItem *idButton;
@property (retain, nonatomic) IBOutlet UIBarButtonItem *settingButton;
@property (retain, nonatomic) IBOutlet UIBarButtonItem *flexibleSpace;
@property (retain, nonatomic) IBOutlet UIBarButtonItem *addButton;
@property (retain, nonatomic) IBOutlet UITapGestureRecognizer *tapGesture;

- (IBAction)pushPostButton:(id)sender;
- (IBAction)pushTrashButton:(id)sender;
- (IBAction)pushSettingButton:(id)sender;
- (IBAction)pushImageSettingButton:(id)sender;
- (IBAction)pushIDButton:(id)sender;
- (IBAction)pushAddButton:(id)sender;

- (IBAction)callbackTextFieldEnter:(id)sender;
- (IBAction)textFieldStartEdit:(id)sender;

- (IBAction)callbackSwitchDidChage:(id)sender;
- (IBAction)fastPostSwitchDidChage:(id)sender;

- (IBAction)svTapGesture:(id)sender;

- (void)loadSettings;
- (void)postDone:(NSNotification *)center;
- (BOOL)ios5Check;
- (BOOL)reachability;
- (NSString *)nowPlaying;

@end
