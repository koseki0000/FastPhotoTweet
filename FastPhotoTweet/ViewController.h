//
//  ViewController.h
//  FastPhotoTweet
//
//  Created by @peace3884 on 12/02/23.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import <UIKit/UITextChecker.h>
#import <Twitter/Twitter.h>
#import <Accounts/Accounts.h>
#import "JSON.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"
#import <CFNetwork/CFNetwork.h>
#import <QuartzCore/QuartzCore.h>
#import <SystemConfiguration/SystemConfiguration.h>
#import "Reachability.h"
#import "Twitter/TWTwitterHeader.h"
#import "UtilityClass.h"
#import "IDChangeViewController.h"
#import "SettingViewController.h"
#import "OAuthSetupViewController.h"
#import "WebViewExController.h"
#import <MediaPlayer/MediaPlayer.h>
#import "UUIDEncryptor.h"
#import "ResendViewController.h"

@interface ViewController : UIViewController <UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIActionSheetDelegate> {
    
    GrayView *grayView;
    
    NSUserDefaults *d;
    UIPasteboard *pboard;
    UIImage *errorImage;
    AppDelegate * appDelegate;
    ACAccount *twAccount;
    
    BOOL changeAccount;
    BOOL cameraMode;
    BOOL repeatedPost;
    BOOL resendMode;
    BOOL webBrowserMode;
    int actionSheetNo;
}

@property (retain, nonatomic) IBOutlet UIScrollView *sv;
@property (retain, nonatomic) IBOutlet UITextView *postText;
@property (retain, nonatomic) IBOutlet UILabel *callbackLabel;
@property (retain, nonatomic) IBOutlet UILabel *postCharLabel;
@property (retain, nonatomic) IBOutlet UITextField *callbackTextField;
@property (retain, nonatomic) IBOutlet UISwitch *callbackSwitch;
@property (retain, nonatomic) IBOutlet UIImageView *imagePreview;
@property (retain, nonatomic) IBOutlet UIToolbar *topBar;
@property (retain, nonatomic) IBOutlet UIToolbar *bottomBar;
@property (retain, nonatomic) IBOutlet UIBarButtonItem *trashButton;
@property (retain, nonatomic) IBOutlet UIBarButtonItem *postButton;
@property (retain, nonatomic) IBOutlet UIBarButtonItem *imageSettingButton;
@property (retain, nonatomic) IBOutlet UIBarButtonItem *resendButton;
@property (retain, nonatomic) IBOutlet UIBarButtonItem *idButton;
@property (retain, nonatomic) IBOutlet UIBarButtonItem *settingButton;
@property (retain, nonatomic) IBOutlet UIBarButtonItem *flexibleSpace;
@property (retain, nonatomic) IBOutlet UIBarButtonItem *addButton;
@property (retain, nonatomic) IBOutlet UIBarButtonItem *nowPlayingButton;
@property (retain, nonatomic) IBOutlet UIBarButtonItem *actionButton;
@property (retain, nonatomic) IBOutlet UITapGestureRecognizer *tapGesture;
@property (retain, nonatomic) IBOutlet UISwipeGestureRecognizer *rigthSwipe;
@property (retain, nonatomic) IBOutlet UISwipeGestureRecognizer *leftSwipe;

- (IBAction)pushPostButton:(id)sender;
- (IBAction)pushTrashButton:(id)sender;
- (IBAction)pushSettingButton:(id)sender;
- (IBAction)pushImageSettingButton:(id)sender;
- (IBAction)pushIDButton:(id)sender;
- (IBAction)pushAddButton:(id)sender;
- (IBAction)pushResendButton:(id)sender;
- (IBAction)pushNowPlayingButton:(id)sender;
- (IBAction)pushActionButton:(id)sender;

- (IBAction)callbackTextFieldEnter:(id)sender;
- (IBAction)textFieldStartEdit:(id)sender;

- (IBAction)callbackSwitchDidChage:(id)sender;

- (IBAction)svTapGesture:(id)sender;
- (IBAction)swipeToMoveCursorRight:(id)sender;
- (IBAction)swipeToMoveCursorLeft:(id)sender;

- (void)testMethod;

- (void)loadSettings;
- (void)showInfomation;
- (void)showImagePicker;
- (void)callback;
- (void)countText;
- (void)startWebBrowsing;
- (void)uploadImage:(UIImage *)image;
- (void)postDone:(NSNotification *)center;
- (BOOL)ios5Check;
- (BOOL)reachability;
- (NSString *)nowPlaying;
- (NSString *)deleteWhiteSpace:(NSString *)string;

- (void)nowPlayingNotification;
- (void)postNotification:(int)pBoardType;
- (void)fastPostNotification:(int)pBoardType;
- (void)photoPostNotification:(int)pBoardType;
- (void)webPageShareNotification:(int)pBoardType;

@end
