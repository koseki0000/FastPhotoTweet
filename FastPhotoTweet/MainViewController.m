//
//  MainViewController.m
//  FastPhotoTweet
//
//  Created by ktysne on 2013/06/30.
//
//

#import <AssetsLibrary/AssetsLibrary.h>
#import <MediaPlayer/MediaPlayer.h>
#import <QuartzCore/QuartzCore.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <SystemConfiguration/SystemConfiguration.h>
#import <CFNetwork/CFNetwork.h>
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"

#import "MainViewController.h"
#import "SettingViewController.h"
#import "IDChangeViewController.h"
#import "ResendViewController.h"
#import "WebViewExController.h"

#import "TWAccounts.h"
#import "TWTweets.h"
#import "TWIconUpload.h"
#import "FPTRequest.h"
#import "TWCharCounter.h"
#import "CheckAppVersion.h"
#import "ResizeImage.h"
#import "EncodeImage.h"
#import "UUIDEncryptor.h"
#import "InternetConnection.h"
#import "ShowAlert.h"
#import "SwipeShiftTextView.h"
#import "ActivityGrayView.h"
#import "ResizeImage.h"
#import "HankakuKana.h"

#import "NSString+WordCollect.h"
#import "NSObject+EmptyCheck.h"
#import "UIImage+Convert.h"
#import "NSNotificationCenter+EasyPost.h"

#define APP_VERSION [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]
#define ACCOUNT_IMAGEVIEW ((UIImageView *)self.accountIconView.customView)
#define COUNT_LABEL ((UILabel *)self.countLabel.customView)

@interface MainViewController () <UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextViewDelegate>

typedef enum {
    ActionSheetTypeImageMenu,
    ActionSheetTypeAction,
    ActionSheetTypeImagePicker,
    ActionSheetTypeImagePickerCheckRepeated,
    ActionSheetTypeHankakuKana,
} ActionSheetType;

typedef enum {
    ImageMenuTypeShow,
    ImageMenuTypeUpload,
    ImageMenuTypeRotateReset,
    ImageMenuTypeRotateLeft,
    ImageMenuTypeRotateRight,
    ImageMenuType4InchImageDeleteSpace,
    ImageMenuTypeDelete
} ImageMenuType;

@property (nonatomic, strong) UIToolbar *topBar;
@property (nonatomic, strong) UIBarButtonItem *resendButton;
@property (nonatomic, strong) UIBarButtonItem *postButton;
@property (nonatomic, strong) SwipeShiftTextView *textView;
@property (nonatomic, strong) UIToolbar *middleBar;
@property (nonatomic, strong) UIBarButtonItem *accountIconView;
@property (nonatomic, strong) UIBarButtonItem *countLabel;
@property (nonatomic, strong) UIImageView *previewImageView;
@property (nonatomic, strong) ActivityGrayView *grayView;
@property (nonatomic, strong) UIToolbar *bottomBar;

@property (nonatomic, strong) CheckAppVersion *checker;

@property (nonatomic, strong) ALAssetsLibrary *assetsLibrary;
@property (nonatomic, strong) NSMutableArray *groups;
@property (nonatomic, strong) NSMutableArray *assets;

@property (nonatomic, copy) NSString *inReplyToID;
@property (nonatomic, copy) NSString *deletedText;
@property (nonatomic) BOOL resendMode;
@property (nonatomic) BOOL webBrowserMode;
@property (nonatomic) BOOL nowPlayingImageUploading;
@property (nonatomic) BOOL iconUploadMode;
@property (nonatomic) BOOL repeatedPost;
@property (nonatomic) BOOL fastUpload;
@property (nonatomic) BOOL useCamera;

- (void)createControls;
- (void)addNotificationObservers;
- (void)loadSettings;
- (void)showInfomation;

- (void)setIconPreviewImage;
- (void)postDone:(NSNotification *)notification;

- (void)swipeTextView:(UISwipeGestureRecognizer *)sender;
- (void)swipePreviewImageView:(UISwipeGestureRecognizer *)sender;
- (void)tapPreviewImageView:(UITapGestureRecognizer *)sender;

- (void)imageMenu:(ImageMenuType)imageMenuType;
- (void)uploadImage:(UIImage *)image;
- (void)setTextViewText:(NSNotification *)notification;
- (void)pboardNotification:(NSNotification *)notification;
- (void)openImageSource:(NSInteger)buttonIndex;

- (NSString *)nowPlayingText;
- (void)saveArtworkURL:(NSString *)URL;

- (void)countText;

- (void)pushTrashButton;
- (void)pushAccountButton;
- (void)pushImageButton;
- (void)pushReSendButton;
- (void)pushPostButton;

- (void)inputMenu;

- (void)pushSettingsButton;
- (void)pushBrowserButton:(id)URLStringOrSender;
- (void)pushiPodButton;
- (void)pushActionButton;

@end

@implementation MainViewController

#pragma mark - Initialize

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    
    self = [super initWithNibName:nibNameOrNil
                           bundle:nibBundleOrNil];
    
    if (self) {
        
        self.title = NSLocalizedString(@"Tweet", @"Tweet");
        self.tabBarItem.image = [UIImage imageNamed:@"Bubble"];
        
        [self setInReplyToID:@""];
        [self setDeletedText:@""];
        [self setResendMode:NO];
        [self setWebBrowserMode:NO];
        [self setNowPlayingImageUploading:NO];
        [self setIconUploadMode:NO];
        [self setRepeatedPost:NO];
        [self setFastUpload:NO];
        [self setUseCamera:NO];
    }
    
    return self;
}

- (void)viewDidLoad {

    [super viewDidLoad];

    CheckAppVersion *checker = [[CheckAppVersion alloc] init];
    [self setChecker:checker];
    [checker versionInfoURL:@"http://fpt.ktysne.info/latest_version_info.txt"
               updateIpaURL:@"itms-services://?action=download-manifest&url=http://fpt.ktysne.info/FastPhotoTweet.plist"];
    
    [self createControls];
    [self loadSettings];
    [self addNotificationObservers];
    
    double delayInSeconds = 0.1;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
       
        [self showInfomation];
        [self.textView becomeFirstResponder];
    });
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    //アカウントアイコン再設定
    [self setIconPreviewImage];
    
    //再投稿
    if ( self.resendMode ) {
        
        if ( [[[TWTweets manager] text] isNotEmpty] ) {
            
            [self.textView setText:[[TWTweets manager] text]];
            [[TWTweets manager] setText:@""];
        }
        
        if ( [[[TWTweets manager] inReplyToID] isNotEmpty] ) {
            
            [self setInReplyToID:[[TWTweets manager] inReplyToID]];
            [[TWTweets manager] setInReplyToID:@""];
        }
        
        [self setResendMode:NO];
    }
    
    if ( self.webBrowserMode ) {
        
        [self setWebBrowserMode:NO];
    }
    
    if ( [[[TWTweets manager] sendedTweets] count] == 0 ) {
        
        [self.resendButton setEnabled:NO];
        
    } else {
        
        [self.resendButton setEnabled:YES];
    }
    
    //タブ切り替えの動作
    if ( [EmptyCheck check:[[TWTweets manager] tabChangeFunction]] ) {
        
        if ( [[[TWTweets manager] tabChangeFunction] isEqualToString:@"Post"] ) {
            
            [self.textView becomeFirstResponder];
        }
    }
    
    if ( [USER_DEFAULTS boolForKey:@"ShowKeyboard"] ) {
        
        [self.textView becomeFirstResponder];
    }
}

