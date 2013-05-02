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
#import "TWTwitterHeader.h"
#import "UtilityClass.h"
#import "IDChangeViewController.h"
#import "SettingViewController.h"
#import "OAuthSetupViewController.h"
#import "WebViewExController.h"
#import <MediaPlayer/MediaPlayer.h>
#import "ResendViewController.h"
#import "FilteringImage.h"
#import "FPTRequest.h"
#import "BaseViewController.h"

#import <AssetsLibrary/AssetsLibrary.h>

@interface TweetViewController : BaseViewController <UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIActionSheetDelegate> {
    
    GrayView *grayView;
    
    NSUserDefaults *d;
    NSString *inReplyToId;
    
    UIView *clearView;
    UIButton *inputFunctionButton;
    UIPasteboard *pboard;
    UIImage *errorImage;
    
    ACAccount *twAccount;
    
    CGRect viewRect;
    CGRect svRect;
    CGRect imagePreviewRect;
    
    BOOL changeAccount;
    BOOL cameraMode;
    BOOL editMode;
    BOOL repeatedPost;
    BOOL resendMode;
    BOOL webBrowserMode;
    BOOL artWorkUploading;
    BOOL showActionSheet;
    BOOL showImagePicker;
    BOOL nowPlayingMode;
    BOOL iconUploadMode;
    BOOL showImageMode;
    BOOL cacheArtWorkSeted;
    
    int actionSheetNo;
}

@property (retain, nonatomic) ALAssetsLibrary *assetsLibrary;
@property (retain, nonatomic) NSMutableArray *groups;
@property (retain, nonatomic) NSMutableArray *assets;

@property (retain, nonatomic) UIImage *originalImage;

@property (retain, nonatomic) IBOutlet UIScrollView *sv;
@property (retain, nonatomic) IBOutlet UITextView *postText;
@property (retain, nonatomic) IBOutlet UILabel *callbackLabel;
@property (retain, nonatomic) IBOutlet UILabel *postCharLabel;
@property (retain, nonatomic) IBOutlet UILabel *pboardURLLabel;
@property (retain, nonatomic) IBOutlet UISwitch *callbackSwitch;
@property (retain, nonatomic) IBOutlet UISwitch *pboardURLSwitch;
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
@property (retain, nonatomic) IBOutlet UIBarButtonItem *nowPlayingButton;
@property (retain, nonatomic) IBOutlet UIBarButtonItem *browserButton;
@property (retain, nonatomic) IBOutlet UIBarButtonItem *actionButton;
@property (retain, nonatomic) IBOutlet UITapGestureRecognizer *tapGesture;
@property (retain, nonatomic) IBOutlet UISwipeGestureRecognizer *rigthSwipe;
@property (retain, nonatomic) IBOutlet UISwipeGestureRecognizer *leftSwipe;
@property (retain, nonatomic) IBOutlet UIButton *inputFunctionButton;
@property (retain, nonatomic) IBOutlet UIImageView *iconPreview;

- (IBAction)pushPostButton:(id)sender;
- (IBAction)pushTrashButton:(id)sender;
- (IBAction)pushSettingButton:(id)sender;
- (IBAction)pushImageSettingButton:(id)sender;
- (IBAction)pushIDButton:(id)sender;
- (IBAction)pushResendButton:(id)sender;
- (IBAction)pushNowPlayingButton:(id)sender;
- (IBAction)pushBrowserButton:(id)sender;
- (IBAction)pushInputFunctionButton:(id)sender;
- (IBAction)pushActionButton:(id)sender;

- (IBAction)callbackSwitchDidChage:(id)sender;
- (IBAction)pboardSwitchDidChage:(id)sender;

- (IBAction)svTapGesture:(UITapGestureRecognizer *)sender;
- (IBAction)svSwipeGesture:(UISwipeGestureRecognizer *)sender;
- (IBAction)imagePreviewTapGesture:(UITapGestureRecognizer *)sender;
- (IBAction)imagePreviewSwipeGesture:(UISwipeGestureRecognizer *)sender;
- (IBAction)swipeToMoveCursorRight:(UISwipeGestureRecognizer *)sender;
- (IBAction)swipeToMoveCursorLeft:(UISwipeGestureRecognizer *)sender;

- (void)loadSettings;
- (void)setBottomBarPosition;
- (void)showInfomation;
- (void)showImagePicker;
- (void)showActionMenu;
- (void)callback;
- (oneway void)countText;
- (void)tohaSearch:(NSString *)text;
- (oneway void)uploadImage:(UIImage *)image;
- (oneway void)uploadNowPlayingImage:(UIImage *)image uploadType:(int)uploadType;
- (void)postDone:(NSNotification *)center;
- (NSString *)nowPlaying;
- (void)setIconPreviewImage;
- (void)tapClearView:(UITapGestureRecognizer *)sender;

- (void)nowPlayingNotification;
- (void)tweetNotification:(int)pBoardType;
- (void)phototweetNotification:(int)pBoardType;
- (void)webPageShareNotification:(int)pBoardType;

- (void)saveArtworkUrl:(NSString *)url;

@end
