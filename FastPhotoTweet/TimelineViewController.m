//
//  TimelineViewController.m
//  FastPhotoTweet
//
//  Created by @peace3884 on 12/07/08.
//

/////////////////////////////
//////// ARC ENABLED ////////
/////////////////////////////

#import <QuartzCore/CALayer.h>
#import <Twitter/Twitter.h>
#import <Accounts/Accounts.h>
#import <Social/Social.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "ASIHTTPRequest.h"
#import <CFNetwork/CFNetwork.h>
#import "UtilityClass.h"
#import "WebViewExController.h"
#import "TimelineViewController.h"
#import "Share.h"
#import "TimelineAttributedCell.h"
#import "TimelineAttributedRTCell.h"
#import "NSAttributedString+Attributes.h"

#import "TWTweet.h"
#import "FPTRequest.h"

#import "UIView+Positioning.h"
#import "UIView+RectInitialize.h"
#import "NSDictionary+DataExtraction.h"
#import "NSArray+AppendUtil.h"
#import "NSObject+EmptyCheck.h"
#import "NSDictionary+XPath.h"
#import "NSString+RegularExpression.h"
#import "NSString+WordCollect.h"
#import "NSString+Calculator.h"
#import "UIImage+Convert.h"
#import "TWTwitterHeader.h"
#import "TWTweets.h"
#import "ListViewController.h"
#import "IconButton.h"
#import "SwipeShiftTextField.h"
#import "TWTweetUtility.h"
#import "ActivityGrayView.h"
#import "ImageWindow.h"
#import "TimelineMenu.h"
#import "InputAlertView.h"

#define OCEAN_COLOR [UIColor colorWithRed:0.4 green:0.8 blue:1.0 alpha:1.0]

#define CELL_IDENTIFIER @"TimelineAttributedCell"
#define RT_CELL_IDENTIFIER @"TimelineAttributedRTCell"

#define USER_STREAM_BUTTON (UIButton *)self.topBarUSButton.customView
#define ICON_BUTTON (UIButton *)self.topBarIcon.customView

#define PICKER_BAR_ITEM @[self.pickerBarCancelButton, self.flexibleSpace, self.pickerBarDoneButton]
#define TOP_BAR_ITEM_DEFAULT @[self.actionButton, self.flexibleSpace, self.topBarUSButton, self.flexibleSpace, self.topBarIcon, self.flexibleSpace, self.topBarReloadButton, self.flexibleSpace, self.composeButton]
#define TOP_BAR_ITEM_OTHER @[self.flexibleSpace, self.closeButton]

#define CELL_WIDTH 264.0f

typedef enum {
    TimelineSegmentTimeline,
    TimelineSegmentMentions,
    TimelineSegmentFavorites,
    TimelineSegmentList
}TimelineSegment;

typedef enum {
    ActionMenuTypeService,
    ActionMenuTypeMyService,
    ActionMenuTypeTimelineLongPress
}ActionMenuType;

typedef enum {
    TextFieldTypeTwilog,
    TextFieldTypeTwilogSearch,
    TextFieldTypeFavStar,
    TextFieldTypeTwitPic,
    TextFieldTypeUserTimeline,
    TextFieldTypeSearch,
    TextFieldTypeSearchStream,
}TextFieldType;

typedef enum {
    TimelineIconActionTypeUserMenu,
    TimelineIconActionTypeReply,
    TimelineIconActionTypeFav,
    TimelineIconActionTypeRT,
    TimelineIconActionTypeFavRT,
    TimelineIconActionTypeSelectIDFavRT
}TimelineIconActionType;

@interface TimelineViewController () <UIActionSheetDelegate, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource, UITableViewDelegate, UITableViewDataSource, NSURLConnectionDelegate, NSURLConnectionDataDelegate>

@property (strong, nonatomic) UIToolbar *topBar;
@property (strong, nonatomic) UIBarButtonItem *flexibleSpace;
@property (strong, nonatomic) UIBarButtonItem *actionButton;
@property (strong, nonatomic) UIBarButtonItem *topBarIcon;
@property (strong, nonatomic) UIBarButtonItem *topBarUSButton;
@property (strong, nonatomic) UIBarButtonItem *topBarReloadButton;
@property (strong, nonatomic) UIBarButtonItem *composeButton;
@property (strong, nonatomic) UIBarButtonItem *closeButton;

@property (strong, nonatomic) UISegmentedControl *segment;

@property (strong, nonatomic) UIRefreshControl *refreshControl;

@property (strong, nonatomic) UITableView *timeline;
@property (strong, nonatomic) TimelineMenu *timelineMenu;
@property (strong, nonatomic) UIToolbar *bottomBar;

@property (strong, nonatomic) UIAlertView *searchAlert;
@property (strong, nonatomic) SwipeShiftTextField *searchAlertTextField;

@property (strong, nonatomic) UIView *pickerBase;
@property (strong, nonatomic) UIToolbar *pickerBar;
@property (strong, nonatomic) UIPickerView *eventPicker;
@property (strong, nonatomic) UIBarButtonItem *pickerBarDoneButton;
@property (strong, nonatomic) UIBarButtonItem *pickerBarCancelButton;
@property (nonatomic) BOOL pickerVisible;

@property (strong, nonatomic) ActivityGrayView *grayView;
@property (strong, nonatomic) ImageWindow *imageWindow;

@property (strong, nonatomic) NSURLConnection *connection;
@property (strong, atomic) NSMutableArray *currentTweets;
@property (strong, nonatomic) TWTweet *selectedTweet;
@property (nonatomic) BOOL loading;
@property (nonatomic) BOOL userStream;
@property (nonatomic) BOOL searchStream;
@property (nonatomic) BOOL webBrowserMode;
@property (nonatomic) BOOL addTweetStopMode;
@property (nonatomic) BOOL listSelect;
@property (nonatomic) NSUInteger longPressControl;

@property (strong, nonatomic) NSMutableArray *userStreamQueue;
@property (strong, nonatomic) NSTimer *userStreamTimer;

@property (strong, nonatomic) NSMutableArray *otherTweets;

- (void)createPullDownRefreshHeader;
- (oneway void)createTimelineGuesture;
- (oneway void)addNotificationObservers;
- (oneway void)requestHomeTimeline;
- (oneway void)requestMentions;
- (oneway void)requestFavorites;
- (oneway void)requestTweet:(NSString *)tweetID;
- (oneway void)requestList:(NSString *)listID;
- (void)createInReplyToChain:(TWTweet *)tweet;

- (oneway void)addFavorite:(NSString *)tweetID accountIndex:(NSInteger)accountIndex;

- (void)changeAccount:(NSNotification *)notification;

- (void)pushActionButton;
- (void)pushTopBarUSButton;
- (void)pushAccountIconButton;
- (void)pushReloadButton;
- (void)pushComposeButton;
- (void)pushCloseButton;

- (void)changeSegmentIndex;

- (oneway void)receiveHomeTimeline:(NSNotification *)notification;
- (oneway void)receiveUserTimeline:(NSNotification *)notification;
- (oneway void)receiveMentions:(NSNotification *)notification;
- (oneway void)receiveFavorites:(NSNotification *)notification;
- (oneway void)receiveSearch:(NSNotification *)notification;
- (oneway void)receiveTweet:(NSNotification *)notification;
- (oneway void)receiveList:(NSNotification *)notification;
- (oneway void)receiveProfile:(NSNotification *)notification;
- (oneway void)receiveAPIError:(NSNotification *)notification;

- (oneway void)receiveOffline:(NSNotification *)notification;

- (void)openStream;
- (void)closeStream;
- (void)reOpenStream;
- (void)startUserStreamQueue;
- (void)stopUserStreamQueue;
- (oneway void)checkUserStreamQueue;
- (oneway void)userStreamDelete:(TWTweet *)receiveTweet;
- (oneway void)userStreamMyAddFavEvent:(TWTweet *)receiveTweet;
- (oneway void)userStreamMyRemoveFavEvent:(TWTweet *)receiveTweet;
- (oneway void)userStreamReceiveFavEvent:(TWTweet *)receiveTweet;
- (oneway void)userStreamReceiveTweet:(TWTweet *)receiveTweet;

- (void)openSearchStream:(NSString *)searchWord;
- (void)closeSearchStream;
- (void)startSearchStreamQueue;
- (void)stopSearchStreamQueue;
- (oneway void)checkSearchStreamQueue;
- (oneway void)searchStreamReceiveTweet:(TWTweet *)receiveTweet;

- (void)getIconWithTweetArray:(NSMutableArray *)tweetArray;
- (void)requestProfileImageWithURL:(NSString *)biggerUrl screenName:(NSString *)screenName searchName:(NSString *)searchName;
- (void)refreshTimelineCell:(NSNumber *)index;
- (void)openTimelineImage:(NSNotification *)notification;
- (void)swipeTimelineRight:(UISwipeGestureRecognizer *)sender;
- (void)swipeTimelineLeft:(UISwipeGestureRecognizer *)sender;
- (void)scrollTimelineToTop:(BOOL)animation;
- (void)scrollTimelineToBottom:(BOOL)animation;
- (void)scrollTimelineForNewTweet:(NSString *)tweetID;
- (void)longPressTimeline:(UILongPressGestureRecognizer *)sender;
- (void)pushIcon:(UIButton *)sender;
- (void)changeFavorite:(NSString *)targerTweetID;

- (void)hideTimelineMenu:(NSNotification *)notification;
- (void)timelineMenuSelectID:(NSNotification *)notification;
- (void)timelineMenuHashTagNG:(NSNotification *)notification;
- (void)timelineMenuClientNG:(NSNotification *)notification;
- (void)timelineMenuInReplyTo:(NSNotification *)notification;
- (void)timelineMenuDelete:(NSNotification *)notification;
- (void)timelineMenuEdit:(NSNotification *)notification;

- (void)createTimelineMenu:(TimeLineMenuIdentifier)menuIdentifier;
- (void)createSearchAlert:(NSString *)title alertType:(TextFieldType)alertType;
- (void)getMyAccountIcon;
- (void)setOtherTweetsMode;

- (void)showAPILimit;
- (void)showListView;

- (void)showPickerView;
- (void)pickerDone;
- (void)pickerCancel;
- (void)hidePicker;

- (void)openBrowser:(NSString *)URL;

@end

@implementation TimelineViewController

#pragma mark - Initialize

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    
    self = [super initWithNibName:nibNameOrNil
                           bundle:nibBundleOrNil];
    
    if ( self ) {
        
        self.title = NSLocalizedString(@"Timeline", @"Timeline");
        self.tabBarItem.image = [UIImage imageNamed:@"Timeline.png"];
        
        [Share manager];
        
        self.currentTweets = [NSMutableArray array];
        
        //アイコン保存用ディレクトリ確認
        BOOL isDir = NO;
        BOOL directoryExists = ( [FILE_MANAGER fileExistsAtPath:ICONS_DIRECTORY isDirectory:&isDir] && isDir );
        
        if ( !directoryExists ) {
            
            //存在しない場合作成
            [FILE_MANAGER createDirectoryAtPath:ICONS_DIRECTORY
                    withIntermediateDirectories:YES
                                     attributes:nil
                                          error:nil];
        }
        
        //クラッシュログ保存用ディレクトリ確認
        isDir = NO;
        directoryExists = ( [FILE_MANAGER fileExistsAtPath:LOGS_DIRECTORY isDirectory:&isDir] && isDir );
        
        if ( !directoryExists ) {
            
            //存在しない場合作成
            [FILE_MANAGER createDirectoryAtPath:LOGS_DIRECTORY
                    withIntermediateDirectories:YES
                                     attributes:nil
                                          error:nil];
        }
    }
    
    return self;
}