- (void)createControls {
    
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    //ツールバー上
    UIToolbar *topBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0.0f,
                                                                    0.0f,
                                                                    SCREEN_WIDTH,
                                                                    TOOL_BAR_HEIGHT)];
    [topBar setTintColor:OCEAN_COLOR];
    [topBar.layer setShadowOpacity:0.5f];
    [topBar.layer setShadowOffset:CGSizeMake(0.0f,
                                             2.0f)];
    [topBar.layer setMasksToBounds:NO];
    [topBar.layer setShadowPath:[UIBezierPath bezierPathWithRect:topBar.bounds].CGPath];
    [self setTopBar:topBar];
    
    //ゴミ箱
    UIBarButtonItem *trashButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"trash.png"]
                                                                    style:UIBarButtonItemStylePlain
                                                                   target:self
                                                                   action:@selector(pushTrashButton)];
    
    //アカウント
    UIBarButtonItem *accountButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"account.png"]
                                                                      style:UIBarButtonItemStylePlain
                                                                     target:self
                                                                     action:@selector(pushAccountButton)];
    
    //再投稿
    UIBarButtonItem *resendButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"reload.png"]
                                                                     style:UIBarButtonItemStylePlain
                                                                    target:self
                                                                    action:@selector(pushReSendButton)];
    [resendButton setEnabled:NO];
    [self setResendButton:resendButton];
    
    //画像
    UIBarButtonItem *imageButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"photo.png"]
                                                                    style:UIBarButtonItemStylePlain
                                                                   target:self
                                                                   action:@selector(pushImageButton)];
    
    //投稿
    UIBarButtonItem *postButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"compose.png"]
                                                                   style:UIBarButtonItemStylePlain
                                                                  target:self
                                                                  action:@selector(pushPostButton)];
    [self setPostButton:postButton];
    
    //スペース
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                                   target:nil
                                                                                   action:nil];
    [self.topBar setItems:@[
     trashButton,
     flexibleSpace,
     accountButton,
     flexibleSpace,
     resendButton,
     flexibleSpace,
     imageButton,
     flexibleSpace,
     postButton
     ]];
    
    //ツールバー下
    UIToolbar *bottomBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0.0f,
                                                                       SCREEN_HEIGHT - TAB_BAR_HEIGHT - TOOL_BAR_HEIGHT,
                                                                       SCREEN_WIDTH,
                                                                       TOOL_BAR_HEIGHT)];
    [bottomBar setTintColor:OCEAN_COLOR];
    [self setBottomBar:bottomBar];
    
    //設定
    UIBarButtonItem *settingsButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"setting.png"]
                                                                       style:UIBarButtonItemStylePlain
                                                                      target:self
                                                                      action:@selector(pushSettingsButton)];
    
    //ブラウザ
    UIBarButtonItem *browserButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"browser.png"]
                                                                      style:UIBarButtonItemStylePlain
                                                                     target:self
                                                                     action:@selector(pushBrowserButton:)];
    
    //iPod
    UIBarButtonItem *ipodButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ipod.png"]
                                                                   style:UIBarButtonItemStylePlain
                                                                  target:self
                                                                  action:@selector(pushiPodButton)];
    
    //機能
    UIBarButtonItem *actionButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"action.png"]
                                                                     style:UIBarButtonItemStylePlain
                                                                    target:self
                                                                    action:@selector(pushActionButton)];
    [self.bottomBar setItems:@[
     settingsButton,
     flexibleSpace,
     browserButton,
     flexibleSpace,
     ipodButton,
     flexibleSpace,
     actionButton
     ]];
    
    //入力欄
    SwipeShiftTextView *textView = [[SwipeShiftTextView alloc] initWithFrame:CGRectMake(0.0f,
                                                                                        CGRectGetMaxY(topBar.frame) + MINI_MARGIN,
                                                                                        SCREEN_WIDTH,
                                                                                        118.0f)];
    [textView setBackgroundColor:[UIColor colorWithWhite:1.0 alpha:0.4]];
    [textView setFont:[UIFont systemFontOfSize:14.0f]];
    [textView setDelegate:self];
    [textView setText:@""];
    [textView setTag:1000];
    [self setTextView:textView];
    
    UISwipeGestureRecognizer *swipeDown = [[UISwipeGestureRecognizer alloc] initWithTarget:self
                                                                                    action:@selector(swipeTextView:)];
    [swipeDown setDirection:UISwipeGestureRecognizerDirectionDown];
    [textView addGestureRecognizer:swipeDown];
    
    //中央バー
    UIToolbar *middleBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0.0f,
                                                                       CGRectGetMaxY(textView.frame),
                                                                       SCREEN_WIDTH,
                                                                       TOOL_BAR_HEIGHT)];
    [middleBar setTintColor:OCEAN_COLOR];
    [middleBar.layer setShadowOpacity:0.5f];
    [middleBar.layer setShadowOffset:CGSizeMake(0.0f,
                                                2.0f)];
    [middleBar.layer setMasksToBounds:NO];
    [middleBar.layer setShadowPath:[UIBezierPath bezierPathWithRect:middleBar.bounds].CGPath];
    [self setMiddleBar:middleBar];
    
    //アカウントアイコン
    UIImageView *accountIcon = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f,
                                                                             0.0f,
                                                                             32.0f,
                                                                             32.0f)];
    [accountIcon.layer setMasksToBounds:YES];
    [accountIcon.layer setCornerRadius:5.0f];
    
    UIBarButtonItem *accounIconItem = [[UIBarButtonItem alloc] initWithCustomView:accountIcon];
    [self setAccountIconView:accounIconItem];
    
    UIBarButtonItem *textUtilButton = [[UIBarButtonItem alloc] initWithTitle:@"⚒"
                                                                       style:UIBarButtonItemStylePlain
                                                                      target:self
                                                                      action:@selector(inputMenu)];
    
    UILabel *countLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f,
                                                                    0.0f,
                                                                    35.0f,
                                                                    18.0f)];
    [countLabel setTextAlignment:NSTextAlignmentRight];
    [countLabel setTextColor:[UIColor whiteColor]];
    [countLabel setText:@"140"];
    [countLabel setBackgroundColor:[UIColor clearColor]];
    [countLabel setFont:[UIFont boldSystemFontOfSize:16.0f]];
    [countLabel setShadowColor:[UIColor blackColor]];
    [countLabel setShadowOffset:CGSizeMake(0.0f,
                                           -0.5f)];
    
    UIBarButtonItem *countLabelItem = [[UIBarButtonItem alloc] initWithCustomView:countLabel];
    [self setCountLabel:countLabelItem];
    
    [middleBar setItems:@[
     accounIconItem,
     flexibleSpace,
     textUtilButton,
     flexibleSpace,
     countLabelItem,
     ]];
    
    //下部
    UIView *bottomView = [[UIView alloc] initWithFrame:CGRectMake(0.0f,
                                                                  CGRectGetMaxY(middleBar.frame),
                                                                  SCREEN_WIDTH,
                                                                  SCREEN_HEIGHT - CGRectGetMaxY(middleBar.frame) - TAB_BAR_HEIGHT - TOOL_BAR_HEIGHT)];
    [bottomView setBackgroundColor:[UIColor whiteColor]];
    
    //プレビュー
    UIImageView *previewImageView = [[UIImageView alloc] initWithFrame:CGRectMake(MAIN_MARGIN,
                                                                                  MINI_MARGIN,
                                                                                  CGRectGetWidth(bottomView.frame) - (MAIN_MARGIN * 2.0f),
                                                                                  CGRectGetHeight(bottomView.frame) - MAIN_MARGIN)];
    [previewImageView setContentMode:UIViewContentModeScaleAspectFit];
    [previewImageView setUserInteractionEnabled:YES];
    [self setPreviewImageView:previewImageView];
    
    UISwipeGestureRecognizer *previewImageViewSwipeLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self
                                                                                                    action:@selector(swipePreviewImageView:)];
    [previewImageViewSwipeLeft setDirection:UISwipeGestureRecognizerDirectionLeft];
    [previewImageView addGestureRecognizer:previewImageViewSwipeLeft];
    
    UISwipeGestureRecognizer *previewImageViewSwipeUp = [[UISwipeGestureRecognizer alloc] initWithTarget:self
                                                                                                  action:@selector(swipePreviewImageView:)];
    [previewImageViewSwipeUp setDirection:UISwipeGestureRecognizerDirectionUp];
    [previewImageView addGestureRecognizer:previewImageViewSwipeUp];
    
    UITapGestureRecognizer *previewImageViewTap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                          action:@selector(tapPreviewImageView:)];
    [previewImageView addGestureRecognizer:previewImageViewTap];
    
    UISwipeGestureRecognizer *previewImageViewSwipeDown = [[UISwipeGestureRecognizer alloc] initWithTarget:self
                                                                                                    action:@selector(swipePreviewImageView:)];
    [previewImageViewSwipeDown setDirection:UISwipeGestureRecognizerDirectionDown];
    [previewImageView addGestureRecognizer:previewImageViewSwipeDown];
    
    ActivityGrayView *grayView = [[ActivityGrayView alloc] init];
    [self setGrayView:grayView];
    
    //AddSubviews
    [self.view addSubview:textView];
    [self.view addSubview:bottomView];
    [bottomView addSubview:previewImageView];
    [self.view addSubview:topBar];
    [self.view addSubview:middleBar];
    [self.view addSubview:bottomBar];
    [self.view addSubview:grayView];
}

