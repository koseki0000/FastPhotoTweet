//
//  MainViewController.m
//  FastPhotoTweet
//
//  Created by ktysne on 2013/06/30.
//
//

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

#import "NSString+WordCollect.h"
#import "NSObject+EmptyCheck.h"
#import "UIImage+Convert.h"
#import "NSNotificationCenter+EasyPost.h"

#define ACCOUNT_IMAGEVIEW ((UIImageView *)self.accountIconView.customView)
#define COUNT_LABEL ((UILabel *)self.countLabel.customView)

@interface MainViewController () <UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextViewDelegate>

typedef enum {
    ActionSheetTypeImageMenu
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
@property (nonatomic, strong) SwipeShiftTextView *textView;
@property (nonatomic, strong) UIToolbar *middleBar;
@property (nonatomic, strong) UIBarButtonItem *accountIconView;
@property (nonatomic, strong) UIBarButtonItem *countLabel;
@property (nonatomic, strong) UIImageView *previewImageView;
@property (nonatomic, strong) ActivityGrayView *grayView;
@property (nonatomic, strong) UIToolbar *bottomBar;

@property (nonatomic, copy) NSString *inReplyToID;
@property (nonatomic) BOOL resendMode;
@property (nonatomic) BOOL webBrowserMode;

- (void)createControls;
- (void)addNotificationObservers;

- (void)setIconPreviewImage;
- (void)postDone:(NSNotification *)notification;

- (void)swipeTextView:(UISwipeGestureRecognizer *)sender;
- (void)swipePreviewImageView:(UISwipeGestureRecognizer *)sender;
- (void)tapPreviewImageView:(UITapGestureRecognizer *)sender;

- (void)imageMenu:(ImageMenuType)imageMenuType;
- (void)uploadImage:(UIImage *)image;
- (void)setWebPagePostText:(NSNotification *)notification;

- (void)countText;

- (void)pushTrashButton;
- (void)pushAccountButton;
- (void)pushImageButton;
- (void)pushReSendButton;
- (void)pushPostButton;

- (void)pushSettingsButton;
- (void)pushBrowserButton;
- (void)pushiPodButton;

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
        [self setResendMode:NO];
        [self setWebBrowserMode:NO];
    }
    
    return self;
}

- (void)viewDidLoad {

    [super viewDidLoad];

    CheckAppVersion *checker = [[CheckAppVersion alloc] init];
    [checker versionInfoURL:@"http://fpt.ktysne.info/latest_version_info.txt"
               updateIpaURL:@"itms-services://?action=download-manifest&url=http://fpt.ktysne.info/FastPhotoTweet.plist"];
    
    [self createControls];
    [self addNotificationObservers];
    [self.textView becomeFirstResponder];
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
            
        }else if ( [[[TWTweets manager] tabChangeFunction] isEqualToString:@"Reply"] ) {
            
            [self.textView setText:[NSString stringWithFormat:@"@%@ %@", [[TWTweets manager] text], self.textView.text]];
            [self setInReplyToID:[[TWTweets manager] inReplyToID]];
            [self.textView becomeFirstResponder];
            
        }else if ( [[[TWTweets manager] tabChangeFunction] isEqualToString:@"Edit"] ) {
            
            [self.textView setText:[[TWTweets manager] text]];
            [self setInReplyToID:[[TWTweets manager] inReplyToID]];
            [self.textView becomeFirstResponder];
        }
        
        [[TWTweets manager] setTabChangeFunction:@""];
        [[TWTweets manager] setText:@""];
        [[TWTweets manager] setInReplyToID:@""];
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
                                                                     action:@selector(pushBrowserButton)];
    
    //iPod
    UIBarButtonItem *ipodButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ipod.png"]
                                                                   style:UIBarButtonItemStylePlain
                                                                  target:self
                                                                  action:nil];
    
    //機能
    UIBarButtonItem *actionButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"action.png"]
                                                                     style:UIBarButtonItemStylePlain
                                                                    target:self
                                                                    action:nil];
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
                                                                      action:nil];
    
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
                                             selector:@selector(setWebPagePostText:)
                                                 name:@"WebPagePost"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(postDone:)
                                                 name:POST_DONE_NOTIFICATION
                                               object:nil];
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
        
        [self uploadImage:self.previewImageView.image];
    
    } else if ( sender.direction == UISwipeGestureRecognizerDirectionDown ) {
        
        [self.textView resignFirstResponder];
    }
}

- (void)tapPreviewImageView:(UITapGestureRecognizer *)sender {
    
    NSLog(@"%s", __func__);
    
    if ( self.previewImageView.image ) {
        
        [self.textView resignFirstResponder];
        
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
    }
}

#pragma mark - ImagePicker

- (void)imagePickerController:(UIImagePickerController *)picPicker
        didFinishPickingImage:(UIImage *)image
                  editingInfo:(NSDictionary *)editingInfo {
    
    NSLog(@"%s", __func__);
    
    [picPicker dismissViewControllerAnimated:YES
                                  completion:nil];
    
    double delayInSeconds = 0.5;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        
        [self.previewImageView setImage:image];
    });
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picPicker {
    
    NSLog(@"%s", __func__);
    
    [picPicker dismissViewControllerAnimated:YES
                                  completion:nil];
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
            
            //正方形もしくは縦長
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

- (void)setWebPagePostText:(NSNotification *)notification {
    
    [self.textView setText:notification.object];
    [self.textView becomeFirstResponder];
}

- (void)requestFinished:(ASIHTTPRequest *)request {

    NSLog(@"%s", __func__);
    
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
        
        [self.textView setText:[NSString stringWithFormat:@"%@ %@ ", self.textView.text, imageURL]];
        [self.textView setText:[self.textView.text replaceWord:@"  " replacedWord:@" "]];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [self.grayView end];
    });
}

- (void)requestFailed:(ASIHTTPRequest *)request {
    
    NSLog(@"%s", __func__);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [self.grayView end];
    });
}

- (void)textViewDidChange:(UITextView *)textView {
    
    [self countText];
}

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
}

- (void)pushTrashButton {
    
    [self.textView setText:@""];
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
    
    UIImagePickerController *picPicker = [[UIImagePickerController alloc] init];
    [picPicker setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    [picPicker setDelegate:self];
    [self showModalViewController:picPicker];
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
            });
        });
    }
}

- (void)pushSettingsButton {
    
    SettingViewController *dialog = [[SettingViewController alloc] init];
    dialog.title = @"Settings";
    UINavigationController *navigation = [[UINavigationController alloc] initWithRootViewController:dialog];
    navigation.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    navigation.navigationBar.tintColor = OCEAN_COLOR;
    [self showModalViewController:navigation];
}

- (void)pushBrowserButton {
    
    NSString *useragent = IPHONE_USERAGENT;
    
    if ( [[USER_DEFAULTS objectForKey:@"UserAgent"] isEqualToString:@"FireFox"] ) {
        
        useragent = FIREFOX_USERAGENT;
        
    }else if ( [[USER_DEFAULTS objectForKey:@"UserAgent"] isEqualToString:@"iPad"] ) {
        
        useragent = IPAD_USERAFENT;
    }
    
    NSDictionary *dictionary = [[NSDictionary alloc] initWithObjectsAndKeys:useragent, @"UserAgent", nil];
    [USER_DEFAULTS registerDefaults:dictionary];
    
    [self setWebBrowserMode:YES];
    
    WebViewExController *dialog = [[WebViewExController alloc] initWithURL:@""];
    dialog.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    [self showModalViewController:dialog];
}

- (void)pushiPodButton {
    
}

@end