#pragma mark - LifeCycle
- (void)viewDidLoad {
    
    [super viewDidLoad];
    NSLog(@"%s", __func__);
    
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    self.topBar = [[UIToolbar alloc] initWithX:0.0f
                                             Y:0.0f
                                             W:SCREEN_WIDTH
                                             H:TOOL_BAR_HEIGHT];
    [self.topBar setTintColor:OCEAN_COLOR];
    
    self.flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                       target:nil
                                                                       action:nil];
    
    self.actionButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"action.png"]
                                                         style:UIBarButtonItemStylePlain
                                                        target:self
                                                        action:@selector(pushActionButton)];
    
    UIButton *topBarUSButton = [[UIButton alloc] initWithX:0.0f
                                                         Y:0.0f
                                                         W:24.0f
                                                         H:36.0f];
    [topBarUSButton.imageView setContentMode:UIViewContentModeCenter];
    [topBarUSButton addTarget:self
                       action:@selector(pushTopBarUSButton)
             forControlEvents:UIControlEventTouchUpInside];
    [topBarUSButton setImage:[UIImage imageNamed:@"play.png"]
                    forState:UIControlStateNormal];
    
    self.topBarUSButton = [[UIBarButtonItem alloc] initWithCustomView:topBarUSButton];
    
    UIButton *accountIconButton = [[UIButton alloc] initWithX:0.0f
                                                            Y:0.0f
                                                            W:36.0f
                                                            H:36.0f];
    [accountIconButton.imageView setContentMode:UIViewContentModeScaleAspectFit];
    
    NSArray *iconList = [FILE_MANAGER contentsOfDirectoryAtPath:ICONS_DIRECTORY
                                                          error:nil];
    NSString *myAccountName = [TWAccounts currentAccountName];
    
    for ( NSString *accountName in iconList ) {
        
        if ( [accountName hasPrefix:myAccountName] ) {
            
            NSString *searchName = [NSString stringWithFormat:@"%@-", accountName];
            NSLog(@"%@", searchName);
            
            UIImage *image = [UIImage imageWithContentsOfFileByContext:FILE_PATH];
            
            [accountIconButton setImage:image
                               forState:UIControlStateNormal];
            break;
        }
    }
    
    [accountIconButton addTarget:self
                          action:@selector(pushAccountIconButton)
                forControlEvents:UIControlEventTouchUpInside];
    [accountIconButton.layer setMasksToBounds:YES];
    [accountIconButton.layer setCornerRadius:5.0f];
    
    self.topBarIcon = [[UIBarButtonItem alloc] initWithCustomView:accountIconButton];
    
    self.topBarReloadButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"reload.png"]
                                                               style:UIBarButtonItemStylePlain
                                                              target:self
                                                              action:@selector(pushReloadButton)];
    
    self.composeButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"compose.png"]
                                                          style:UIBarButtonItemStylePlain
                                                         target:self
                                                         action:@selector(pushComposeButton)];
    [self setDefaultTweetsMode];
    [self.view addSubview:self.topBar];
    
    self.closeButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop
                                                                     target:self
                                                                     action:@selector(pushCloseButton)];
    
    self.segment = [[UISegmentedControl alloc] initWithItems:@[
                    @"Timeline", @"Mentions", @"Favorites", @"List"
                    ]];
    [self.segment setFrame:CGRectMake(0.0f,
                                      CGRectGetMaxY(self.topBar.frame),
                                      SCREEN_WIDTH,
                                      SEGMENT_BAR_HEIGHT)];
    [self.segment setSegmentedControlStyle:UISegmentedControlStyleBar];
    [self.segment setTintColor:OCEAN_COLOR];
    [self.segment addTarget:self
                     action:@selector(changeSegmentIndex)
           forControlEvents:UIControlEventValueChanged];
    [self.segment setSelectedSegmentIndex:0];
    [self.view addSubview:self.segment];
    
    self.timeline = [[UITableView alloc] initWithFrame:CGRectMake(0.0f,
                                                                  CGRectGetMaxY(self.segment.frame),
                                                                  SCREEN_WIDTH,
                                                                  SCREEN_HEIGHT - CGRectGetHeight(self.topBar.frame) - CGRectGetHeight(self.segment.frame) - TAB_BAR_HEIGHT)
                                                 style:UITableViewStylePlain];
    [self.timeline setDelegate:self];
    [self.timeline setDataSource:self];
    [self.view addSubview:self.timeline];
    [self createPullDownRefreshHeader];
    [self createTimelineGuesture];
    
    self.imageWindow = [[ImageWindow alloc] init];
    [self.view addSubview:self.imageWindow];
    
    self.grayView = [[ActivityGrayView alloc] init];
    [self.view addSubview:self.grayView];
    
    [self addNotificationObservers];
    
    if ( [InternetConnection enable] ) {
        
        if ( [TWAccounts accountCount] != 0 ) {
         
            DISPATCH_AFTER(0.3) ^{
               
                [self requestHomeTimeline];
            });
        }
    }
}

- (void)viewDidAppear:(BOOL)animated {
    
    NSLog(@"%s", __func__);
    
    [super viewDidAppear:animated];
    
    if ( self.listSelect ) {
        
        if ( [[[TWTweets manager] listID] isNotEmpty] ) {
            
            if ( ![[[TWTweets manager] listID] isEqualToString:[[TWTweets manager] showingListID]] ) {
             
                [TWTweets manager].showingListID = [[TWTweets manager] listID];
                [self requestList:[[TWTweets manager] listID]];
            }
        }
    }
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    
    NSLog(@"%s", __func__);
    
    if ( [D boolForKey:@"BecomeActiveUSConnect"] &&
         self.segment.selectedSegmentIndex == 0 &&
         !self.addTweetStopMode &&
         !self.userStream ) {
        
        [self pushReloadButton];
    }
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    
    NSLog(@"%s", __func__);
    
    if ( [D boolForKey:@"EnterBackgroundUSDisConnect"] &&
         (self.userStream || self.searchStream )) {
        
        [self closeStream];
        [self closeSearchStream];
    }
}

- (void)createPullDownRefreshHeader {
    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [self setRefreshControl:refreshControl];
    [refreshControl addTarget:self
                       action:@selector(refreshOccured:)
             forControlEvents:UIControlEventValueChanged];
    [self.timeline setAlwaysBounceVertical:YES];
    [self.timeline addSubview:refreshControl];
}

- (oneway void)createTimelineGuesture {
    
    UISwipeGestureRecognizer *swipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self
                                                                                     action:@selector(swipeTimelineRight:)];
    [swipeRight setDirection:UISwipeGestureRecognizerDirectionRight];
    [self.timeline addGestureRecognizer:swipeRight];
    
    UISwipeGestureRecognizer *swipeLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self
                                                                                    action:@selector(swipeTimelineLeft:)];
    [swipeLeft setDirection:UISwipeGestureRecognizerDirectionLeft];
    [self.timeline addGestureRecognizer:swipeLeft];
    
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self
                                                                                            action:@selector(longPressTimeline:)];
    [longPress setMinimumPressDuration:0.5f];
    [self.timeline addGestureRecognizer:longPress];
}

- (oneway void)addNotificationObservers {
 
    NSLog(@"%s", __func__);
    
    //アプリがアクティブになった場合の通知を受け取る設定
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationDidBecomeActive:)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
    
    //バックグラウンドに移行した際にストリームを切断
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationDidEnterBackground:)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];
    
    //アカウントが切り替わった通知を受け取る設定
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(changeAccount:)
                                                 name:@"ChangeAccount"
                                               object:nil];
    
    //APIエラー
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveAPIError:)
                                                 name:GET_API_ERROR_NOTIFICATION
                                               object:nil];
    
    //Timeline取得完了
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveHomeTimeline:)
                                                 name:HOME_TIMELINE_DONE_NOTIFICATION
                                               object:nil];
    
    //UserTimeline取得完了
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveUserTimeline:)
                                                 name:USER_TIMELINE_DONE_NOTIFICATION
                                               object:nil];
    
    //Mentions取得完了
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveMentions:)
                                                 name:MENTIONS_DONE_NOTIFICATION
                                               object:nil];
    
    //Favorites取得完了
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveFavorites:)
                                                 name:FAVORITES_DONE_NOTIFICATION
                                               object:nil];
    
    //Search取得完了
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveSearch:)
                                                 name:SEARCH_DONE_NOTIFICATION
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveTweet:)
                                                 name:TWEET_DONE_NOTIFICATION
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveProfile:)
                                                 name:PROFILE_DONE_NOTIFICATION
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveList:)
                                                 name:LIST_DONE_NOTIFICATION
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveOffline:)
                                                 name:@"Offline"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(openTimelineURL:)
                                                 name:@"OpenTimelineURL"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(openTimelineImage:)
                                                 name:@"OpenTimelineImage"
                                               object:nil];
    
    //TimelineMenu
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(hideTimelineMenu:)
                                                 name:@"TimelineMenuDone"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(timelineMenuSelectID:)
                                                 name:@"TimelineMenuSelectID"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(timelineMenuHashTagNG:)
                                                 name:@"TimelineMenuHashTagNG"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(timelineMenuClientNG:)
                                                 name:@"TimelineMenuClientNG"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(timelineMenuInReplyTo:)
                                                 name:@"TimelineMenuInReplyTo"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(timelineMenuDelete:)
                                                 name:@"TimelineMenuDelete"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(timelineMenuEdit:)
                                                 name:@"TimelineMenuEdit"
                                               object:nil];
    //Menuここまで
}

#pragma mark - Request

- (oneway void)requestHomeTimeline {
    
    NSLog(@"%s", __func__);
    
    if ( ![InternetConnection enable] ) {
        
        return;
    }
    
    if ( [self.currentTweets count] == 0 ) {
        
        [self.grayView start];
    }
    
    [self getMyAccountIcon];
    
    if ( [D boolForKey:@"UseTimelineList"] ) {
        
        NSString *listID = [[D objectForKey:@"TimelineList"] objectForKey:[TWAccounts currentAccountName]];
        
        if ( [listID isNotEmpty] ) {
            
            //代替リスト
            NSLog(@"TimelineListMode");
            
            [self requestList:listID];
            return;
        }
    }
    
    NSMutableDictionary *parameters = [@{} mutableCopy];
    
    //取得数
    [parameters setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"TimelineLoadCount"]
                   forKey:@"count"];
    //エンティティの有効化
    [parameters setObject:@"1"
                   forKey:@"include_entities"];
    //RT表示
    [parameters setObject:@"1"
                   forKey:@"include_rts"];
    
    if ( [[TWTweets topTweetID] isNotEmpty] ) {
        
        [parameters setObject:[TWTweets topTweetID]
                        forKey:@"since_id"];
    }
    
    [FPTRequest requestWithGetType:FPTGetRequestTypeHomeTimeline
                        parameters:parameters];
}

- (oneway void)requestUserTimeline:(NSString *)screenName {
    
    if ( ![InternetConnection enable] ) {
        
        return;
    }
    
    [self.grayView start];
    
    NSMutableDictionary *parameters = [@{} mutableCopy];
    
    //表示するユーザー
    [parameters setObject:screenName
                   forKey:@"screen_name"];
    //取得数
    [parameters setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"TimelineLoadCount"]
                   forKey:@"count"];
    //エンティティの有効化
    [parameters setObject:@"1"
                   forKey:@"include_entities"];
    //RT表示
    [parameters setObject:@"1"
                   forKey:@"include_rts"];
    
    [FPTRequest requestWithGetType:FPTGetRequestTypeUserTimeline
                        parameters:parameters];
}

- (oneway void)requestMentions {
    
    if ( ![InternetConnection enable] ) {
        
        return;
    }
    
    [self.grayView start];
    
    NSMutableDictionary *parameters = [@{} mutableCopy];
    
    //取得数
    [parameters setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"MentionsLoadCount"]
                   forKey:@"count"];
    //エンティティの有効化
    [parameters setObject:@"1"
                   forKey:@"include_entities"];
    
    [FPTRequest requestWithGetType:FPTGetRequestTypeMentions
                        parameters:parameters];
}

- (oneway void)requestFavorites {
    
    if ( ![InternetConnection enable] ) {
        
        return;
    }
    
    [self.grayView start];
    
    NSMutableDictionary *parameters = [@{} mutableCopy];
    
    //取得数
    [parameters setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"FavoritesLoadCount"]
                   forKey:@"count"];
    //エンティティの有効化
    [parameters setObject:@"1"
                   forKey:@"include_entities"];
    
    [FPTRequest requestWithGetType:FPTGetRequestTypeFavorites
                        parameters:parameters];
}

- (oneway void)requestSearch:(NSString *)searchWord {
    
    if ( ![InternetConnection enable] ) {
        
        return;
    }
    
    [self.grayView start];
    
    NSMutableDictionary *parameters = [@{} mutableCopy];
    
    //サーチワード
    [parameters setObject:searchWord
                   forKey:@"q"];
    //取得数
    [parameters setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"TimelineLoadCount"]
               forKey:@"count"];
    //エンティティの有効化
    [parameters setObject:@"1"
                   forKey:@"include_entities"];
    //日本
    [parameters setObject:@"ja"
                   forKey:@"lang"];
    
    [FPTRequest requestWithGetType:FPTGetRequestTypeSearch
                        parameters:parameters];
}

- (oneway void)requestTweet:(NSString *)tweetID {
    
    NSLog(@"%s", __func__);
    
    if ( ![InternetConnection enable] ) {
        
        return;
    }
    
    NSMutableDictionary *parameters = [@{} mutableCopy];
    
    [parameters setObject:tweetID
                   forKey:@"id"];
    
    //エンティティの有効化
    [parameters setObject:@"1"
                   forKey:@"include_entities"];
    
    [FPTRequest requestWithGetType:FPTGetRequestTypeTweet
                        parameters:parameters];
}

- (oneway void)requestList:(NSString *)listID {
    
    NSLog(@"%s", __func__);
    
    if ( ![InternetConnection enable] ) {
        
        return;
    }

    if ( self.segment.selectedSegmentIndex == TimelineSegmentList ) {
    
        [self.grayView start];
    }
    
    NSMutableDictionary *parameters = [@{} mutableCopy];
    
    //取得数
    [parameters setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"TimelineLoadCount"]
                   forKey:@"count"];
    
    //エンティティの有効化
    [parameters setObject:@"1"
                   forKey:@"include_entities"];
    
    [parameters setObject:listID
                   forKey:LIST_ID];
    
    if ( [D boolForKey:@"UseTimelineList"] &&
          self.segment.selectedSegmentIndex == TimelineSegmentTimeline ) {
        
        [parameters setObject:@"YES"
                       forKey:TIMELINE_LIST_MODE];
    }
    
    [FPTRequest requestWithGetType:FPTGetRequestTypeList
                        parameters:parameters];
}