- (void)addNotificationObservers {
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(setTextViewText:)
                                                 name:@"SetTweetViewText"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(postDone:)
                                                 name:POST_DONE_NOTIFICATION
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(pboardNotification:)
                                                 name:@"pboardNotification"
                                               object:nil];
}

- (void)loadSettings {
    
    if ( ![EmptyCheck check:[USER_DEFAULTS objectForKey:@"UUID"]] ) {
        
        //UUIDを生成して保存
        CFUUIDRef uuidObj = CFUUIDCreate(kCFAllocatorDefault);
        NSString *uuidString = (__bridge  NSString *)CFUUIDCreateString(nil, uuidObj);
        CFRelease(uuidObj);
        
        [USER_DEFAULTS setObject:uuidString forKey:@"UUID"];
    }
    
    if ( ![EmptyCheck check:[USER_DEFAULTS objectForKey:@"CallBackScheme"]] ) {
        
        //スキームが保存されていない場合FPTを設定
        [USER_DEFAULTS setObject:@"FPT" forKey:@"CallBackScheme"];
    }
    
    //画像形式が設定されていない場合JPGを設定
    if ( ![EmptyCheck check:[USER_DEFAULTS objectForKey:@"SaveImageType"]] ) {
        [USER_DEFAULTS setObject:@"JPG" forKey:@"SaveImageType"];
    }
    
    //リサイズ最大長辺が設定されていない場合640を設定
    if ( [USER_DEFAULTS integerForKey:@"ImageMaxSize"] == 0 ) {
        [USER_DEFAULTS setInteger:640 forKey:@"ImageMaxSize"];
    }
    
    //カスタム書式が設定されていない場合デフォルト書式を設定
    if ( ![EmptyCheck check:[USER_DEFAULTS objectForKey:@"NowPlayingEditText"]] ) {
        [USER_DEFAULTS setObject:@" #nowplaying : [st] - [ar] - [at] - " forKey:@"NowPlayingEditText"];
    }
    
    //サブ書式が設定されていない場合デフォルト書式を設定
    if ( ![EmptyCheck check:[USER_DEFAULTS objectForKey:@"NowPlayingEditTextSub"]] ) {
        [USER_DEFAULTS setObject:@" #nowplaying : [st] - [ar] - " forKey:@"NowPlayingEditTextSub"];
    }
    
    //写真投稿先が設定されていない場合Twitterを設定
    if ( ![EmptyCheck check:[USER_DEFAULTS objectForKey:@"PhotoService"]] ) {
        [USER_DEFAULTS setObject:@"Twitter" forKey:@"PhotoService"];
    }
    
    //Webページ投稿書式が設定されていない場合はデフォルトの書式を設定
    if ( ![EmptyCheck check:[USER_DEFAULTS objectForKey:@"WebPagePostFormat"]] ) {
        [USER_DEFAULTS setObject:@" \"[title]\" [url] " forKey:@"WebPagePostFormat"];
    }
    
    //UserAgentが設定されていない場合はiPhoneを設定
    if ( ![EmptyCheck check:[USER_DEFAULTS objectForKey:@"UserAgent"]] ) {
        [USER_DEFAULTS setObject:@"iPhone" forKey:@"UserAgent"];
    }
    
    //UserAgentを戻す設定がされていない場合はOFFを設定
    if ( ![EmptyCheck check:[USER_DEFAULTS objectForKey:@"UserAgentReset"]] ) {
        [USER_DEFAULTS setObject:@"OFF" forKey:@"UserAgentReset"];
    }
    
    if ( ![EmptyCheck check:[USER_DEFAULTS dictionaryForKey:@"ArtworkUrl"]] ) {
        [USER_DEFAULTS setObject:[NSDictionary dictionary] forKey:@"ArtworkUrl"];
    }
    
    if ( [USER_DEFAULTS integerForKey:@"IconCornerRounding"] == 0 ) {
        [USER_DEFAULTS setInteger:1 forKey:@"IconCornerRounding"];
    }
    
    if ( [USER_DEFAULTS objectForKey:@"TimelineLoadCount"] == nil ) {
        [USER_DEFAULTS setObject:@"80" forKey:@"TimelineLoadCount"];
    }
    
    if ( [USER_DEFAULTS objectForKey:@"MentionsLoadCount"] == nil ) {
        [USER_DEFAULTS setObject:@"40" forKey:@"MentionsLoadCount"];
    }
    
    if ( [USER_DEFAULTS objectForKey:@"FavoritesLoadCount"] == nil ) {
        [USER_DEFAULTS setObject:@"40" forKey:@"FavoritesLoadCount"];
    }
    
    if ( [USER_DEFAULTS dictionaryForKey:@"TimelineList"] == nil ) {
        
        NSMutableDictionary *accounts = [NSMutableDictionary dictionary];
        
        for ( ACAccount *account in [[TWAccounts manager] twitterAccounts] ) {
            
            [accounts setObject:@"" forKey:account.username];
        }
        
        [USER_DEFAULTS setObject:accounts forKey:@"TimelineList"];
        
    } else {
        
        NSMutableDictionary *accounts = [[USER_DEFAULTS objectForKey:@"TimelineList"] mutableCopy];
        
        for ( ACAccount *account in [[TWAccounts manager] twitterAccounts] ) {
            
            if ( accounts[account.username] == nil ) {
                
                [accounts setObject:@"" forKey:account.username];
            }
        }
        
        [USER_DEFAULTS setObject:accounts forKey:@"TimelineList"];
    }
    
    if ( [USER_DEFAULTS objectForKey:@"IconQuality"] == nil ) {
        [USER_DEFAULTS setObject:@"Bigger" forKey:@"IconQuality"];
    }
    
    //設定を即反映
    [USER_DEFAULTS synchronize];
}