#pragma mark - Receive Response
- (oneway void)receiveHomeTimeline:(NSNotification *)notification {
    
    NSLog(@"%s", __func__);
    
    NSString *requestUserName = notification.userInfo[REQUEST_USER_NAME];
    
    if ( self.segment.selectedSegmentIndex == TimelineSegmentTimeline &&
        [requestUserName isEqualToString:[TWAccounts currentAccountName]] ) {
        
        BOOL stopped = NO;
        
        if ( self.userStream ) {
            
            stopped = YES;
            [self setAddTweetStopMode:YES];
        }
        
        NSString *scrollTweetID = nil;
        if ( [self.currentTweets isNotEmpty] ) {
            
            scrollTweetID = ((TWTweet *)self.currentTweets[0]).tweetID;
        }
        
        NSMutableArray *receiveTweets = notification.userInfo[RESPONSE_DATA];
        [self getIconWithTweetArray:receiveTweets];
        
        NSUInteger beforeCount = [self.currentTweets count];
        
        [self setCurrentTweets:[self.currentTweets appendOnlyNewTweetToTop:receiveTweets
                                                                 returnMutable:YES]];
        [self.grayView end];
        [self.refreshControl endRefreshing];
        
        if ( beforeCount != [self.currentTweets count] ) {
            
            //新着があった場合のみ行う
            [TWTweets saveCurrentTimeline:self.currentTweets];
            
            [self.timeline reloadData];
            
            if ( [D boolForKey:@"TimelineFirstLoad"] ) {
              
                if ( [[TWTweets currentTimeline] count] != 0 ) {
                
                    [self scrollTimelineToBottom:YES];
                }
            
            } else {
                
                if ( self.timeline.contentOffset.y <= 0.0f ) {
                 
                    //新着取得前の最新までスクロール
                    [self scrollTimelineForNewTweet:scrollTweetID];
                }
            }
            
            [self addTaskNotification:[NSString stringWithFormat:@"新着Tweet %d件", [self.currentTweets count] - beforeCount]];
            
        }else {
            
            [self addTaskNotification:@"新着Tweetなし"];
        }
        
        if ( [D boolForKey:@"ReloadAfterUSConnect"] &&
            !self.userStream ) {
            
            //UserStream接続
            [self pushTopBarUSButton];
        }
        
        if ( stopped ) {
            
            [self setAddTweetStopMode:NO];
        }
    }
}

- (oneway void)receiveUserTimeline:(NSNotification *)notification {
    
    NSLog(@"%s", __func__);
    
    NSString *requestUserName = notification.userInfo[REQUEST_USER_NAME];
    
    if ( [requestUserName isEqualToString:[TWAccounts currentAccountName]] ) {
    
        [self setOtherTweetsMode];
        
        NSMutableArray *receiveTweets = notification.userInfo[RESPONSE_DATA];
        [self getIconWithTweetArray:receiveTweets];
        [self setCurrentTweets:receiveTweets];
        [self.timeline reloadData];
        [self.grayView end];
        [self.refreshControl endRefreshing];
    }
}

- (void)receiveMentions:(NSNotification *)notification {
    
    NSLog(@"%s", __func__);
    
    NSString *requestUserName = notification.userInfo[REQUEST_USER_NAME];
    
    if ( self.segment.selectedSegmentIndex == TimelineSegmentMentions &&
        [requestUserName isEqualToString:[TWAccounts currentAccountName]] ) {
        
        NSMutableArray *receiveTweets = notification.userInfo[RESPONSE_DATA];
        [self getIconWithTweetArray:receiveTweets];
        [self setCurrentTweets:receiveTweets];
        [self.timeline reloadData];
        [self.grayView end];
        [self.refreshControl endRefreshing];
    }
}

- (oneway void)receiveFavorites:(NSNotification *)notification {
    
    NSLog(@"%s", __func__);
    
    NSString *requestUserName = notification.userInfo[REQUEST_USER_NAME];
    
    if ( self.segment.selectedSegmentIndex == TimelineSegmentFavorites &&
        [requestUserName isEqualToString:[TWAccounts currentAccountName]] ) {
        
        NSMutableArray *receiveTweets = notification.userInfo[RESPONSE_DATA];
        [self getIconWithTweetArray:receiveTweets];
        [self setCurrentTweets:receiveTweets];
        [self.timeline reloadData];
        [self.grayView end];
        [self.refreshControl endRefreshing];
    }
}

- (oneway void)receiveSearch:(NSNotification *)notification {
    
    NSLog(@"%s", __func__);
    
    NSString *requestUserName = notification.userInfo[REQUEST_USER_NAME];
    
    if ( [requestUserName isEqualToString:[TWAccounts currentAccountName]] ) {
        
        [self setOtherTweetsMode];
        
        NSMutableArray *receiveTweets = notification.userInfo[RESPONSE_DATA];
        [self getIconWithTweetArray:receiveTweets];
        [self setCurrentTweets:receiveTweets];
        [self.timeline reloadData];
        [self.grayView end];
        [self.refreshControl endRefreshing];
        
        if ( self.searchStream ) {
            
            NSString *searchWord = notification.userInfo[@"SearchWord"];
            [self openSearchStream:searchWord];
            
        } else {
            
            [self setOtherTweetsMode];
        }
    }
}

- (oneway void)receiveTweet:(NSNotification *)notification {
    
    TWTweet *tweet = notification.userInfo[RESPONSE_DATA];
    [self.otherTweets addObject:tweet];
    [self createInReplyToChain:tweet];
}

- (oneway void)receiveList:(NSNotification *)notification {
    
    NSString *requestUserName = notification.userInfo[REQUEST_USER_NAME];
    
    if ( self.segment.selectedSegmentIndex == TimelineSegmentList &&
        [requestUserName isEqualToString:[TWAccounts currentAccountName]] ) {
        
        NSMutableArray *receiveTweets = notification.userInfo[RESPONSE_DATA];
        [self getIconWithTweetArray:receiveTweets];
        [self setCurrentTweets:receiveTweets];
        [self.timeline reloadData];
        [self.grayView end];
        [self.refreshControl endRefreshing];
    }
}

- (oneway void)receiveProfile:(NSNotification *)notification {
    
    NSLog(@"%s", __func__);
    
    NSString *myAccountName = [TWAccounts currentAccountName];
    NSString *requestUserName = notification.userInfo[REQUEST_USER_NAME];
    if ( [requestUserName isEqualToString:myAccountName] ) {
     
        IconSize iconSize;
        NSString *iconQualitySetting = [D objectForKey:@"IconQuality"];
        
        if ( [iconQualitySetting isEqualToString:@"Mini"] ) {
            iconSize = IconSizeMini;
        }else if ( [iconQualitySetting isEqualToString:@"Normal"] ) {
            iconSize = IconSizeNormal;
        }else if ( [iconQualitySetting isEqualToString:@"Bigger"] ) {
            iconSize = IconSizeBigger;
        }else if ( [iconQualitySetting hasPrefix:@"Original"] ) {
            iconSize = IconSizeOriginal;
        } else {
            iconSize = IconSizeBigger;
        }
        
        NSString *iconURL = [TWIconResizer iconURL:notification.userInfo[@"ResponseData"][@"profile_image_url"]
                                          iconSize:iconSize];
        ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:iconURL]];
        __weak __block ASIHTTPRequest *wRequest = request;
        
        [wRequest setCompletionBlock:^ {
            
            NSArray *iconList = [FILE_MANAGER contentsOfDirectoryAtPath:ICONS_DIRECTORY
                                                                  error:nil];
            
            for ( NSString *accountName in iconList ) {
                
                if ( [accountName hasPrefix:myAccountName] ) {
                    
                    NSString *searchName = [NSString stringWithFormat:@"%@", accountName];
                    [FILE_MANAGER removeItemAtPath:FILE_PATH
                                             error:nil];
                    break;
                }
            }
            
            UIImage *iconImage = [UIImage imageWithDataByContext:wRequest.responseData];
            
            if ( [iconQualitySetting isEqualToString:@"Original96"] ) {
                
                iconImage = [ResizeImage aspectResizeForMaxSize:iconImage
                                                        maxSize:96.0f];
            }
            
            [ICON_BUTTON setImage:iconImage
                         forState:UIControlStateNormal];
            
            NSString *fileName = [iconURL lastPathComponent];
            NSString *screenName = notification.userInfo[REQUEST_USER_NAME];
            NSString *searchName = [NSString stringWithFormat:@"%@-%@", screenName, fileName];
            [wRequest.responseData writeToFile:FILE_PATH
                                    atomically:YES];
            [Share cacheImage:iconImage
                      forName:screenName
             doneNotification:NO];
        }];
        
        [wRequest startAsynchronous];
    }
}

- (oneway void)receiveAPIError:(NSNotification *)notification {
    
    NSLog(@"%s", __func__);
    
    if ( notification.userInfo ) {
        
        NSDictionary *errors = notification.userInfo[@"ErrorResponseData"];
        
        if ( errors ) {
            
            NSDictionary *error = errors[@"errors"][0];
            NSLog(@"%@", error);
            
            NSString *message = error[@"message"];
            NSString *code = [error[@"code"] stringValue];
            
            if ( message && code ) {
                
                [ShowAlert title:code
                         message:message];
            }
        }
    }
    
    [self.grayView forceEnd];
    [self.refreshControl endRefreshing];
}

- (oneway void)receiveOffline:(NSNotification *)notification {
    
    [self.grayView forceEnd];
}

- (void)createInReplyToChain:(TWTweet *)tweet {
    
    NSLog(@"%s", __func__);
    
    NSString *inReplyToID = tweet.inReplyToID;
    
    if ( [inReplyToID isNotEmpty] ) {
        
        NSLog(@"inReplyToID: %@", inReplyToID);
        
        __block TWTweet *findTweet = nil;
        
        [self.currentTweets enumerateObjectsUsingBlock:^(TWTweet *searchTweet,
                                                         NSUInteger index,
                                                         BOOL *stop) {
             
             NSString *searchTweetID = searchTweet.tweetID;
             
             if ( [searchTweetID isNotEmpty] ) {
                 
                 if ( [searchTweetID isEqualToString:inReplyToID] ) {
                     
                     findTweet = searchTweet;
                     [self.otherTweets addObject:findTweet];
                     *stop = YES;
                 }
             }
         }];
        
        if ( findTweet ) {
            
            [self createInReplyToChain:findTweet];
            
        } else {
            
            [self requestTweet:inReplyToID];
        }
        
    } else {
        
        if ( self.otherTweets.count <= 1 ) {
            
            [ShowAlert error:@"InReplyToIDがありません。"];
            
        } else {
            
            [self setOtherTweetsMode];
            [self setCurrentTweets:self.otherTweets];
            [self.timeline reloadData];
        }
    }
}

- (oneway void)addFavorite:(NSString *)tweetID accountIndex:(NSInteger)accountIndex {
    
    NSMutableDictionary *parameters = [@{} mutableCopy];
    [parameters setObject:tweetID
                   forKey:@"id"];
    [parameters setObject:@(accountIndex)
                   forKey:NEED_SELECT_ACCOUNT];
    
    [FPTRequest requestWithPostType:FPTPostRequestTypeFavorite
                         parameters:parameters];
}

#pragma mark - PullDownRefresh

- (void)refreshOccured:(id)sender {
    
    if ( !self.searchStream ) {
     
        [self pushReloadButton];
    }
}

#pragma mark - Account Change
- (void)changeAccount:(NSNotification *)notification {
    
    //Tweet画面でアカウントが切り替えられた際に呼ばれる
    NSLog(@"changeAccount");
    
    //UserStreamが有効な場合切断する
    if ( self.userStream ) [self closeStream];
    
    //自分のアカウントを設定
    [self getMyAccountIcon];
    
    //List一覧のキャッシュを削除
    
    //タイムラインをアクティブアカウントの物に切り替え
    [self setCurrentTweets:[TWTweets currentTimeline]];
    [self.timeline reloadData];
    
    DISPATCH_AFTER(0.1) ^{
        
        [self requestHomeTimeline];
    });
}

#pragma mark - Button
- (void)pushActionButton {
    
    NSLog(@"%s", __func__);
    
    UIActionSheet *sheet = [[UIActionSheet alloc]
                            initWithTitle:@"外部サービスやユーザー情報を開く"
                            delegate:self
                            cancelButtonTitle:@"Cancel"
                            destructiveButtonTitle:nil
                            otherButtonTitles:
                            @"Twilog", @"TwilogSearch", @"favstar", @"Twitpic",
                            @"UserTimeline", @"TwitterSearch", @"TwitterSearch(Stream)",
                            @"API Limitを確認", nil];
    [sheet setTag:ActionMenuTypeService];
    [sheet showInView:self.tabBarController.view];
}

- (void)pushTopBarUSButton {
    
    NSLog(@"%s", __func__);
    
    if ( self.segment.selectedSegmentIndex == TimelineSegmentList ) {
        
        [self showListView];
        
    } else {
     
        if ( self.userStream ) {
            
            [self closeStream];
            
        } else {
            
            [USER_STREAM_BUTTON setEnabled:NO];
            [self setUserStream:YES];
            [self openStream];
        }
    }
}