- (void)showInfomation {
    
    BOOL check = YES;
    NSMutableDictionary *information = nil;
    
    if ( ![EmptyCheck check:[USER_DEFAULTS dictionaryForKey:@"Information"]] ) {
        
        [USER_DEFAULTS setObject:[NSDictionary dictionary] forKey:@"Information"];
    }
    
    while ( check ) {
        
        if ( [[USER_DEFAULTS dictionaryForKey:@"Information"] valueForKey:@"FirstRun"] == 0 ) {
            
            [ShowAlert title:@"ようこそ"
                     message:@"FastPhotoTweetへようこそ\nアプリ内やタスクスイッチャーから様々なTweetを素早くTwitterに投稿する事が出来ます。"];
            
            information = [[NSMutableDictionary alloc] initWithDictionary:[USER_DEFAULTS dictionaryForKey:@"Information"]];
            [information setValue:[NSNumber numberWithInt:1] forKey:@"FirstRun"];
            
            NSDictionary *dic = [[NSDictionary alloc] initWithDictionary:information];
            [USER_DEFAULTS setObject:dic forKey:@"Information"];
            
            //推奨設定
            [USER_DEFAULTS setBool:YES forKey:@"ResizeImage"];
            [USER_DEFAULTS setInteger:800 forKey:@"ImageMaxSize"];
            [USER_DEFAULTS setObject:@"JPG(High)" forKey:@"SaveImageType"];
            [USER_DEFAULTS setBool:YES forKey:@"NoResizeIphone4Ss"];
            [USER_DEFAULTS setBool:YES forKey:@"FullSizeImage"];
            [USER_DEFAULTS setBool:YES forKey:@"NowPlayingArtWork"];
            [USER_DEFAULTS setBool:YES forKey:@"OpenPasteBoardURL"];
            [USER_DEFAULTS setBool:YES forKey:@"SwipeShiftCaret"];
            [USER_DEFAULTS setBool:YES forKey:@"EnterBackgroundUSDisConnect"];
            [USER_DEFAULTS setBool:YES forKey:@"BecomeActiveUSConnect"];
            [USER_DEFAULTS setBool:YES forKey:@"ReloadAfterUSConnect"];
            
            continue;
        }
        
        if ( [[USER_DEFAULTS dictionaryForKey:@"Information"] valueForKey:APP_VERSION] == 0 ) {
            
            [ShowAlert title:[NSString stringWithFormat:@"FastPhotoTweet %@", APP_VERSION]
                     message:@"・NowPlaying時にアートワークが自動アップロードされない問題を修正\n・画像連続投稿機能の再実装\n・カメラから画像投稿した際に画像が保存されない問題を修正\n・ペーストボード監視がTLで動作していない問題を修正\n・カメラロール、カメラから即アップロード出来る選択肢を追加\n・再投稿に関する問題を修正\n・ゴミ箱ボタン2度押しで削除取り消し出来る機能を追加\n・その他細かなバグ修正とレスポンス改善"];
            
            information = [[NSMutableDictionary alloc] initWithDictionary:[USER_DEFAULTS dictionaryForKey:@"Information"]];
            [information setValue:[NSNumber numberWithInt:1] forKey:APP_VERSION];
            
            NSDictionary *dic = [[NSDictionary alloc] initWithDictionary:information];
            [USER_DEFAULTS setObject:dic forKey:@"Information"];
            continue;
        }
        
        check = NO;
    }
    
    //設定を即反映
    [USER_DEFAULTS synchronize];
}

#pragma mark - Gestures

- (void)swipeTextView:(UISwipeGestureRecognizer *)sender {
    
    if ( sender.direction == UISwipeGestureRecognizerDirectionDown ) {
        
        [self.textView resignFirstResponder];
    }
}

- (void)swipePreviewImageView:(UISwipeGestureRecognizer *)sender {
    
    NSLog(@"%s", __func__);
    
    if ( sender.direction == UISwipeGestureRecognizerDirectionLeft ) {
     
        [self.tabBarController setSelectedIndex:1];
        
    } else if ( sender.direction == UISwipeGestureRecognizerDirectionUp ) {
        
        if ( self.previewImageView.image ) {
        
            [self uploadImage:self.previewImageView.image];
        }
    
    } else if ( sender.direction == UISwipeGestureRecognizerDirectionDown ) {
        
        [self.textView resignFirstResponder];
    }
}

- (void)tapPreviewImageView:(UITapGestureRecognizer *)sender {
    
    NSLog(@"%s", __func__);
    
    [self.textView resignFirstResponder];
    
    if ( self.previewImageView.image ) {
        
        UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"画像メニュー"
                                                           delegate:self
                                                  cancelButtonTitle:@"キャンセル"
                                             destructiveButtonTitle:nil
                                                  otherButtonTitles:
                                @"画像を表示", @"画像アップロード", @"画像回転をリセット", @"画像を左に90度回転",
                                @"画像を右に90度回転", @"4-inch画像の両端を削除", @"画像を削除", nil];
        [sheet setTag:ActionSheetTypeImageMenu];
        [sheet showInView:self.tabBarController.view];
    }
}

#pragma mark - Views

- (void)setIconPreviewImage {
    
    NSArray *iconsDirectory = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:ICONS_DIRECTORY
                                                                                  error:nil];
    NSString *searchName = [NSString stringWithFormat:@"%@-", [TWAccounts currentAccountName]];
    
    if ( [searchName isNotEmpty] ) {
        
        //アイコンが見つかったか
        BOOL find = NO;
        
        for ( NSString *name in iconsDirectory ) {
            
            if ( [name hasPrefix:searchName] ) {
                
                UIImage *image = [UIImage imageWithContentsOfFileByContext:[ICONS_DIRECTORY stringByAppendingPathComponent:name]];
                [ACCOUNT_IMAGEVIEW setImage:image];
                find = YES;
                break;
            }
        }
        
        //アイコンが見つからなかった場合はnilをセット
        if ( !find ) {
         
            ACCOUNT_IMAGEVIEW.image = nil;
        }
    }
}

- (void)postDone:(NSNotification *)notification {
    
    NSString *result = notification.name;
    
    if ( [result isEqualToString:POST_DONE_NOTIFICATION] ||
         [result isEqualToString:POST_WITH_MEDIA_DONE_NOTIFICATION] ) {
        
        //投稿成功
        NSString *sendedText = notification.userInfo[@"SendedText"];
        
        NSUInteger index = 0;
        BOOL find = NO;
        for ( NSDictionary *savedData in [[TWTweets manager] sendedTweets] ) {
            
            NSString *text = savedData[@"Parameters"][@"status"];
            text = [text deleteWhiteSpace];
            
            if ( [text isEqualToString:sendedText] ) {
                
                find = YES;
                break;
            }
            
            index++;
        }
        
        if ( find ) {
            
            [[[TWTweets manager] sendedTweets] removeObjectAtIndex:index];
        }
        
        [NSNotificationCenter postNotificationCenterForName:@"AddStatusBarTask"
                                               withUserInfo:@{@"Task" : @"Tweet Sended"}];
        
    }else if ( [result isEqualToString:POST_API_ERROR_NOTIFICATION] ) {
        
        [NSNotificationCenter postNotificationCenterForName:@"AddStatusBarTask"
                                               withUserInfo:@{@"Task" : @"Tweet Error"}];
        
        [ShowAlert error:@"投稿に失敗しました。失敗したPostは上部中央のボタンから再投稿出来ます。"];
    }
    
    //再投稿ボタンの有効･無効切り替え
    if ( [[[TWTweets manager] sendedTweets] count] == 0 ) {
        
        [self.resendButton setEnabled:NO];
        
    } else {
        
        [self.resendButton setEnabled:YES];
    }
}