- (void)pushAccountIconButton {
    
    NSLog(@"%s", __func__);
    
    UIActionSheet *sheet = [[UIActionSheet alloc]
                            initWithTitle:@"外部サービスやユーザー情報を開く"
                            delegate:self
                            cancelButtonTitle:@"Cancel"
                            destructiveButtonTitle:nil
                            otherButtonTitles:
                            @"Twilog", @"TwilogSearch", @"favstar", @"Twitpic",
                            @"UserTimeline", @"TwitterSearch", nil];
    [sheet setTag:ActionMenuTypeMyService];
    [sheet showInView:self.tabBarController.view];
}

- (void)pushReloadButton {
    
    NSLog(@"%s", __func__);
    
    switch (self.segment.selectedSegmentIndex) {
            
        case TimelineSegmentTimeline:
            
            [self requestHomeTimeline];
            break;
            
        case TimelineSegmentMentions:
            
            [self requestMentions];
            break;
            
        case TimelineSegmentFavorites:
            
            [self requestFavorites];
            break;
            
        case TimelineSegmentList:
            
            break;
            
        default:
            break;
    }
}

- (void)pushComposeButton {
    
    NSLog(@"%s", __func__);
    
    [[TWTweets manager] setTabChangeFunction:@"Post"];
    [self.tabBarController setSelectedIndex:0];
}

- (void)pushCloseButton {
    
    if ( self.searchStream ) {
        
        [self closeSearchStream];
    }
    
    [self setDefaultTweetsMode];
    [self.segment setSelectedSegmentIndex:TimelineSegmentTimeline];
    [USER_STREAM_BUTTON setEnabled:YES];
    [self setCurrentTweets:[TWTweets currentTimeline]];
    [self.timeline reloadData];
}

#pragma mark - UIActionSheet
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    NSInteger tag = actionSheet.tag;
    
    if ( tag == ActionMenuTypeService ) {
        
        //Twilog, TwilogSearch, favstar, Twitpic, UserTimeline,
        //TwitterSearch, TwitterSearch(Stream), API Limitを確認
        
        if ( buttonIndex == TextFieldTypeTwilog ) {
            
            [self createSearchAlert:@"Twilog"
                          alertType:TextFieldTypeTwilog];
            
        }else if ( buttonIndex == TextFieldTypeTwilogSearch ) {
            
            InputAlertView *alert = [[InputAlertView alloc] initWithTitle:@"TwilogSearch"
                                                                 delegate:self
                                                        cancelButtonTitle:@"キャンセル"
                                                          doneButtonTitle:@"確定"
                                                        isMultiInputField:YES
                                                               doneAction:@selector(openTwilogSearch:searchWord:)];
            [alert.multiTextFieldTop setPlaceholder:@"ScreenName"];
            [alert.multiTextFieldBottom setPlaceholder:@"SearchWord"];
            [alert show];
            
        }else if ( buttonIndex == TextFieldTypeFavStar ) {
            
            [self createSearchAlert:@"favstar"
                          alertType:TextFieldTypeFavStar];
            
        }else if ( buttonIndex == TextFieldTypeTwitPic ) {
            
            [self createSearchAlert:@"TwitPic"
                          alertType:TextFieldTypeTwitPic];
            
        }else if ( buttonIndex == TextFieldTypeUserTimeline ) {
            
            [self createSearchAlert:@"UserTimeline"
                          alertType:TextFieldTypeUserTimeline];
            
        }else if ( buttonIndex == TextFieldTypeSearch ) {
            
            [self createSearchAlert:@"TwitterSearch"
                          alertType:TextFieldTypeSearch];
            
        }else if ( buttonIndex == TextFieldTypeSearchStream ) {
            
            [self createSearchAlert:@"SearchStream"
                          alertType:TextFieldTypeSearchStream];
            
        }else if ( buttonIndex == 7 ) {
            
            [ActivityIndicator on];
            [self showAPILimit];
        }
        
    }else if ( tag == ActionMenuTypeMyService ) {
        
        if ( buttonIndex == TextFieldTypeTwilog ) {
            
            [self openTwilog:[TWAccounts currentAccountName]];
            
        }else if ( buttonIndex == TextFieldTypeTwilogSearch ) {
            
            InputAlertView *alert = [[InputAlertView alloc] initWithTitle:@"TwilogSearch"
                                                                 delegate:self
                                                        cancelButtonTitle:@"キャンセル"
                                                          doneButtonTitle:@"確定"
                                                        isMultiInputField:YES
                                                               doneAction:@selector(openTwilogSearch:searchWord:)];
            [alert.multiTextFieldTop setPlaceholder:@"ScreenName"];
            [alert.multiTextFieldTop setText:[TWAccounts currentAccountName]];
            [alert.multiTextFieldBottom setPlaceholder:@"SearchWord"];
            [alert show];
            [alert.multiTextFieldBottom becomeFirstResponder];
            
        }else if ( buttonIndex == TextFieldTypeFavStar ) {
            
            [self openFavStar:[TWAccounts currentAccountName]];
            
        }else if ( buttonIndex == TextFieldTypeTwitPic ) {
            
            [self openTwitPic:[TWAccounts currentAccountName]];
            
        }else if ( buttonIndex == TextFieldTypeUserTimeline ) {
            
            [self requestUserTimeline:[TWAccounts currentAccountName]];
            
        }else if ( buttonIndex == TextFieldTypeSearch ) {
            
            [self requestSearch:[TWAccounts currentAccountName]];
        }
    
    }else if ( tag == ActionMenuTypeTimelineLongPress ) {
        
        [self setLongPressControl:0];
        
        if ( buttonIndex != 3 && buttonIndex != 4 ) {
            
            [self closeStream];
            [self.currentTweets removeAllObjects];
            [self setCurrentTweets:nil];
            [self setCurrentTweets:BLANK_M_ARRAY];
            [TWTweets saveCurrentTimeline:self.currentTweets];
            
            if ( buttonIndex == 0 ) {
                
            }else if ( buttonIndex == 1 || buttonIndex == 2 ) {
                
                //各アカウントのログを削除
                for ( ACAccount *account in [TWAccounts twitterAccounts] ) {
                    
                    [[[TWTweets manager] timelines] setObject:[NSMutableArray array]
                                                       forKey:account.username];
                }
                
                [[Share images] removeAllObjects];
                
                if ( buttonIndex == 2 ) {
                    
                    ASYNC_MAIN_QUEUE ^{
                        
                        [ICON_BUTTON setImage:nil
                                     forState:UIControlStateNormal];
                    });
                    
                    //アイコンファイルを削除
                    [[NSFileManager defaultManager] removeItemAtPath:ICONS_DIRECTORY
                                                               error:nil];
                    
                    //フォルダを再作成
                    [FILE_MANAGER createDirectoryAtPath:ICONS_DIRECTORY
                            withIntermediateDirectories:YES
                                             attributes:nil
                                                  error:nil];
                }
            }
            
            [self.timeline reloadData];
            
        }else if ( buttonIndex == 3 ) {
            
            //NG情報を再適用
            
            //NG判定を行う
            ASYNC_MAIN_QUEUE ^{
                
                dispatch_queue_t queue = GLOBAL_QUEUE_DEFAULT;
                dispatch_semaphore_t semaphore = dispatch_semaphore_create(1);
                dispatch_sync(queue, ^{
                    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
                    
                    [self setCurrentTweets:[NSMutableArray arrayWithArray:[TWNgTweet ngAll:self.currentTweets]]];
                    
                    dispatch_semaphore_signal(semaphore);
                });
                
                [TWTweets saveCurrentTimeline:self.currentTweets];
                [self.timeline reloadData];
            });
            
        } else {
            
            //キャンセル
            return;
        }
    }
}

#pragma mark - AlertView
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if ( buttonIndex == 1 ) {
        
        NSInteger tag = alertView.tag;
        NSString *inputText = self.searchAlertTextField.text;
        
        if ( [inputText isNotEmpty] ) {
            
            switch ( tag ) {
                    
                case TextFieldTypeTwilog:
                    
                    [self openTwilog:inputText];
                    break;
                    
                case TextFieldTypeTwilogSearch:
                    
                    [ShowAlert error:@"未実装"];
                    break;
                    
                case TextFieldTypeFavStar:
                    
                    [self openFavStar:inputText];
                    break;
                    
                case TextFieldTypeTwitPic:
                    
                    [self openTwitPic:inputText];
                    break;
                    
                case TextFieldTypeUserTimeline:
                    
                    [self requestUserTimeline:inputText];
                    break;
                    
                case TextFieldTypeSearch:
                    
                    [self requestSearch:inputText];
                    break;
                    
                case TextFieldTypeSearchStream:
                    
                    [self closeStream];
                    [self setSearchStream:YES];
                    [self requestSearch:inputText];
                    break;
                    
                default:
                    break;
            }
        }
    }
    
    [self.searchAlertTextField resignFirstResponder];
    [self setSearchAlert:nil];
    [self setSearchAlertTextField:nil];
}

#pragma mark - TextField
- (BOOL)textFieldShouldReturn:(SwipeShiftTextField *)sender {
    
    NSInteger tag = sender.tag;
    NSString *inputText = self.searchAlertTextField.text;
    
    if ( [inputText isNotEmpty] ) {
        
        switch ( tag ) {
                
            case TextFieldTypeTwilog:
                
                [self openTwilog:inputText];
                break;
                
            case TextFieldTypeTwilogSearch:
                
                break;
                
            case TextFieldTypeFavStar:
                
                [self openFavStar:inputText];
                break;
                
            case TextFieldTypeTwitPic:
                
                [self openTwitPic:inputText];
                break;
                
            case TextFieldTypeUserTimeline:
                
                [self requestUserTimeline:inputText];
                break;
                
            case TextFieldTypeSearch:
                
                [self requestSearch:inputText];
                break;
                
            case TextFieldTypeSearchStream:
                
                [self closeStream];
                [self setSearchStream:YES];
                [self requestSearch:inputText];
                break;
                
            default:
                break;
        }
    }
    
    [sender resignFirstResponder];
    [self.searchAlert dismissWithClickedButtonIndex:0
                                           animated:YES];
    [self setSearchAlert:nil];
    [self setSearchAlertTextField:nil];
    
    return YES;
}

#pragma mark - Segment
- (void)changeSegmentIndex {
    
    NSLog(@"%s: %d", __func__, self.segment.selectedSegmentIndex);
    
    if ( self.pickerVisible ) [self hidePicker];
    
    if ( self.segment.selectedSegmentIndex == TimelineSegmentTimeline ) {
        
        [USER_STREAM_BUTTON setEnabled:YES];
        
    } else {
        
        [USER_STREAM_BUTTON setEnabled:NO];
    }
    
    NSString *buttonImageName = nil;
    
    if ( self.segment.selectedSegmentIndex == TimelineSegmentList ) {
        
        buttonImageName = @"list.png";
        [USER_STREAM_BUTTON setEnabled:YES];
        
    } else {
        
        if ( self.userStream ) {
        
            buttonImageName = @"stop.png";
            
        } else {
         
            buttonImageName = @"play.png";
        }
    }
    
    [USER_STREAM_BUTTON setImage:[UIImage imageNamed:buttonImageName]
                        forState:UIControlStateNormal];
    
    switch ( self.segment.selectedSegmentIndex ) {
            
        case TimelineSegmentTimeline:
    
            [self setListSelect:NO];
            [self setAddTweetStopMode:NO];
            [self setCurrentTweets:[TWTweets currentTimeline]];
            [self.timeline reloadData];
            
            if ( !self.userStream ) {
            
                [self requestHomeTimeline];
            }
            break;
            
        case TimelineSegmentMentions:
            
            [self setListSelect:NO];
            [self setAddTweetStopMode:YES];
            [self requestMentions];
            break;
            
        case TimelineSegmentFavorites:
            
            [self setListSelect:NO];
            [self setAddTweetStopMode:YES];
            [self requestFavorites];
            break;
        
        case TimelineSegmentList:
            
            [self setListSelect:YES];
            [self setAddTweetStopMode:YES];
            [self showListView];
            break;
            
        default:
            break;
    }
}

#pragma mark - UserStream