#pragma mark - ActionSheet

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    NSLog(@"%s", __func__);
    
    if ( buttonIndex == actionSheet.cancelButtonIndex ) {
        
        return;
    }
    
    if ( actionSheet.tag == ActionSheetTypeImageMenu ) {
        
        [self imageMenu:buttonIndex];
        
    } else if ( actionSheet.tag == ActionSheetTypeAction ) {
        
        [self setIconUploadMode:YES];
        [self pushImageButton];
        
    } else if ( actionSheet.tag == ActionSheetTypeImagePicker ) {
        
        [self openImageSource:buttonIndex];
    
    } else if ( actionSheet.tag == ActionSheetTypeImagePickerCheckRepeated ) {
        
        if ( buttonIndex == 0 ) {
            
            [self setRepeatedPost:YES];
            [self openImageSource:0];
            
        } else if ( buttonIndex == 1 ) {
            
            UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"投稿画像ソース"
                                                               delegate:self
                                                      cancelButtonTitle:@"キャンセル"
                                                 destructiveButtonTitle:nil
                                                      otherButtonTitles:
                                    @"カメラロール", @"カメラロール(即)", @"カメラ", @"カメラ(即)", @"カメラロールの最新", nil];
            [sheet setTag:ActionSheetTypeImagePicker];
            [sheet showInView:self.tabBarController.view];
        }
        
    }else if ( actionSheet.tag == ActionSheetTypeHankakuKana ) {
        
        if ( buttonIndex == 0 ) {
            
            [self.textView setText:[HankakuKana kana:self.textView.text]];
            
        } else if ( buttonIndex == 1 ) {
            
            [self.textView setText:[HankakuKana hiragana:self.textView.text]];
            
        } else if ( buttonIndex == 2 ) {
            
            [self.textView setText:[HankakuKana kanaHiragana:self.textView.text]];
        
        } else if ( buttonIndex == 3 ) {
            
            NSString *pasteboardString = [[UIPasteboard generalPasteboard] string];
            if ( [pasteboardString isNotEmpty] ) {
                
                [self.textView setText:[NSString stringWithFormat:@"%@%@", self.textView.text, pasteboardString]];
            }
            
        } else if ( buttonIndex == 4 ) {
            
            [[UIPasteboard generalPasteboard] setString:self.textView.text];
        }
    }
}

#pragma mark - ImagePicker

- (void)imagePickerController:(UIImagePickerController *)picPicker
        didFinishPickingImage:(UIImage *)image
                  editingInfo:(NSDictionary *)editingInfo {
    
    NSLog(@"%s", __func__);
    
    double delayInSeconds = 0.5;
    
    if ( self.repeatedPost ) {
        
        delayInSeconds = 0.1;
        
    } else {
        
        [picPicker dismissViewControllerAnimated:YES
                                      completion:nil];
    }
    
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        
        [self.previewImageView setImage:image];
        
        if ( self.useCamera ) {
            
            dispatch_queue_t imageSaveQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
            dispatch_async(imageSaveQueue, ^{
               
                UIImageWriteToSavedPhotosAlbum(image,
                                               self,
                                               @selector(savingImageIsFinished:didFinishSavingWithError:contextInfo:),
                                               nil);
            });
        }
        
        if ( self.iconUploadMode ) {
         
            [self setIconUploadMode:NO];
            [TWIconUpload image:[ResizeImage aspectResizeForMaxSize:self.previewImageView.image
                                                            maxSize:256.0f]];
        }
        
        if ( self.repeatedPost ||
             self.fastUpload ) {
            
            [self uploadImage:self.previewImageView.image];
        }
    });
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picPicker {
    
    NSLog(@"%s", __func__);
    
    [picPicker dismissViewControllerAnimated:YES
                                  completion:nil];
    
    if ( self.iconUploadMode ) {
        
        [self setIconUploadMode:NO];
    }
}

- (void)savingImageIsFinished:(UIImage *)image
     didFinishSavingWithError:(NSError *)error
                  contextInfo:(void *)contextInfo {
}

#pragma mark - ImageMenu

- (void)imageMenu:(ImageMenuType)imageMenuType {
    
    NSLog(@"%s", __func__);
    
    if ( imageMenuType == ImageMenuTypeShow ) {
        
    } else if ( imageMenuType == ImageMenuTypeUpload ) {
        
        [self uploadImage:self.previewImageView.image];
        
    } else if ( imageMenuType == ImageMenuTypeRotateReset ) {
        
        [self.previewImageView setImage:[UIImage imageWithCGImage:self.previewImageView.image.CGImage
                                                            scale:self.previewImageView.image.scale
                                                      orientation:UIImageOrientationUp]];
        
    } else if ( imageMenuType == ImageMenuTypeRotateLeft ) {
        
        [self.previewImageView setImage:[UIImage imageWithCGImage:self.previewImageView.image.CGImage
                                                            scale:self.previewImageView.image.scale
                                                      orientation:UIImageOrientationLeft]];
        
    } else if ( imageMenuType == ImageMenuTypeRotateRight ) {
        
        [self.previewImageView setImage:[UIImage imageWithCGImage:self.previewImageView.image.CGImage
                                                            scale:self.previewImageView.image.scale
                                                      orientation:UIImageOrientationRight]];
        
    } else if ( imageMenuType == ImageMenuType4InchImageDeleteSpace ) {
        
        CGFloat cutSize = 44.0f;
        CGFloat width = self.previewImageView.image.size.width;
        CGFloat height = self.previewImageView.image.size.height;
        CGFloat scale = [[UIScreen mainScreen] scale];
        UIImage *cuttedImage = nil;
        
        if ( width == height ) {
            
            //正方形
            return;
        }
        
        if ( width < height ) {
            
            //縦長
            CGFloat cuttedHeight = height - (cutSize * 4.0f);
            CGRect scaledRect = CGRectMake(0.0f,
                                           cutSize * scale,
                                           SCREEN_WIDTH * scale,
                                           cuttedHeight);
            CGImageRef clip = CGImageCreateWithImageInRect(self.previewImageView.image.CGImage,
                                                           scaledRect);
            cuttedImage = [UIImage imageWithCGImage:clip
                                              scale:scale
                                        orientation:UIImageOrientationUp];
            CGImageRelease(clip);
            
        } else {
            
            //横長
            CGFloat cuttedWidth = width - (cutSize * 4.0f);
            CGRect scaledRect = CGRectMake(cutSize * scale,
                                           0.0f,
                                           cuttedWidth,
                                           SCREEN_HEIGHT * scale);
            CGImageRef clip = CGImageCreateWithImageInRect(self.previewImageView.image.CGImage,
                                                           scaledRect);
            cuttedImage = [UIImage imageWithCGImage:clip
                                              scale:scale
                                        orientation:UIImageOrientationUp];
            CGImageRelease(clip);
        }
        
        if ( cuttedImage ) {
         
            [self.previewImageView setImage:cuttedImage];
        }
        
    } else if ( imageMenuType == ImageMenuTypeDelete ) {    
        
        [self.previewImageView setImage:nil];
    }
}

- (NSData *)optimizeImage:(UIImage *)image {
    
    if ( [[NSUserDefaults standardUserDefaults] boolForKey:@"ResizeImage"] ) {
        
        return [EncodeImage image:[ResizeImage aspectResize:image]];
        
    } else {
        
        return [EncodeImage image:image];
    }
}