- (void)openStream {
    
    dispatch_queue_t userStreamQueue = GLOBAL_QUEUE_BACKGROUND;
    dispatch_async(userStreamQueue, ^{
        
        NSLog(@"%s", __func__);
        
        if ( [D boolForKey:@"USNoAutoLock"] ) [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
        
        //UserStream接続リクエストの作成
        SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeTwitter
                                                requestMethod:TWRequestMethodPOST
                                                          URL:[NSURL URLWithString:@"https://userstream.twitter.com/2/user.json"]
                                                   parameters:nil];
        
        //アカウントの設定
        [request setAccount:[TWAccounts currentAccount]];
        
        [self startUserStreamQueue];
        
        //接続開始
        self.connection = [NSURLConnection connectionWithRequest:request.preparedURLRequest
                                                        delegate:self];
        [self.connection start];
        
        // 終わるまでループさせる
        while ( self.userStream ) {
            
            [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                     beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
        }
        
        request = nil;
    });
}

- (void)closeStream {
    
    if ( [D boolForKey:@"USNoAutoLock"] ) [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
    
    [self setUserStream:NO];
    [self.connection cancel];
    [self setConnection:nil];
    [self stopUserStreamQueue];
    
    dispatch_async(dispatch_get_main_queue(), ^{
       
        [USER_STREAM_BUTTON setImage:[UIImage imageNamed:@"play.png"]
                            forState:UIControlStateNormal];
        [USER_STREAM_BUTTON setEnabled:YES];
    });
}

- (void)reOpenStream {
    
    [self closeStream];
    
    NSLog(@"%s", __func__);
    
    DISPATCH_AFTER(10.0) ^{
     
        NSLog(@"Connection ReStart");
        
        if ( [InternetConnection enable] ) {
            
            [self addTaskNotification:@"Timeline再読み込み"];
            [self pushReloadButton];
        }
    });
}

- (void)startUserStreamQueue {
    
    [self setUserStreamQueue:[@[] mutableCopy]];
    self.userStreamTimer = [NSTimer scheduledTimerWithTimeInterval:0.2
                                                            target:self
                                                          selector:@selector(checkUserStreamQueue)
                                                          userInfo:nil
                                                           repeats:YES];
    [self.userStreamTimer fire];
}

- (void)stopUserStreamQueue {
    
    [self.userStreamTimer invalidate];
}

- (oneway void)checkUserStreamQueue {
 
    if ( [self.userStreamQueue count] != 0 ) {
        
        if ( !self.addTweetStopMode ) {
         
            TWTweet *addTweet = self.userStreamQueue[0];
            
            if ( [addTweet.eventType isNotEmpty] &&
                  addTweet.favoriteEventeType == FavoriteEventTypeReceive ) {
                
                //ふぁぼられ
                [self userStreamReceiveFavEvent:addTweet];
                
            } else {
            
                [self userStreamReceiveTweet:addTweet];
            }
            
            [self.userStreamQueue removeObjectAtIndex:0];
        }
    }
}

- (oneway void)userStreamDelete:(TWTweet *)receiveTweet {
    
    NSLog(@"%s", __func__);
    
    NSString  *tweetID = receiveTweet.tweetID;
    NSInteger index = 0;
    BOOL find = NO;
    
    @synchronized(self) {
        
        for ( TWTweet *tweet in self.currentTweets ) {
            
            if ( [tweet.tweetID isEqualToString:tweetID] ) {
                
                find = YES;
                break;
            }
            
            index++;
        }
        
        if ( find ) {
            
            [self.currentTweets removeObjectAtIndex:index];
            [TWTweets saveCurrentTimeline:self.currentTweets];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [self.timeline deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index
                                                                           inSection:0]]
                                     withRowAnimation:UITableViewRowAnimationTop];
            });
        }
    }
}

- (oneway void)userStreamMyAddFavEvent:(TWTweet *)receiveTweet {
    
    NSLog(@"%s", __func__);
    
    //自分のふぁぼりイベント
    NSString *favedTweetID = receiveTweet.tweetID;
    [self changeFavorite:favedTweetID];
}

- (oneway void)userStreamMyRemoveFavEvent:(TWTweet *)receiveTweet {
    
    NSLog(@"%s", __func__);
    
    //自分のふぁぼり外しイベント
    NSString *unFavedTweetID = receiveTweet.tweetID;
    
    @synchronized(self) {
        
        NSInteger index = 0;
        for ( TWTweet *tweet in self.currentTweets ) {
            
            if ( [tweet.tweetID isEqualToString:unFavedTweetID] ) {
                
                TWTweet *favedTweet = tweet;
                [favedTweet setIsFavorited:NO];
                [favedTweet createTimelineCellInfo];
                
                [self.currentTweets replaceObjectAtIndex:index withObject:favedTweet];
                [TWTweets saveCurrentTimeline:self.currentTweets];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    [self.timeline reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index
                                                                               inSection:0]]
                                         withRowAnimation:UITableViewRowAnimationLeft];
                });
                
                break;
            }
            
            index++;
        }
    }
}

- (oneway void)userStreamReceiveFavEvent:(TWTweet *)receiveTweet {
    
    NSLog(@"%s", __func__);
    
    if ( [[Share images] objectForKey:receiveTweet.favUser] == nil ) {
        
        [self getIconWithTweetArray:[NSMutableArray arrayWithArray:@[receiveTweet]]];
    }
    
    @synchronized(self) {
        
        [self.currentTweets insertObject:receiveTweet
                                 atIndex:0];
        [TWTweets saveCurrentTimeline:self.currentTweets];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [self.timeline insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0
                                                                   inSection:0]]
                             withRowAnimation:UITableViewRowAnimationTop];
    });
}

- (oneway void)userStreamReceiveTweet:(TWTweet *)receiveTweet {
    
    if ( self.segment.selectedSegmentIndex == TimelineSegmentTimeline ) {
     
        NSUInteger beforeCount = self.currentTweets.count;
        
        @synchronized(self) {
            
            //タイムラインに追加
            if ( receiveTweet.isReTweet ) {
                
                [self.currentTweets insertObject:receiveTweet
                                         atIndex:0];
                
            } else {
                
                [self setCurrentTweets:[self.currentTweets appendOnlyNewTweetToTop:@[receiveTweet]
                                                                     returnMutable:YES]];
            }
            
            //タイムラインを保存
            [TWTweets saveCurrentTimeline:self.currentTweets];
        }
        
        if ( beforeCount == self.currentTweets.count ) {
            
            return;
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [self.timeline insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0
                                                                       inSection:0]]
                                 withRowAnimation:UITableViewRowAnimationTop];
        });
        
        //アイコン保存
        [self getIconWithTweetArray:[NSMutableArray arrayWithArray:@[receiveTweet]]];
    }
}

#pragma mark - SearchStream

- (void)openSearchStream:(NSString *)searchWord {
    
    if ( self.pickerVisible ) [self hidePicker];
    [self.topBar setItems:TOP_BAR_ITEM_OTHER];
    
    dispatch_queue_t userStreamQueue = GLOBAL_QUEUE_BACKGROUND;
    dispatch_async(userStreamQueue, ^{
        
        NSLog(@"%s", __func__);
        
        if ( [D boolForKey:@"USNoAutoLock"] ) [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
        
        SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeTwitter
                                                requestMethod:TWRequestMethodPOST
                                                          URL:[NSURL URLWithString:@"https://stream.twitter.com/1.1/statuses/filter.json"]
                                                   parameters:@{@"track" : searchWord}];
        
        //アカウントの設定
        [request setAccount:[TWAccounts currentAccount]];
        
        [self startSearchStreamQueue];
        
        //接続開始
        self.connection = [NSURLConnection connectionWithRequest:request.preparedURLRequest
                                                        delegate:self];
        [self.connection start];
        
        // 終わるまでループさせる
        while ( self.searchStream ) {
            
            [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                     beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
        }
        
        request = nil;
    });
}

- (void)closeSearchStream {
    
    NSLog(@"%s", __func__);
    
    if ( [D boolForKey:@"USNoAutoLock"] ) [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
    
    [self setSearchStream:NO];
    [self.connection cancel];
    [self setConnection:nil];
    [self stopSearchStreamQueue];
}

- (void)startSearchStreamQueue {
    
    NSLog(@"%s", __func__);
    
    [self setUserStreamQueue:[@[] mutableCopy]];
    self.userStreamTimer = [NSTimer scheduledTimerWithTimeInterval:0.2
                                                            target:self
                                                          selector:@selector(checkSearchStreamQueue)
                                                          userInfo:nil
                                                           repeats:YES];
    [self.userStreamTimer fire];
}

- (void)stopSearchStreamQueue {
    
    NSLog(@"%s", __func__);
    
    [self.userStreamTimer invalidate];
}

- (oneway void)checkSearchStreamQueue {
    
    if ( [self.userStreamQueue count] != 0 ) {
        
        if ( !self.addTweetStopMode ) {
         
            TWTweet *addTweet = self.userStreamQueue[0];
            [self searchStreamReceiveTweet:addTweet];
            [self.userStreamQueue removeObjectAtIndex:0];
        }
    }
}

- (oneway void)searchStreamReceiveTweet:(TWTweet *)receiveTweet {
    
//    NSLog(@"%s", __func__);
    
    if ( self.segment.selectedSegmentIndex == TimelineSegmentTimeline ) {
        
        @synchronized(self) {
            
            //タイムラインに追加
            [self.currentTweets insertObject:receiveTweet
                                     atIndex:0];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [self.timeline insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0
                                                                       inSection:0]]
                                 withRowAnimation:UITableViewRowAnimationTop];
        });
        
        //アイコン保存
        [self getIconWithTweetArray:[NSMutableArray arrayWithArray:@[receiveTweet]]];
    }
}

#pragma mark - NSURLConnectionDataDelegate
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    
    NSError *error = nil;
    id receiveData = [NSJSONSerialization JSONObjectWithData:data
                                                     options:NSJSONReadingMutableLeaves
                                                       error:&error];
    
    if ( error != nil ) return;
    
    if ( [receiveData isKindOfClass:[NSDictionary class]] ) {
        
        NSDictionary *receiveDic = (NSDictionary *)receiveData;
        
        if ( [receiveDic count] == 0 ) return;
        if ( [receiveDic count] == 1 && receiveDic[@"friends"] != nil ) return;
        
        TWTweet *receiveTweet = [TWTweet tweetWithDictionary:receiveDic];
        if (receiveTweet == nil ) return;
        
        if ( self.searchStream ) {
            
            if ( !receiveTweet.isEvent &&
                 !receiveTweet.isDelete ) {
            
                @synchronized(self) {
                    
                    [self.userStreamQueue addObject:receiveTweet];
                }
            }
            return;
        }
        
        if ( [receiveTweet.eventType isNotEmpty] &&
              receiveTweet.favoriteEventeType == FavoriteEventTypeReceive ) {
            
            @synchronized(self) {
                
                //ふぁぼられイベント
                [self.userStreamQueue addObject:receiveTweet];
            }
            return;
        }
        
        if ( receiveTweet.isDelete ) {
            
            NSLog(@"UserStream Delete Event");
            
            //削除イベント
            [self userStreamDelete:receiveTweet];
            return;
        }
        
        if ( [receiveTweet.eventType isNotEmpty] &&
             receiveTweet.favoriteEventeType == FavoriteEventTypeAdd ) {
            
            NSLog(@"UserStream Add Fav Event");
            
            //自分のふぁぼりイベント
            [self userStreamMyAddFavEvent:receiveTweet];
            return;
            
        }else if ( [receiveTweet.eventType isNotEmpty] &&
                    receiveTweet.favoriteEventeType == FavoriteEventTypeRemove ) {
            
            if ( self.currentTweets.count == 0 ) return;
            
            NSLog(@"UserStream Remove Fav Event");
            
            //自分のふぁぼ外しイベント
            [self userStreamMyRemoveFavEvent:receiveTweet];
            return;
            
        }else if ( receiveTweet.isEvent ) {
            
            return;
        }
        
        NSArray *newTweet = @[receiveTweet];
        
        if ( !receiveTweet.isEvent &&
             !receiveTweet.isDelete ) {
            
            //NG判定を行う
            newTweet = [TWNgTweet ngAll:newTweet];
            
            //新着が無いので終了
            if ( [newTweet count] == 0 ) return;
        }
        
        @synchronized(self) {
            
            //通常Post向け処理
            [self.userStreamQueue addObject:receiveTweet];
        }
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
    NSLog(@"didReceiveResponse:%d, %lld", httpResponse.statusCode, response.expectedContentLength);
    
    if ( httpResponse.statusCode == 200 ) {
        
        if ( !self.searchStream ) {
        
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [USER_STREAM_BUTTON setImage:[UIImage imageNamed:@"stop.png"]
                                    forState:UIControlStateNormal];
                [USER_STREAM_BUTTON setEnabled:YES];
            });
        }
        
    } else {
        
        [self closeStream];
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    
    NSLog(@"%s", __func__);
    [self closeStream];
}

#pragma mark - NSURLConnectionDelegate
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    
    NSLog(@"%s", __func__);
    
    [self reOpenStream];
}