- (void)uploadImage:(UIImage *)image {
    
    NSLog(@"%s", __func__);
    
    if ( [[USER_DEFAULTS objectForKey:@"PhotoService"] isEqualToString:@"Twitter"] ) {
        
        [ShowAlert error:@"Twitterへの画像投稿は本文と同時に送信されます。"];
        return;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
       
        [self.grayView start];
        [self.textView resignFirstResponder];
    });
    
    //画像をリサイズするか判定
    if ( [USER_DEFAULTS boolForKey:@"ResizeImage"] ) {
        
        //リサイズを行う
        image = [ResizeImage aspectResize:image];
    }
    
    //UIImageをNSDataに変換
    NSData *imageData = [EncodeImage image:image];
    
    //リクエストURLを指定
    NSURL *URL = nil;
    
    if ( [[USER_DEFAULTS objectForKey:@"PhotoService"] isEqualToString:@"img.ur"] ) {
        
        URL = [NSURL URLWithString:@"http://api.imgur.com/2/upload.json"];
        
    }else if ( [[USER_DEFAULTS objectForKey:@"PhotoService"] isEqualToString:@"Twitpic"] ) {
        
        URL = [NSURL URLWithString:@"http://api.twitpic.com/1/upload.json"];
    }
    
    if ( URL == nil ) {
        
        return;
    }
    
    ASIFormDataRequest *request = [[ASIFormDataRequest alloc] initWithURL:URL];
    
    if ( [[USER_DEFAULTS objectForKey:@"PhotoService"] isEqualToString:@"img.ur"] ) {
        
        //NSLog(@"img.ur upload");
        
        [request addPostValue:IMGUR_API_KEY forKey:@"key"];
        [request addData:imageData forKey:@"image"];

    } else if ( [[USER_DEFAULTS objectForKey:@"PhotoService"] isEqualToString:@"Twitpic"] ) {
        
        //NSLog(@"Twitpic upload");
        
        ACAccount *twAccount = [TWAccounts currentAccount];
        NSDictionary *dic = [USER_DEFAULTS dictionaryForKey:@"OAuthAccount"];
        
        if ( [EmptyCheck check:[dic objectForKey:twAccount.username]] ) {
            
            NSString *key    = [UUIDEncryptor decryption:dic[twAccount.username][0]];
            NSString *secret = [UUIDEncryptor decryption:dic[twAccount.username][1]];
            
            [request addPostValue:TWITPIC_API_KEY forKey:@"key"];
            [request addPostValue:OAUTH_KEY forKey:@"consumer_token"];
            [request addPostValue:OAUTH_SECRET forKey:@"consumer_secret"];
            [request addPostValue:key forKey:@"oauth_token"];
            [request addPostValue:secret forKey:@"oauth_secret"];
            [request addPostValue:self.textView.text forKey:@"message"];
            [request addData:imageData forKey:@"media"];
            
        } else {
            
            [USER_DEFAULTS setObject:@"img.ur" forKey:@"PhotoService"];
            
            [request setURL:[NSURL URLWithString:@"http://api.imgur.com/2/upload.json"]];
            [request addPostValue:IMGUR_API_KEY forKey:@"key"];
            [request addData:imageData forKey:@"image"];
            
            [ShowAlert error:[NSString stringWithFormat:@"%@のTwitpicアカウントが見つからなかったためimg.urに投稿しました。", twAccount.username]];
        }
    }
    
    [request setDelegate:self];
    [request start];
}

- (void)setTextViewText:(NSNotification *)notification {
    
    NSDictionary *userInfo = notification.userInfo;
    if ( [userInfo isNotEmpty] ) {
     
        NSString *text = userInfo[@"Text"];
        if ( text ) {
         
            [self.textView setText:[NSString stringWithFormat:@"%@%@", self.textView.text, text]];
            [self.textView becomeFirstResponder];
        }
        
        NSString *inReplyToID = userInfo[@"InReplyToID"];
        if ( inReplyToID ) {
            
            [self setInReplyToID:inReplyToID];
        }
        
        [self countText];
    }
}

- (void)pboardNotification:(NSNotification *)notification {
    
    [self.tabBarController setSelectedIndex:0];
    [self pushBrowserButton:[notification.userInfo objectForKey:@"pboardURL"]];
}

- (void)openImageSource:(NSInteger)buttonIndex {
    
    UIImagePickerController *picPicker = [[UIImagePickerController alloc] init];
    [picPicker setDelegate:self];
    
    if ( buttonIndex == 1 ||
         buttonIndex == 3 ) {
        
        [self setFastUpload:YES];
    }
    
    if ( buttonIndex == 0 ||
         buttonIndex == 1 ) {
        
        picPicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        [self showModalViewController:picPicker];
        
    } else if ( buttonIndex == 2 ||
                buttonIndex == 3 ) {
        
        if ( [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] ) {
            
            [self setUseCamera:YES];
            picPicker.sourceType = UIImagePickerControllerSourceTypeCamera;
            
        } else {
        
            picPicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            [ShowAlert error:@"カメラが利用できない端末です。カメラロールを開きます。"];
        }
        
        [self showModalViewController:picPicker];
        
    } else if ( buttonIndex == 4 ) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if ( !self.assets ) {
                
                self.assets = [NSMutableArray array];
                
            } else {
                
                [self.assets removeAllObjects];
            }
            
            if ( !self.groups ) {
                
                self.groups = [NSMutableArray array];
                
            } else {
                
                [self.groups removeAllObjects];
            }
            
            if ( !self.assetsLibrary ) {
                
                self.assetsLibrary = [[ALAssetsLibrary alloc] init];
            }
            
            [self.assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos
                                              usingBlock:^(ALAssetsGroup *assetsGroup,
                                                           BOOL *stop) {
                                                  
                                                  if ( assetsGroup ) {
                                                      
                                                      [self.groups addObject:assetsGroup];
                                                      
                                                      ALAssetsGroupEnumerationResultsBlock resultBlock = ^(ALAsset *asset,
                                                                                                           NSUInteger index,
                                                                                                           BOOL *stop) {
                                                          
                                                          if ( asset ) {
                                                              
                                                              [self.assets addObject:asset];
                                                              *stop = YES;
                                                              
                                                          } else {
                                                              
                                                              if ( self.assets.count != 0 ) {
                                                                  
                                                                  ALAsset *asset = (ALAsset *)[self.assets objectAtIndex:0];
                                                                  ALAssetRepresentation *representation = [asset defaultRepresentation];
                                                                  UIImage *image = [UIImage imageWithCGImage:[representation fullResolutionImage]
                                                                                                       scale:[representation scale]
                                                                                                 orientation:[representation orientation]];
                                                                  [self.previewImageView setImage:image];
                                                                  
                                                              } else {
                                                                  
                                                                  [ShowAlert error:@"画像が取得出来ません。"];
                                                              }
                                                          }
                                                      };
                                                      
                                                      ALAssetsGroup *group = (ALAssetsGroup *)[self.groups objectAtIndex:0];
                                                      [self.assets removeAllObjects];
                                                      
                                                      [group setAssetsFilter:[ALAssetsFilter allPhotos]];
                                                      [group enumerateAssetsWithOptions:NSEnumerationReverse
                                                                             usingBlock:resultBlock];
                                                  };
                                              }
             
                                            failureBlock:nil
             ];
        });
    }
}

- (void)requestFinished:(ASIHTTPRequest *)request {

    NSLog(@"%s", __func__);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [self.grayView end];
    });
    
    NSError *jsonError = nil;
    NSDictionary *result = [NSJSONSerialization JSONObjectWithData:request.responseData
                                                           options:NSJSONReadingMutableLeaves
                                                             error:&jsonError];
    
    if ( !jsonError ) {
        
        NSString *imageURL = nil;
        
        if ( [[USER_DEFAULTS objectForKey:@"PhotoService"] isEqualToString:@"img.ur"] ) {
            
            imageURL = [[[result objectForKey:@"upload"] objectForKey:@"links"] objectForKey:@"original"];
            
        }else if ( [[USER_DEFAULTS objectForKey:@"PhotoService"] isEqualToString:@"Twitpic"] ) {
            
            imageURL = [result objectForKey:@"url"];
        }
        
        if ( imageURL == nil ) {
            
            [self requestFailed:request];
            return;
        }
        
        NSRange beforerange = self.textView.selectedRange;
        
        [self.textView setText:[NSString stringWithFormat:@"%@ %@ ", self.textView.text, imageURL]];
        [self.textView setText:[self.textView.text replaceWord:@"  " replacedWord:@" "]];
        [self.textView becomeFirstResponder];
        [self.textView setSelectedRange:beforerange];
        
        if ( self.nowPlayingImageUploading ) {
            
            [self saveArtworkURL:imageURL];
        }
    }
}

- (void)requestFailed:(ASIHTTPRequest *)request {
    
    NSLog(@"%s", __func__);
    
    if ( self.nowPlayingImageUploading ) {
        
        [self setNowPlayingImageUploading:NO];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
       
        [self.grayView end];
    });
}

- (void)textViewDidChange:(UITextView *)textView {
    
    [self countText];
}

#pragma mark - NowPlaying

- (NSString *)nowPlayingText {
    
    NSMutableString *resultText = [NSMutableString string];
    
    MPMusicPlayerController *player = [MPMusicPlayerController iPodMusicPlayer];
    NSString *songTitle = [player.nowPlayingItem valueForProperty:MPMediaItemPropertyTitle];
    NSString *songArtist = [player.nowPlayingItem valueForProperty:MPMediaItemPropertyArtist];
    NSString *albumTitle = [player.nowPlayingItem valueForProperty:MPMediaItemPropertyAlbumTitle];
    NSNumber *playCount = [player.nowPlayingItem valueForProperty:MPMediaItemPropertyPlayCount];
    NSNumber *ratingNum = [player.nowPlayingItem valueForProperty:MPMediaItemPropertyRating];
    
    if ( songTitle == nil ) {
        
        return @"";
    }
    
    NSString *URL = nil;
    BOOL nowPlayingArtWork = [USER_DEFAULTS boolForKey:@"NowPlayingArtWork"];
    if ( nowPlayingArtWork ) {
        
        NSString *searchKey = [NSString stringWithFormat:@"%@ - %@ - %@", songTitle, songArtist, albumTitle];
        NSDictionary *artWorkURLs = [USER_DEFAULTS dictionaryForKey:@"ArtworkUrl"];
        
        for ( NSString *key in artWorkURLs ) {
            
            if ( [key isEqualToString:searchKey] ) {
                
                URL = [artWorkURLs objectForKey:key];
                break;
            }
        }
        
        MPMediaItemArtwork *artwork = [player.nowPlayingItem valueForProperty:MPMediaItemPropertyArtwork];
        
        if ( artwork ) {
         
            CGSize imageMaxSize = CGSizeMake(500.0f,
                                             500.0f);
            [self.previewImageView setImage:[ResizeImage aspectResizeForMaxSize:[artwork imageWithSize:imageMaxSize]
                                                                        maxSize:500.0f]];
            
            if ( URL == nil ||
                [URL isEmpty] ) {
             
                NSUInteger uploadType = [USER_DEFAULTS integerForKey:@"NowPlayingPhotoService"];
                
                if ( uploadType == 0 ) {
                    
                    uploadType = [USER_DEFAULTS integerForKey:@"PhotoService"];
                }
                
                //アップロード先がTwitter以外
                if ( uploadType != 1 ) {
                    
                    //アートワークをアップロード
                    [self setNowPlayingImageUploading:YES];
                    [self uploadImage:self.previewImageView.image];
                }
            }
        }
    }
    
    NSUInteger playCountInt = [playCount unsignedIntegerValue];
    NSString *playCountStr = [NSString stringWithFormat:@"%d", playCountInt];
    
    NSUInteger rating = [ratingNum unsignedIntegerValue];
    NSString *ratingStr = [NSString stringWithFormat:@"%d", rating];
    
    if ([ratingStr isEqualToString:@"0"]) {
        ratingStr = @"☆☆☆☆☆";
    }else if ([ratingStr isEqualToString:@"1"]) {
        ratingStr = @"★☆☆☆☆";
    }else if ([ratingStr isEqualToString:@"2"]) {
        ratingStr = @"★★☆☆☆";
    }else if ([ratingStr isEqualToString:@"3"]) {
        ratingStr = @"★★★☆☆";
    }else if ([ratingStr isEqualToString:@"4"]) {
        ratingStr = @"★★★★☆";
    }else if ([ratingStr isEqualToString:@"5"]) {
        ratingStr = @"★★★★★";
    }
    
    if ( [USER_DEFAULTS boolForKey:@"NowPlayingEdit"] ) {
        
        resultText = [NSMutableString stringWithString:[USER_DEFAULTS stringForKey:@"NowPlayingEditText"]];
        
        if ( [USER_DEFAULTS boolForKey:@"NowPlayingEditSub"] != 0 ) {
            
            //サブ書式使用設定が完全一致かつ条件に当てはまる場合
            if ( [USER_DEFAULTS integerForKey:@"NowPlayingEditSub"] == 2 && [albumTitle isEqualToString:songTitle] ) {
                
                resultText = [NSMutableString stringWithString:[USER_DEFAULTS stringForKey:@"NowPlayingEditTextSub"]];
                
                //サブ書式使用設定が前方一致かつ条件に当てはまる場合
            }else if ( [USER_DEFAULTS integerForKey:@"NowPlayingEditSub"] == 1 && [albumTitle hasPrefix:songTitle] ) {
                
                resultText = [NSMutableString stringWithString:[USER_DEFAULTS stringForKey:@"NowPlayingEditTextSub"]];
            }
        }
        
        //曲情報を書式に埋め込み
        resultText = [resultText replaceMutableWord:@"[st]" replacedWord:songTitle];
        resultText = [resultText replaceMutableWord:@"[ar]" replacedWord:songArtist];
        resultText = [resultText replaceMutableWord:@"[at]" replacedWord:albumTitle];
        resultText = [resultText replaceMutableWord:@"[pc]" replacedWord:playCountStr];
        resultText = [resultText replaceMutableWord:@"[rt]" replacedWord:ratingStr];
        
    } else {
        
        resultText = [NSMutableString stringWithFormat:@" #nowplaying : %@ - %@ ", songTitle, songArtist];
    }
    
    if ( nowPlayingArtWork &&
         [URL isNotEmpty] ) {
        
        resultText = [NSMutableString stringWithFormat:@"%@%@", resultText, URL];
        [self.textView becomeFirstResponder];
        [self.textView setSelectedRange:NSMakeRange(0, 0)];
    }
    
    return [resultText copy];
}

- (void)saveArtworkURL:(NSString *)URL {
    
    MPMusicPlayerController *player = [MPMusicPlayerController iPodMusicPlayer];
    NSString *songTitle = [player.nowPlayingItem valueForProperty:MPMediaItemPropertyTitle];
    NSString *songArtist = [player.nowPlayingItem valueForProperty:MPMediaItemPropertyArtist];
    NSString *albumTitle = [player.nowPlayingItem valueForProperty:MPMediaItemPropertyAlbumTitle];
    
    NSString *keyName = [NSString stringWithFormat:@"%@ - %@ - %@", songTitle, songArtist, albumTitle];
    
    NSMutableDictionary *artworkURLs = [[USER_DEFAULTS dictionaryForKey:@"ArtworkUrl"] mutableCopy];
    [artworkURLs setValue:URL
                   forKey:keyName];
    [USER_DEFAULTS setObject:artworkURLs
                      forKey:@"ArtworkUrl"];
    [self setNowPlayingImageUploading:NO];
}

#pragma mark - Text