#pragma mark - Timeline
- (void)getIconWithTweetArray:(NSMutableArray *)tweetArray {
    
    NSMutableDictionary *userList = [NSMutableDictionary dictionary];
    
    //重複ユーザーを消す
    for ( TWTweet *tweet in tweetArray ) {
        
        NSString *tempScreenName = tweet.screenName;
        
        if ( tweet == nil ||
             tempScreenName == nil ) {
            
            continue;
        }
        
        [userList setObject:tweet
                     forKey:tempScreenName];
        
        if ( tweet.isReTweet &&
             userList[tweet.rtUserName] == nil ) {
            
            TWTweet *reTweet = [[TWTweet alloc] init];
            [reTweet setScreenName:tweet.rtUserName];
            [reTweet setIconURL:tweet.rtIconURL];
            [reTweet setIconSearchPath:tweet.rtIconSearchPath];
            
            [userList setObject:reTweet
                         forKey:tweet.rtUserName];
        }
    }
    
    //  NSLog(@"getIconWithTweetArray delete duplicate user[%d], %@", userList.count, userList);
    
    for ( NSString *userName in userList.allKeys ) {
        
        TWTweet *tweet = userList[userName];
        
        if ( [[Share images] objectForKey:userName] == nil ) {
            
            //キャッシュされていない
            //NSLog(@"No Cache User: %@", userName);
            
            //アイコンのユーザー名
            __block NSString *screenName = tweet.screenName;
            
            //アイコンURL
            NSString *iconURL = tweet.iconURL;
            
            //検索用の名前
            __block NSString *searchName = tweet.iconSearchPath;
            
            if ( [self iconExist:searchName] ) {
                
                //アイコンファイルが保存済み
                //NSLog(@"File Saved: %@", userName);
                
                //アイコンファイルを読み込み
                __block UIImage *image = [UIImage imageWithContentsOfFileByContext:FILE_PATH];
                
                if ( image != nil ) {
                    
                    [Share cacheImage:image
                              forName:screenName
                     doneNotification:NO];
                    
                    NSInteger index = 0;
                    for ( TWTweet *currentTweet in self.currentTweets ) {
                        
                        NSString *currentScreenName = currentTweet.screenName;
                        
                        if ( [currentScreenName isEqualToString:screenName] ) {
                            
                            [self refreshTimelineCell:@(index)];
                        }
                        
                        index++;
                        
                        if ( 8 < index ) break;
                    }
                    
                    //自分のアイコンの場合は上部バーに設定
                    if ( [screenName isEqualToString:[TWAccounts currentAccountName]] ) {
                        
                            [ICON_BUTTON setImage:image
                                         forState:UIControlStateNormal];
                            image = nil;
                    }
                    
                    [ActivityIndicator off];
                    
                } else {
                    
                    [self requestProfileImageWithURL:iconURL
                                          screenName:screenName
                                          searchName:searchName];
                }
                
            } else {
                
                //アイコンファイルが保存されていない
                [self requestProfileImageWithURL:iconURL
                                      screenName:screenName
                                      searchName:searchName];
            }
            
        } else {
            
            //キャッシュ済み
            //NSLog(@"Cached User: %@", userName);
        }
    }
}

- (void)requestProfileImageWithURL:(NSString *)biggerUrl screenName:(NSString *)screenName searchName:(NSString *)searchName {
    
    if ( [screenName isNotEmpty] &&
         [biggerUrl isNotEmpty] &&
         [[biggerUrl lastPathComponent] isNotEmpty] &&
         [searchName isNotEmpty] ) {
        
        NSMutableDictionary *tempDic = BLANK_M_DIC;
        
        //ユーザー名を設定
        [tempDic setObject:screenName
                    forKey:@"screen_name"];
        
        //アイコンURLを設定
        [tempDic setObject:biggerUrl
                    forKey:@"profile_image_url"];
        
        //検索用の名前
        [tempDic setObject:searchName
                    forKey:@"SearchName"];
        
        ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:biggerUrl]];
        [request setUserInfo:tempDic];
        __weak __block ASIHTTPRequest *wRequest = request;
        
        [wRequest setCompletionBlock:^ {
            
            //NSLog(@"Request Finished");
            
            NSString *receiveScreenName = wRequest.userInfo[@"screen_name"];
            
            NSMutableArray *icons = [NSMutableArray array];
            NSArray *iconList = [FILE_MANAGER contentsOfDirectoryAtPath:ICONS_DIRECTORY
                                                                  error:nil];
            NSString *searchIconName = [NSString stringWithFormat:@"%@-", receiveScreenName];
            
            if ( iconList.count != 0 ) {
                
                for ( NSString *filePath in iconList ) {
                    
                    if ( [filePath hasPrefix:searchIconName] ) {
                        
                        [icons addObject:filePath];
                    }
                }
                
                if ( icons.count != 0 ) {
                    
                    [[Share images] removeObjectForKey:receiveScreenName];
                    
                    for ( NSString *deletePath in icons ) {
                        
                        [FILE_MANAGER removeItemAtPath:[ICONS_DIRECTORY stringByAppendingPathComponent:deletePath]
                                                 error:nil];
                    }
                }
            }
            
            if ( ![self iconExist:searchName] ) {
                
                [wRequest.responseData writeToFile:FILE_PATH
                                        atomically:YES];
            }
            
            UIImage *receiveImage = [UIImage imageWithDataByContext:wRequest.responseData];

            NSString *iconQualitySetting = [D objectForKey:@"IconQuality"];
            if ( [iconQualitySetting isEqualToString:@"Original96"] ) {
                
                receiveImage = [ResizeImage aspectResizeForMaxSize:receiveImage
                                                           maxSize:96.0f];
            }
            
            if ( receiveImage != nil ) {
                
                [Share cacheImage:receiveImage
                          forName:receiveScreenName
                 doneNotification:NO];
                
                receiveImage = nil;
                
                if ( [screenName isEqualToString:[TWAccounts currentAccountName]] ) {
                    
                        [ICON_BUTTON setImage:receiveImage
                                            forState:UIControlStateNormal];
                }
                
                NSInteger index = 0;
                for ( TWTweet *tweet in self.currentTweets ) {
                    
                    NSString *currentScreenName = tweet.screenName;
                    
                    if ( [currentScreenName isEqualToString:screenName] ) {
                        
                        [self refreshTimelineCell:@(index)];
                        
                    } else {
                        
                        if ( tweet.isReTweet ) {
                            
                            currentScreenName = tweet.rtUserName;
                            
                            if ( [currentScreenName isEqualToString:screenName] ) {
                                
                                [self refreshTimelineCell:@(index)];
                            }
                        }
                    }
                    
                    index++;
                }
            }
            
            wRequest = nil;
        }];
        
        [request startAsynchronous];
    }
}

- (void)refreshTimelineCell:(NSNumber *)index {
    
//    NSLog(@"%s", __func__);
    
    [self setAddTweetStopMode:YES];
    
    NSInteger i = [index intValue];
    
    if ( self.currentTweets[i] == nil ||
         self.currentTweets.count - 1 < i ) return;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [self.timeline reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:i
                                                                   inSection:0]]
                             withRowAnimation:UITableViewRowAnimationNone];
        [self setAddTweetStopMode:NO];
    });
}

- (void)openTimelineImage:(NSNotification *)notification {
    
    if ( notification.userInfo[@"URL"] != nil ) {
        
        NSString *urlString = notification.userInfo[@"URL"];
        [self.imageWindow loadImage:urlString
                           viewRect:self.timeline.frame];
    }
}

- (void)openTimelineURL:(NSNotification *)notification {
    
    NSString *urlString = notification.userInfo[@"URL"];
    
    if ( urlString == nil ) return;
    
    [self openBrowser:urlString];
}

- (void)swipeTimelineRight:(UISwipeGestureRecognizer *)sender {
    
    NSLog(@"%s", __func__);
    
    //ピッカー表示中の場合は隠す
    if ( self.pickerVisible ) [self hidePicker];
    if ( self.segment.selectedSegmentIndex == TimelineSegmentList ) {
        
        [self showListView];
        
    } else {
        
        //InReplyTto表示中は何もしない
//        if ( _otherTweetsMode ) return;
        
        NSInteger num = [D integerForKey:@"UseAccount"] - 1;
        
        if ( num < 0 ) {
         
            [self.tabBarController setSelectedIndex:0];
            return;
        }
        
        NSInteger accountCount = [TWAccounts accountCount] - 1;
        
        if ( accountCount >= num ) {
            
            if ( self.userStream ) [self closeStream];
            
            [D setInteger:num
                   forKey:@"UseAccount"];
            [self setCurrentTweets:[TWTweets currentTimeline]];
            [self.timeline reloadData];
            [self.segment setSelectedSegmentIndex:0];
            [self requestHomeTimeline];
        }
    }
}

- (void)swipeTimelineLeft:(UISwipeGestureRecognizer *)sender {
    
    NSLog(@"%s", __func__);
    
    //ピッカー表示中の場合は隠す
    if ( self.pickerVisible ) [self hidePicker];
    if ( !self.timeline.isScrollEnabled ) {
        
        [self hideTimelineMenu:nil];
        return;
    }

    if ( self.segment.selectedSegmentIndex == 3 ) return;

    //InReplyTto表示中は何もしない
//    if ( _otherTweetsMode ) return;

    NSInteger num = [D integerForKey:@"UseAccount"] + 1;
    NSInteger accountCount = [TWAccounts accountCount] - 1;
    
    if ( accountCount >= num ) {
        
        if ( self.userStream ) [self closeStream];
        
        [D setInteger:num
               forKey:@"UseAccount"];
        [self setCurrentTweets:[TWTweets currentTimeline]];
        [self.timeline reloadData];
        [self.segment setSelectedSegmentIndex:0];
        [self requestHomeTimeline];
    }
}

- (void)scrollTimelineToTop:(BOOL)animation {
    
    NSLog(@"%s", __func__);
    
    if ( self.currentTweets == nil ||
         self.currentTweets.count == 0 ) return;
    
    [self.timeline scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0
                                                             inSection:0]
                         atScrollPosition:UITableViewScrollPositionBottom
                                 animated:animation];
}

- (void)scrollTimelineToBottom:(BOOL)animation {
    
    NSLog(@"%s", __func__);
    
    if ( self.currentTweets == nil ||
         self.currentTweets.count == 0 ) return;
    
    [self.timeline scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[self.currentTweets count] - 1
                                                             inSection:0]
                         atScrollPosition:UITableViewScrollPositionBottom
                                 animated:animation];
}

- (void)scrollTimelineForNewTweet:(NSString *)tweetID {
    
    NSLog(@"%s", __func__);
    
    if ( self.currentTweets == nil ||
         self.currentTweets.count == 0 ) return;
    
    if ( tweetID == nil ||
        [tweetID isEmpty] ) return;
    
    NSInteger index = 0;
    BOOL find = NO;
    for ( TWTweet *tweet in [TWTweets currentTimeline] ) {
        
        if ( tweet.tweetID != nil &&
            [tweet.tweetID isEqualToString:tweetID] ) {
            
            find = YES;
            break;
        }
        
        index++;
    }
    
    if ( find ) {
        
        if ( self.currentTweets.count < index ||
            [self.currentTweets objectAtIndex:index] == nil ) return;
        
        [self.timeline scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:index
                                                                 inSection:0]
                             atScrollPosition:UITableViewScrollPositionBottom
                                     animated:YES];
    }
}

- (void)longPressTimeline:(UILongPressGestureRecognizer *)sender {
    
    if ( self.longPressControl == 0 ) {
        
        [self setLongPressControl:1];
        
        UIActionSheet *sheet = [[UIActionSheet alloc]
                                initWithTitle:@"ログ削除"
                                delegate:self
                                cancelButtonTitle:@"Cancel"
                                destructiveButtonTitle:nil
                                otherButtonTitles:@"現在のアカウントのTimelineログを削除", @"全てのTimelineログを削除",
                                @"全てのログとアイコンキャッシュを削除", @"タイムラインにNG情報を再適用", nil];
        [sheet setTag:ActionMenuTypeTimelineLongPress];
        [sheet showInView:self.tabBarController.view];
    }
}

- (void)pushIcon:(IconButton *)sender {
    
    if ( !self.timeline.isScrollEnabled ) {
        
        [self hideTimelineMenu:nil];
        
    } else {
        
        NSString *screenName = sender.targetTweet.screenName;
        NSString *tweetID = sender.targetTweet.tweetID;
        
        if ( [D integerForKey:@"TimelineIconAction"] == TimelineIconActionTypeUserMenu ) {
            
        }else if ( [D integerForKey:@"TimelineIconAction"] == TimelineIconActionTypeReply ) {
            
            screenName = [NSString stringWithFormat:@"@%@ ", screenName];
            
            NSNotification *notification = [NSNotification notificationWithName:@"SetTweetViewText"
                                                                         object:nil
                                                                       userInfo:
                                            @{
                                            @"Text" : screenName,
                                            @"InReplyToID" : tweetID
                                            }];
            [[NSNotificationCenter defaultCenter] postNotification:notification];
            [self.tabBarController setSelectedIndex:0];
            
        }else if ( [D integerForKey:@"TimelineIconAction"] == TimelineIconActionTypeFav ) {
            
            BOOL favorited = sender.targetTweet.isFavorited;
            
            if ( favorited ) {
                
                [TWEvent unFavorite:tweetID
                       accountIndex:[D integerForKey:@"UseAccount"]];
                
            } else {
                
                [self changeFavorite:tweetID];
                [self addFavorite:tweetID
                     accountIndex:[D integerForKey:@"UseAccount"]];
            }
            
        }else if ( [D integerForKey:@"TimelineIconAction"] == TimelineIconActionTypeRT ) {
            
            [TWEvent reTweet:tweetID
                accountIndex:[D integerForKey:@"UseAccount"]];
            
        }else if ( [D integerForKey:@"TimelineIconAction"] == TimelineIconActionTypeFavRT ) {
            
            [TWEvent favoriteReTweet:tweetID
                        accountIndex:[D integerForKey:@"UseAccount"]];
            
        }else if ( [D integerForKey:@"TimelineIconAction"] == TimelineIconActionTypeSelectIDFavRT ) {
            
            [self setSelectedTweet:sender.targetTweet];
            [self timelineMenuSelectID:nil];
        }
    }
}

- (void)changeFavorite:(NSString *)targerTweetID {
    
    NSLog(@"%s", __func__);
    
    NSInteger index = 0;
    for ( TWTweet *tweet in self.currentTweets ) {
        
        if ( [tweet.tweetID isEqualToString:targerTweetID] ) {
            
            if ( !tweet.isFavorited ) {
                
                TWTweet *favedTweet = tweet;
                [favedTweet setIsFavorited:YES];
                [favedTweet setTextColor:CellTextColorGold];
                
                @synchronized(self) {
                    
                    [self.currentTweets replaceObjectAtIndex:index
                                                  withObject:favedTweet];
                    [TWTweets saveCurrentTimeline:self.currentTweets];
                }
                
                dispatch_async(dispatch_get_main_queue(), ^{
                
                    [self.timeline reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index
                                                                               inSection:0]]
                                         withRowAnimation:UITableViewRowAnimationLeft];
                });
                break;
            }
        }
        
        index++;
    }
}

- (void)hideTimelineMenu:(NSNotification *)notification {
    
    DISPATCH_AFTER(0.2) ^{
        
        [UIView animateWithDuration:0.2
                         animations:^{
                             
                             [self.topBar setFrame:CGRectMake(0.0f,
                                                              self.topBar.frame.origin.y,
                                                              self.topBar.frame.size.width,
                                                              self.topBar.frame.size.height)];
                             
                             [self.segment setFrame:CGRectMake(0.0f,
                                                               self.segment.frame.origin.y,
                                                               self.segment.frame.size.width,
                                                               self.segment.frame.size.height)];
                             
                             [self.timeline setFrame:CGRectMake(0.0f,
                                                                self.timeline.frame.origin.y,
                                                                self.timeline.frame.size.width,
                                                                self.timeline.frame.size.height)];
                         }
                         completion:^(BOOL finished) {
                             
                             [self.topBar setUserInteractionEnabled:YES];
                             [self.segment setUserInteractionEnabled:YES];
                             [self.timeline setScrollEnabled:YES];
                             
                             if ( self.timelineMenu != nil ) [self.timelineMenu removeFromSuperview];
                             [self setTimelineMenu:nil];
                         }
         ];
    });
    
    [UIView animateWithDuration:0.3f
                     animations:^{
                         
                         [self.timelineMenu setAlpha:0.0f];
                         [self.timelineMenu setFrame:CGRectMake(self.timelineMenu.frame.origin.x,
                                                                self.timelineMenu.frame.size.height,
                                                                self.timelineMenu.frame.size.width,
                                                                self.timelineMenu.frame.size.height)];
                     }
     ];
}

- (void)timelineMenuSelectID:(NSNotification *)notification {
    
    [self hideTimelineMenu:nil];
    
    DISPATCH_AFTER(0.5) ^{
       
        [self showPickerView];
    });
}

- (void)timelineMenuHashTagNG:(NSNotification *)notification {
    
    NSLog(@"%s", __func__);
    
    NSString *hashTag = [self.selectedTweet.text stringWithRegExp:@"((?:\\A|\\z|[\x0009-\x000D\x0020\xC2\x85\u00A0\u1680\u180E\u2000-\u200A\u2028\u2029\u202F\u205F\u3000]|[\\[\\]［］()（）{}｛｝‘’“”\"\'｟｠⸨⸩「」｢｣『』〚〛⟦⟧〔〕❲❳〘〙⟬⟭〈〉〈〉⟨⟩《》⟪⟫<>＜＞«»‹›【】〖〗]|。|、|\\.|!))(#|＃)([a-z0-9_\u00C0-\u00D6\u00D8-\u00F6\u00F8-\u00FF\u0400-\u04FF\u0500-\u0527\u1100-\u11FF\u3130-\u3185\uA960-\uA97F\uAC00-\uD7AF\uD7B0-\uD7FF\u30A1-\u30FA\uFF66-\uFF9D\uFF10-\uFF19\uFF21-\uFF3A\uFF41-\uFF5A\u3041-\u3096\u3400-\u4DBF\u4E00-\u9FFF\u020000-\u02A6DF\u02A700-\u02B73F\u02B740-\u02B81F\u02F800-\u02FA1F\u30FC\u3005]*[a-z_\u00C0-\u00D6\u00D8-\u00F6\u00F8-\u00FF\u0400-\u04FF\u0500-\u0527\u1100-\u11FF\u3130-\u3185\uA960-\uA97F\uAC00-\uD7AF\uD7B0-\uD7FF\u30A1-\u30FA\uFF66-\uFF9D\uFF10-\uFF19\uFF21-\uFF3A\uFF41-\uFF5A\u3041-\u3096\u3400-\u4DBF\u4E00-\u9FFF\u020000-\u02A6DF\u02A700-\u02B73F\u02B740-\u02B81F\u02F800-\u02FA1F\u30FC\u3005][a-z0-9_\u00C0-\u00D6\u00D8-\u00F6\u00F8-\u00FF\u0400-\u04FF\u0500-\u0527\u1100-\u11FF\u3130-\u3185\uA960-\uA97F\uAC00-\uD7AF\uD7B0-\uD7FF\u30A1-\u30FA\uFF66-\uFF9D\uFF10-\uFF19\uFF21-\uFF3A\uFF41-\uFF5A\u3041-\u3096\u3400-\u4DBF\u4E00-\u9FFF\u020000-\u02A6DF\u02A700-\u02B73F\u02B740-\u02B81F\u02F800-\u02FA1F\u30FC\u3005]*)(?=(?:\\A|\\z|[\x0009-\x000D\x0020\xC2\x85\u00A0\u1680\u180E\u2000-\u200A\u2028\u2029\u202F\u205F\u3000]|[\\[\\]［］()（）{}｛｝‘’“”\"\'｟｠⸨⸩「」｢｣『』〚〛⟦⟧〔〕❲❳〘〙⟬⟭〈〉〈〉⟨⟩《》⟪⟫<>＜＞«»‹›【】〖〗]|。|、|\\.|!))"];
    
    if ( [hashTag isNotEmpty] ) {
        
        NSMutableDictionary *addDic = BLANK_M_DIC;
        
        //NGワード設定を読み込む
        NSMutableArray *ngWordArray = [NSMutableArray arrayWithArray:[D objectForKey:@"NGWord"]];
        
        //NGワードに追加
        [addDic setObject:[DeleteWhiteSpace string:hashTag]
                   forKey:@"Word"];
        [ngWordArray addObject:addDic];
        
        //設定に反映
        [D setObject:ngWordArray
              forKey:@"NGWord"];
        
        //タイムラインにNGワードを適用
        [self setCurrentTweets:[NSMutableArray arrayWithArray:[TWNgTweet ngWord:[NSArray arrayWithArray:self.currentTweets]]]];
        
        //タイムラインを保存
        [TWTweets saveCurrentTimeline:self.currentTweets];
        [self.timeline reloadData];
        
    } else {
        
        ASYNC_MAIN_QUEUE ^{
            
            [ShowAlert error:@"ハッシュタグが見つかりませんでした。"];
        });
    }
}

- (void)timelineMenuClientNG:(NSNotification *)notification {
    
    NSLog(@"%s", __func__);
    
    NSMutableDictionary *addDic = BLANK_M_DIC;
    
    NSString *clientName = self.selectedTweet.source;
    
    //NGクライアント設定を読み込む
    NSMutableArray *ngClientArray = [NSMutableArray arrayWithArray:[D objectForKey:@"NGClient"]];
    
    if ( clientName != nil ) {
        
        [addDic setObject:clientName
                   forKey:@"Client"];
        [ngClientArray addObject:addDic];
        
        [D setObject:ngClientArray
              forKey:@"NGClient"];
        
        //タイムラインにNGワードを適用
        [self setCurrentTweets:[NSMutableArray arrayWithArray:[TWNgTweet ngClient:[NSArray arrayWithArray:self.currentTweets]]]];
        
        //タイムラインを保存
        [TWTweets saveCurrentTimeline:self.currentTweets];
        [self.timeline reloadData];
    }
}

- (void)timelineMenuInReplyTo:(NSNotification *)notification {
    
    NSLog(@"%s", __func__);
    [self setOtherTweets:nil];
    [self setOtherTweets:[@[] mutableCopy]];
    [self.otherTweets addObject:self.selectedTweet];
    [self createInReplyToChain:self.selectedTweet];
}

- (void)timelineMenuDelete:(NSNotification *)notification {
    
    NSLog(@"%s", __func__);
    
    NSString *tweetID = self.selectedTweet.tweetID;
    [TWEvent destroy:tweetID];
    
    NSUInteger index = 0;
    BOOL find = NO;
    for ( TWTweet *tweet in self.currentTweets ) {
        
        if ( [tweet.tweetID isEqualToString:tweetID] ) {
            
            find = YES;
            break;
        }
        
        index++;
    }
    
    if ( find ) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [self.currentTweets removeObjectAtIndex:index];
            [TWTweets saveCurrentTimeline:self.currentTweets];
            [self.timeline deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index
                                                                       inSection:0]]
                                 withRowAnimation:UITableViewRowAnimationTop];
        });
    }
}

- (void)timelineMenuEdit:(NSNotification *)notification {
    
    NSLog(@"%s", __func__);
}