- (void)countText {
    
    //t.coを考慮した文字数カウントを行う
    NSInteger num = [TWCharCounter charCounter:self.textView.text];
    
    //画像投稿先がTwitterの場合で画像が設定されている場合入力可能文字数を23文字減らす
    if ( [[USER_DEFAULTS objectForKey:@"PhotoService"] isEqualToString:@"Twitter"] ) {
        
        if ( self.previewImageView.image != nil ) {
            
            num = num - 23;
        }
    }
    
    //結果をラベルに反映
    COUNT_LABEL.text = [NSString stringWithFormat:@"%d", num];
    
    if ( num < 0 ) {
    
        //入力可能数を超えている
        [self.postButton setEnabled:NO];
        [COUNT_LABEL setTextColor:[UIColor redColor]];
        
    } else {
        
        [self.postButton setEnabled:YES];
        [COUNT_LABEL setTextColor:[UIColor whiteColor]];
    }
}

- (void)pushTrashButton {
    
    if ( [self.textView.text isEmpty] ) {
    
        if ( [self.deletedText isNotEmpty] ) {
            
            [self.textView setText:self.deletedText];
            [self setDeletedText:@""];
        }
        
    } else {
    
        [self setDeletedText:self.textView.text];
        [self.textView setText:@""];
    }
    
    [self.previewImageView setImage:nil];
    [self countText];
}

- (void)pushAccountButton {
    
    IDChangeViewController *dialog = [[IDChangeViewController alloc] init];
    dialog.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    [self showModalViewController:dialog];
}

- (void)pushImageButton {
    
    NSLog(@"%s", __func__);
    
    [self.textView resignFirstResponder];
    [self setRepeatedPost:NO];
    [self setFastUpload:NO];
    [self setUseCamera:NO];
    
    UIActionSheet *sheet = nil;
    if ( [USER_DEFAULTS boolForKey:@"RepeatedPost"] ) {
        
        sheet = [[UIActionSheet alloc] initWithTitle:@"投稿画像ソース"
                                            delegate:self
                                   cancelButtonTitle:@"キャンセル"
                              destructiveButtonTitle:nil
                                   otherButtonTitles:
                 @"連続投稿", @"一枚投稿", nil];
        [sheet setTag:ActionSheetTypeImagePickerCheckRepeated];
        
    } else {
        
        sheet = [[UIActionSheet alloc] initWithTitle:@"投稿画像ソース"
                                            delegate:self
                                   cancelButtonTitle:@"キャンセル"
                              destructiveButtonTitle:nil
                                   otherButtonTitles:
                 @"カメラロール", @"カメラロール(即)", @"カメラ", @"カメラ(即)", @"カメラロールの最新", nil];
            [sheet setTag:ActionSheetTypeImagePicker];
    }
    
    [sheet showInView:self.tabBarController.view];
}

- (void)pushReSendButton {
    
    [self setResendMode:YES];
    ResendViewController *dialog = [[ResendViewController alloc] init];
    dialog.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    [self showModalViewController:dialog];
}

- (void)pushPostButton {
    
    if ( [InternetConnection enable] ) {
        
        dispatch_queue_t queue = GLOBAL_QUEUE_DEFAULT;
        dispatch_async(queue, ^{
            dispatch_async(dispatch_get_main_queue(), ^{
                
                if ( [TWAccounts accountCount] == 0 ) {
                    
                    [ShowAlert error:@"Twitterアカウントが見つかりませんでした。"];
                    return;
                }
                
                NSString *text = self.textView.text;
                NSString *inReplyToID = self.inReplyToID ? self.inReplyToID : @"";
                
                if ( [text isEmpty] &&
                     self.previewImageView.image == nil ) {
                    
                    [ShowAlert error:@"文字が入力されていません。"];
                    return;
                }
                
                if ( self.previewImageView.image == nil ) {
                    
                    [FPTRequest requestWithPostType:FPTPostRequestTypeText
                                         parameters:@{
                     @"status" : text,
                     @"in_reply_to_status_id" : inReplyToID
                     }];
                    
                } else {
                    
                    //画像投稿先がTwitterの場合
                    if ( [[USER_DEFAULTS objectForKey:@"PhotoService"] isEqualToString:@"Twitter"] ) {
                        
                        [FPTRequest requestWithPostType:FPTPostRequestTypeTextWithMedia
                                             parameters:@{
                         @"status" : text,
                         @"in_reply_to_status_id" : inReplyToID,
                         @"image" : [self optimizeImage:self.previewImageView.image]
                         }];
                        
                    } else {
                        
                        [FPTRequest requestWithPostType:FPTPostRequestTypeText
                                             parameters:@{
                         @"status" : text,
                         @"in_reply_to_status_id" : inReplyToID
                         }];
                    }
                }
                
                [self.textView setText:@""];
                [self.previewImageView setImage:nil];
                [self countText];
                [self.tabBarController setSelectedIndex:1];
            });
        });
    }
}

- (void)inputMenu {
    
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"入力支援機能"
                                                       delegate:self
                                              cancelButtonTitle:@"キャンセル"
                                         destructiveButtonTitle:nil
                                              otherButtonTitles:
                            @"半角カナ変換(カタカナ)", @"半角カナ変換(ひらがな)", @"半角カナ変換(カタカナ+ひらがな)", @"ペーストボードの内容を貼り付け", @"ペーストボードに全てコピー", nil];
    [sheet setTag:ActionSheetTypeHankakuKana];
    [sheet showInView:self.tabBarController.view];
}

- (void)pushSettingsButton {
    
    SettingViewController *dialog = [[SettingViewController alloc] init];
    dialog.title = @"Settings";
    UINavigationController *navigation = [[UINavigationController alloc] initWithRootViewController:dialog];
    navigation.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    navigation.navigationBar.tintColor = OCEAN_COLOR;
    [self showModalViewController:navigation];
}

- (void)pushBrowserButton:(id)URLStringOrSender {
    
    NSString *useragent = IPHONE_USERAGENT;
    
    if ( [[USER_DEFAULTS objectForKey:@"UserAgent"] isEqualToString:@"FireFox"] ) {
        
        useragent = FIREFOX_USERAGENT;
        
    }else if ( [[USER_DEFAULTS objectForKey:@"UserAgent"] isEqualToString:@"iPad"] ) {
        
        useragent = IPAD_USERAFENT;
    }
    
    NSDictionary *dictionary = [[NSDictionary alloc] initWithObjectsAndKeys:useragent, @"UserAgent", nil];
    [USER_DEFAULTS registerDefaults:dictionary];
    
    [self setWebBrowserMode:YES];
    
    WebViewExController *dialog = [[WebViewExController alloc] initWithURL:[URLStringOrSender isKindOfClass:[NSString class]] ? URLStringOrSender : @""];
    dialog.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    [self showModalViewController:dialog];
}

- (void)pushiPodButton {
    
    NSString *nowPlayingText = [self nowPlayingText];
    
    if ( [nowPlayingText isNotEmpty] ) {
        
        [self.textView setText:[NSString stringWithFormat:@"%@%@", self.textView.text, nowPlayingText]];
        [self countText];
        
    } else {
        
        [ShowAlert error:@"iPod再生中に使用して下さい。"];
    }
}

- (void)pushActionButton {
    
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"その他機能"
                                                       delegate:self
                                              cancelButtonTitle:@"キャンセル"
                                         destructiveButtonTitle:nil
                                              otherButtonTitles:
                            @"アイコン変更", nil];
    [sheet setTag:ActionSheetTypeAction];
    [sheet showInView:self.tabBarController.view];
}

#pragma mark - Rotation
- (BOOL)shouldAutorotate {
    
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations {
    
    return UIInterfaceOrientationMaskPortrait;
}

@end