#pragma mark - TableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    //TableViewの要素数を返す
	return [self.currentTweets count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    //NSLog(@"cellForRowAtIndexPath: %d", indexPath.row);
    
    TWTweet *currentTweet = self.currentTweets[indexPath.row];
    
    if ( currentTweet.isReTweet ) {
        
        //公式RT
        TimelineAttributedRTCell *cell = (TimelineAttributedRTCell *)[tableView dequeueReusableCellWithIdentifier:RT_CELL_IDENTIFIER];
        
        if ( cell == nil ) {
            
            cell = [[TimelineAttributedRTCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                   reuseIdentifier:RT_CELL_IDENTIFIER
                                                          forWidth:CELL_WIDTH];
            [cell.iconView addTarget:self
                              action:@selector(pushIcon:)
                    forControlEvents:UIControlEventTouchUpInside];
        }
        
        [cell setTweetData:currentTweet
                 cellWidth:CELL_WIDTH];
        
        return cell;
        
    } else {
        
        TimelineAttributedCell *cell = (TimelineAttributedCell *)[tableView dequeueReusableCellWithIdentifier:CELL_IDENTIFIER];
    
        if ( cell == nil ) {
            
            cell = [[TimelineAttributedCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                 reuseIdentifier:CELL_IDENTIFIER
                                                        forWidth:CELL_WIDTH];
            
            [cell.iconView addTarget:self
                              action:@selector(pushIcon:)
                    forControlEvents:UIControlEventTouchUpInside];
        }
        
        [cell setTweetData:currentTweet
                 cellWidth:CELL_WIDTH];
        
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    //セルの高さを設定
    TWTweet *currentTweet = self.currentTweets[indexPath.row];
    CGFloat heightOffset = 25.0f;
    
    if ( currentTweet.favoriteEventeType == FavoriteEventTypeReceive ) {
        
        return [[NSString stringWithFormat:@"【%@がお気に入りに追加】\n%@",
                 currentTweet.favUser,
                 currentTweet.text]
                heightForContents:[UIFont systemFontOfSize:12.0f]
                toWidht:264.0f
                minHeight:31.0f
                lineBreakMode:NSLineBreakByCharWrapping] + heightOffset;
    }
    
    if ( currentTweet.isReTweet &&
         currentTweet.cellHeight == 31.0f ) {
        
        heightOffset += 6.0f;
    }
    
    return currentTweet.cellHeight + heightOffset;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath
                             animated:YES];
    
    if ( !self.timeline.isScrollEnabled ) {
        
        [self hideTimelineMenu:nil];
        
    } else {
     
        TWTweet *selectedTweet = self.currentTweets[indexPath.row];
        
        if ( selectedTweet.isEvent ) {
            
            NSString *targetId = self.selectedTweet.tweetID;
            NSString *favStarUrl = [NSString stringWithFormat:@"http://ja.favstar.fm/users/%@/status/%@",
                                    [TWAccounts currentAccountName],
                                    targetId];
            [self openBrowser:favStarUrl];
            
        } else {
            
            [self.timeline setScrollEnabled:NO];
            [self setSelectedTweet:selectedTweet];
            [self createTimelineMenu:TimeLineMenuIdentifierMain];
        }
    }
}

- (void)createTimelineMenu:(TimeLineMenuIdentifier)menuIdentifier {
    
    [self.topBar setUserInteractionEnabled:NO];
    [self.segment setUserInteractionEnabled:NO];
    
    self.timelineMenu = [[TimelineMenu alloc] initWithTweet:self.selectedTweet
                                                    forMenu:TimeLineMenuIdentifierMain
                                                 controller:self];
    [self.timelineMenu setAlpha:0.0f];
    [self.view addSubview:self.timelineMenu];
    
    DISPATCH_AFTER(0.1) ^{
        
        [UIView animateWithDuration:0.3f
                         animations:^{
                             
                             [self.timelineMenu setAlpha:1.0f];
                             [self.timelineMenu setFrame:CGRectMake(self.timelineMenu.frame.origin.x,
                                                                    0.0f,
                                                                    self.timelineMenu.frame.size.width,
                                                                    self.timelineMenu.frame.size.height)];
                         }
         ];
    });
    
    [UIView animateWithDuration:0.2f
                     animations:^{
                         
                         self.topBar.frame = CGRectMake(266.0f,
                                                        self.topBar.frame.origin.y,
                                                        self.topBar.frame.size.width,
                                                        self.topBar.frame.size.height);
                         
                         self.segment.frame = CGRectMake(266.0f,
                                                         self.segment.frame.origin.y,
                                                         self.segment.frame.size.width,
                                                         self.segment.frame.size.height);
                         
                         self.timeline.frame = CGRectMake(266.0f,
                                                          self.timeline.frame.origin.y,
                                                          self.timeline.frame.size.width,
                                                          self.timeline.frame.size.height);
                     }
     ];
}

- (void)createSearchAlert:(NSString *)title alertType:(TextFieldType)alertType {
    
    self.searchAlert = [[UIAlertView alloc] initWithTitle:title
                                                  message:@"\n"
                                                 delegate:self
                                        cancelButtonTitle:@"キャンセル"
                                        otherButtonTitles:@"確定", nil];
    [self.searchAlert setTag:alertType];
    
    self.searchAlertTextField = [[SwipeShiftTextField alloc] initWithFrame:CGRectMake(12.0f,
                                                                              40.0f,
                                                                              260.0f,
                                                                              25.0f)];
    [self.searchAlertTextField setBackgroundColor:[UIColor whiteColor]];
    [self.searchAlertTextField setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
    [self.searchAlertTextField setDelegate:self];
    [self.searchAlertTextField setText:BLANK];
    [self.searchAlertTextField setTag:alertType];
    [self.searchAlert addSubview:self.searchAlertTextField];
    [self.searchAlert show];
    [self.searchAlertTextField becomeFirstResponder];
}

- (void)getMyAccountIcon {
    
    if ( [[Share images] count] == 0 ) {
        
        NSLog(@"icon file 0");
        
        //アイコンが1つもない場合は自分のアイコンがないので保存を行う
        [FPTRequest requestWithGetType:FPTGetRequestTypeProfile
                            parameters:@{@"screen_name" : [TWAccounts currentAccountName]}];
        return;
    }
    
    NSString *string = BLANK;
    BOOL find = NO;
    
    //NSLog(@"icons key: %@", array);
    
    NSArray *allKeys = [[Share images] allKeys];
    
    for ( string in allKeys ) {
        
        if ( [string hasPrefix:[TWAccounts currentAccountName]] ) {
            
            NSLog(@"icon find");
            
            [ICON_BUTTON setImage:[[Share images] objectForKey:[TWAccounts currentAccountName]]
                         forState:UIControlStateNormal];
            find = YES;
            break;
        }
        
        if ( find ) break;
    }
    
    if ( !find ) {
        
        NSLog(@"icon not found");
        
        [ICON_BUTTON setImage:nil
                     forState:UIControlStateNormal];
        [FPTRequest requestWithGetType:FPTGetRequestTypeProfile
                            parameters:@{@"screen_name" : [TWAccounts currentAccountName]}];
    }
}

- (void)setDefaultTweetsMode {
    
    if ( self.pickerVisible ) [self hidePicker];
    [self.topBar setItems:TOP_BAR_ITEM_DEFAULT];
    [self setAddTweetStopMode:NO];
    
    if ( [self.otherTweets isNotEmpty] ) {
        
        [self.otherTweets removeAllObjects];
    }
}

- (void)setOtherTweetsMode {
    
    if ( self.pickerVisible ) [self hidePicker];
    [self.topBar setItems:TOP_BAR_ITEM_OTHER];
    [self setAddTweetStopMode:YES];
}

- (void)showAPILimit {
    
    NSString *requestURL = [NSString stringWithFormat:@"https://api.twitter.com/1.1/application/rate_limit_status.json"];
    SLRequest *getRequest = [SLRequest requestForServiceType:SLServiceTypeTwitter
                                            requestMethod:TWRequestMethodGET
                                                      URL:[NSURL URLWithString:requestURL]
                                               parameters:nil];
    [getRequest setAccount:[TWAccounts currentAccount]];
    
    [getRequest performRequestWithHandler:^(NSData *responseData,
                                            NSHTTPURLResponse *urlResponse,
                                            NSError *error) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if ( responseData  ) {
                
                NSError *jsonError = nil;
                NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseData
                                                                       options:NSJSONReadingMutableLeaves
                                                                         error:&jsonError];
                
                if ( !jsonError ) {
                    
                    NSDictionary *limits = result[@"resources"];
                    NSMutableString *resultString = [NSMutableString string];
                    
                    for ( NSString *typeKey in limits ) {
                        
                        NSDictionary *type = limits[typeKey];
                        
                        for ( NSString *limitKey in type ) {
                            
                            NSDictionary *limitData = type[limitKey];
                            
                            [resultString appendFormat:@"【%@】\n%@ / %@\n",
                             limitKey,
                             [limitData[@"remaining"] stringValue],
                             [limitData[@"limit"] stringValue]];
                        }
                    }
                    
                    [ShowAlert title:@"API Limit"
                             message:resultString];
                    
                } else {
                    
                    [ShowAlert error:error.description];
                }
                
            } else {
                
                [ShowAlert error:@"API Limit取得エラー"];
            }
            
            [ActivityIndicator off];
        });
    }];
}

- (void)showListView {
    
    NSLog(@"%s", __func__);
    
    ListViewController *modalView = [[ListViewController alloc] initWithListSelectMode:NO];
    [modalView setModalTransitionStyle:UIModalTransitionStyleCoverVertical];
    [self showModalViewController:modalView];
}

- (void)openTwilog:(NSString *)userName {
    
    NSString *URL = [NSString stringWithFormat:@"http://twilog.org/%@", userName];
    [self openBrowser:URL];
}

- (void)openTwilogSearch:(NSString *)userName searchWord:(NSString *)searchWord {
    
    NSString *URL = [CreateSearchURL twilog:userName searchWord:searchWord];
    [self openBrowser:URL];
}

- (void)openFavStar:(NSString *)userName {
    
    NSString *URL = [NSString stringWithFormat:@"http://ja.favstar.fm/users/%@/recent", userName];
    [self openBrowser:URL];
}

- (void)openTwitPic:(NSString *)userName {
    
    NSString *URL = [NSString stringWithFormat:@"http://twitpic.com/photos/%@", userName];
    [self openBrowser:URL];
}

- (void)openBrowser:(NSString *)URL {
    
    NSString *useragent = IPHONE_USERAGENT;
    
    if ( [[D objectForKey:@"UserAgent"] isEqualToString:@"FireFox"] ) {
        
        useragent = FIREFOX_USERAGENT;
        
    }else if ( [[D objectForKey:@"UserAgent"] isEqualToString:@"iPad"] ) {
        
        useragent = IPAD_USERAFENT;
    }
    
    NSDictionary *dictionary = [[NSDictionary alloc] initWithObjectsAndKeys:useragent, @"UserAgent", nil];
    [D registerDefaults:dictionary];
    
    [self setWebBrowserMode:YES];
    
    WebViewExController *dialog = [[WebViewExController alloc] initWithURL:URL];
    [dialog setHidesBottomBarWhenPushed:YES];
    [self.navigationController pushViewController:dialog
                                         animated:YES];
}

#pragma mark - UIPickerView

- (void)showPickerView {
    
    //NSLog(@"showPickerView");
    
    //表示フラグ
    [self setPickerVisible:YES];
    [self.tabBarController.tabBar setUserInteractionEnabled:NO];
    
    self.pickerBase = [[UIView alloc] initWithFrame:CGRectMake(0.0f,
                                                               SCREEN_HEIGHT,
                                                               SCREEN_WIDTH,
                                                               TOOL_BAR_HEIGHT + PICKER_HEIGHT)];
    [self.pickerBase setBackgroundColor:[UIColor clearColor]];
    [self.tabBarController.view addSubview:self.pickerBase];
    
    self.pickerBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0.0f,
                                                                 0.0f,
                                                                 SCREEN_WIDTH,
                                                                 TOOL_BAR_HEIGHT)];
    [self.pickerBar setTintColor:self.topBar.tintColor];
    
    self.pickerBarDoneButton = [[UIBarButtonItem alloc]
                                initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                target:self
                                action:@selector(pickerDone)];
    
    self.pickerBarCancelButton = [[UIBarButtonItem alloc]
                                  initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                  target:self
                                  action:@selector(pickerCancel)];
    
    [self.pickerBar setItems:PICKER_BAR_ITEM
                    animated:NO];
    [self.pickerBase addSubview:self.pickerBar];
    
    self.eventPicker = [[UIPickerView alloc] initWithFrame:CGRectMake(0,
                                                                      TOOL_BAR_HEIGHT,
                                                                      SCREEN_WIDTH,
                                                                      PICKER_HEIGHT)];
    [self.eventPicker setDelegate:self];
    [self.eventPicker setDataSource:self];
    [self.eventPicker setShowsSelectionIndicator:YES];
    [self.pickerBase addSubview:self.eventPicker];
    
    //アカウント初期値
    [self.eventPicker selectRow:[D integerForKey:@"UseAccount"]
                inComponent:0
                   animated:NO];
    
    //イベント初期値
    [self.eventPicker selectRow:1
                inComponent:1
                   animated:NO];
    
    [self.pickerBase setAlpha:0.0f];
    [self.pickerBar setAlpha:0.0f];
    [self.eventPicker setAlpha:0.0f];
    
    //アニメーションさせつつ画面に表示
    [UIView animateWithDuration:0.3f
                     animations:^{
                         
                         [self.pickerBase setFrame:CGRectMake(0.0f,
                                                              STATUS_BAR_HEIGHT + SCREEN_HEIGHT - TAB_BAR_HEIGHT - PICKER_HEIGHT - TOOL_BAR_HEIGHT,
                                                              SCREEN_WIDTH,
                                                              TOOL_BAR_HEIGHT + PICKER_HEIGHT)];
                         
                         [self.pickerBase setAlpha:1.0f];
                         [self.pickerBar setAlpha:1.0f];
                         [self.eventPicker setAlpha:1.0f];
                     }
     ];
}

- (void)pickerDone {
    
    //NSLog(@"pickerDone");
    
    NSInteger account = [self.eventPicker selectedRowInComponent:0];
    NSInteger function = [self.eventPicker selectedRowInComponent:1];
    NSString *tweetID = [[NSString alloc] initWithString:self.selectedTweet.tweetID];
    [self performSelectorInBackground:@selector(hidePicker)
                           withObject:nil];
    
    if ( function == 0 ) {
        
        BOOL favorited = self.selectedTweet.isFavorited;
        
        if ( favorited ) {
            
            [TWEvent unFavorite:tweetID
                   accountIndex:account];
            
        } else {
            
            [self addFavorite:tweetID
                 accountIndex:account];
        }
        
    }else if ( function == 1 ) {
        
        [TWEvent reTweet:tweetID
            accountIndex:account];
        
    }else if ( function == 2 ) {
        
        [TWEvent favoriteReTweet:tweetID
                    accountIndex:account];
    }
    
    [ActivityIndicator on];
}

- (void)pickerCancel {
    
    //NSLog(@"pickerCancel");
    
    [self hidePicker];
}

- (void)hidePicker {
    
    [self setPickerVisible:NO];
    [self.tabBarController.tabBar setUserInteractionEnabled:YES];
    
    //アニメーションさせつつ画面から消す
    [UIView animateWithDuration:0.4f
                     animations:^{
                         
                         [self.pickerBase setFrame:CGRectMake(0.0f,
                                                             SCREEN_HEIGHT,
                                                             SCREEN_WIDTH,
                                                             TOOL_BAR_HEIGHT + PICKER_HEIGHT)];
                         
                         [self.pickerBase setAlpha:0.0f];
                         [self.pickerBar setAlpha:0.0f];
                         [self.eventPicker setAlpha:0.0f];
                     }
     
                     completion:^( BOOL finished ){
                         
                         [self setPickerBarCancelButton:nil];
                         [self setPickerBarDoneButton:nil];
                         
                         while ( self.pickerBase.subviews.count ) {
                             
                             UIView *subView = self.pickerBase.subviews.lastObject;
                             [subView removeFromSuperview];
                             subView = nil;
                         }
                         
                         [self.pickerBase removeFromSuperview];
                         [self setPickerBase:nil];
                     }
     ];
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    
    //列数を返す
    return 2;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    
    //行数を返す
    if ( component == 0 ) {
        
        return [TWAccounts accountCount];
        
    }else{
        
        return 3;
    }
}

- (NSString *)pickerView:(UIPickerView *)pickerView
             titleForRow:(NSInteger)row
            forComponent:(NSInteger)component {
    
    //表示する内容を返す
    NSString * result = BLANK;
    
    if ( component == 0 ) {
        
        result = [TWAccounts selectAccount:row].username;
        
    } else {
        
        result = @[@"Fav／UnFav", @"ReTweet", @"Fav+RT"][row];
    }
    
    return result;
}

#pragma mark - Rotation
- (BOOL)shouldAutorotate {
    
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations {
    
    return UIInterfaceOrientationMaskPortrait;
}

@end
