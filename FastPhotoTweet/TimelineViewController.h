//
//  TimelineViewController.h
//  FastPhotoTweet
//
//  Created by @peace3884 on 12/07/08.
//

#import "TimelineMenu.h"
#import "Share.h"
#import <UIKit/UIKit.h>
#import <QuartzCore/CALayer.h>
#import <Twitter/Twitter.h>
#import <Accounts/Accounts.h>
#import "AppDelegate.h"

#import "TimelineAttributedCell.h"
#import "TimelineAttributedRTCell.h"
#import "NSAttributedString+Attributes.h"

#import "TWTwitterHeader.h"
#import "TWTweets.h"
#import "ListViewController.h"

#import "UtilityClass.h"

#import <MobileCoreServices/MobileCoreServices.h>
#import "ASIHTTPRequest.h"
#import <CFNetwork/CFNetwork.h>

#import "WebViewExController.h"
#import "UIViewSubViewRemover.h"
#import "TitleButton.h"
#import "ActivityGrayView.h"
#import "ImageWindow.h"
#import "SSTextField.h"
#import "NSDictionary+DataExtraction.h"
#import "NSArray+AppendUtil.h"
#import "NSObject+EmptyCheck.h"
#import "NSDictionary+XPath.h"
#import "NSString+RegularExpression.h"
#import "NSString+WordCollect.h"
#import "NSString+Calculator.h"

#import "Three20UI/TTTableHeaderDragRefreshView.h"
#import <Three20UI/TTActivityLabel.h>
#import <Three20Style/Three20Style.h>
#import <Three20UICommon/Three20UICommon.h>

typedef enum {
    CellTextColorBlack,
    CellTextColorRed,
    CellTextColorBlue,
    CellTextColorGreen,
    CellTextColorGold
}CellTextColor;

typedef enum {
    TimelineMenuActionOpenURL,
    TimelineMenuActionReply,
    TimelineMenuActionFavorite,
    TimelineMenuActionReTweet,
    TimelineMenuActionFavRT,
    TimelineMenuActionSelectID,
    TimelineMenuActionNGTag,
    TimelineMenuActionNGClient,
    TimelineMenuActionInReplyTo,
    TimelineMenuActionCopy,
    TimelineMenuActionDelete,
    TimelineMenuActionEdit,
    TimelineMenuActionUserMenu
}TimelineMenuAction;

@interface TimelineViewController : UIViewController <UIActionSheetDelegate, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource, UITableViewDelegate, UITableViewDataSource>

@property BOOL userStream;
@property BOOL userStreamFirstResponse;
@property BOOL webBrowserMode;
@property BOOL otherTweetsMode;
@property BOOL viewWillAppear;
@property BOOL alertSearchType;
@property BOOL listMode;
@property BOOL pickerVisible;
@property BOOL searchStream;
@property BOOL isLoading;
@property BOOL iconWorking;
@property BOOL firstLoad;
@property BOOL showMenu;

@property int selectRow;
@property int longPressControl;

@property (strong, nonatomic) TimelineMenu *timelineMenu;
@property (strong, nonatomic) ActivityGrayView *grayView;
@property (strong, nonatomic) NSMutableArray *timelineArray;
@property (strong, nonatomic) NSMutableArray *inReplyTo;
@property (strong, nonatomic) NSMutableArray *currentList;
@property (strong, nonatomic) NSMutableArray *searchStreamTemp;
@property (strong, nonatomic) NSMutableDictionary *allLists;
@property (strong, nonatomic) NSMutableSet *requestedUser;
@property (strong, nonatomic) NSArray *mentionsArray;
@property (strong, nonatomic) NSArray *selectTweetIds;
@property (strong, nonatomic) NSArray *tweetInUrls;
@property (strong, nonatomic) NSDictionary *selectTweet;

@property (copy, nonatomic) NSString *lastUpdateAccount;
@property (copy, nonatomic) NSString *selectAccount;
@property (copy, nonatomic) NSString *alertSearchUserName;
@property (strong, nonatomic) NSTimer *searchStreamTimer;
@property (strong, nonatomic) NSTimer *connectionCheckTimer;
@property (strong, nonatomic) NSTimer *onlineCheckTimer;
@property (strong, nonatomic) NSURLConnection *connection;
@property (strong, nonatomic) UIImage *startImage;
@property (strong, nonatomic) UIImage *stopImage;
@property (strong, nonatomic) UIImage *listImage;

@property (strong, nonatomic) UIAlertView *alertSearch;
@property (strong, nonatomic) SSTextField *alertSearchText;
@property (strong, nonatomic) UIView *pickerBase;
@property (strong, nonatomic) UIToolbar *pickerBar;
@property (strong, nonatomic) UIPickerView *eventPicker;
@property (strong, nonatomic) UIBarButtonItem *pickerBarDoneButton;
@property (strong, nonatomic) UIBarButtonItem *pickerBarCancelButton;
@property (strong, nonatomic) TTTableHeaderDragRefreshView *headerView;
@property (strong, nonatomic) UIView *activityTable;

@property (strong, nonatomic) ImageWindow *imageWindow;

@property (strong, nonatomic) IBOutlet UIToolbar *topBar;
@property (strong, nonatomic) IBOutlet UITableView *timeline;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *flexibleSpace;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *fixedSpace;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *postButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *reloadButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *timelineControlButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *actionButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *closeOtherTweetsButton;
@property (strong, nonatomic) IBOutlet UIImageView *accountIconView;
@property (strong, nonatomic) IBOutlet UISegmentedControl *timelineSegment;

- (IBAction)pushPostButton:(UIBarButtonItem *)sender;
- (IBAction)pushReloadButton:(UIBarButtonItem *)sender;
- (IBAction)pushTimelineControlButton:(UIBarButtonItem *)sender;
- (IBAction)pushActionButton:(UIBarButtonItem *)sender;
- (IBAction)pushCloseOtherTweetsButton:(UIBarButtonItem *)sender;

- (IBAction)swipeTimelineRight:(UISwipeGestureRecognizer *)sender;
- (IBAction)swipeTimelineLeft:(UISwipeGestureRecognizer *)sender;
- (IBAction)longPressTimeline:(UILongPressGestureRecognizer *)sender;

- (IBAction)changeSegment:(UISegmentedControl *)sender;

- (void)setDefault;
- (void)setNotifications;
- (void)setTimelineHeight;
- (void)createPullDownRefreshHeader;
- (void)startLoad;
- (void)finishLoad;

- (void)createTimeline;
- (void)loadTimeline:(NSNotification *)center;
- (void)loadMentions:(NSNotification *)center;
- (void)loadFavorites:(NSNotification *)center;
- (void)getIconWithTweetArray:(NSMutableArray *)tweetArray;
- (void)requestProfileImageWithURL:(NSString *)biggerUrl screenName:(NSString *)screenName searchName:(NSString *)searchName;
- (void)changeAccount:(NSNotification *)notification;
- (void)getInReplyToChain:(NSDictionary *)tweetData;
- (void)scrollTimelineForNewTweet:(NSString *)tweetID;
- (void)scrollTimelineToTop:(BOOL)animation;
- (void)scrollTimelineToBottom:(BOOL)animation;
- (void)refreshTimelineCell:(NSNumber *)index;
- (void)copyTweetInUrl:(NSArray *)urlList;
- (void)checkTimelineCount:(BOOL)animated;
- (void)pushIcon:(UIButton *)sender;
- (void)openTimelineURL:(NSNotification *)notification;
- (void)openTimelineImage:(NSNotification *)notification;
- (void)receiveGrayViewDoneNotification:(NSNotification *)notification;
- (UIColor *)getTextColor:(CellTextColor)color;

- (void)openStream;
- (void)closeStream;
- (void)userStreamDelete:(NSDictionary *)receiveData;
- (void)userStreamMyAddFavEvent:(NSDictionary *)receiveData;
- (void)userStreamMyRemoveFavEvent:(NSDictionary *)receiveData;
- (void)userStreamReceiveFavEvent:(NSDictionary *)receiveData;
- (void)userStreamReceiveTweet:(NSDictionary *)receiveData newTweet:(NSArray *)newTweet;
- (void)openSearchStream:(NSString *)searchWord;
- (void)closeSearchStream;
- (void)searchStreamReceiveTweet:(NSDictionary *)receiveData;
- (void)startSearchStreamTimer;
- (void)stopSearchStreamTimer;
- (void)checkSearchStreamTemp;

- (void)showTwitterAccountSelectActionSheet:(NSArray *)ids;
- (void)openTwitterService:(NSString *)username serviceType:(int)serviceType;

- (void)timelineMenuActionOpenURL;
- (void)timelineMenuActionReply;
- (void)timelineMenuActionFavorite;
- (void)timelineMenuActionReTweet;
- (void)timelineMenuActionFavRT;
- (void)timelineMenuActionSelectID;
- (void)timelineMenuActionNGTag;
- (void)timelineMenuActionNGClient;
- (void)timelineMenuActionInReplyTo;
- (void)timelineMenuActionCopy;
- (void)timelineMenuActionDelete;
- (void)timelineMenuActionEdit;
- (void)timelineMenuActionUserMenu;

- (void)receiveProfile:(NSNotification *)notification;
- (void)enterBackground:(NSNotification *)notification;
- (void)becomeActive:(NSNotification *)notification;

- (void)timelineMenuAction:(NSNotification *)notification;
- (void)hideTimelineMenu:(NSNotification *)notification;

- (void)getMyAccountIcon;
- (void)setMyAccountIconCorner;
- (void)timelineDidListChanged;
- (void)showListSelectView;
- (void)setTimelineBarItems;
- (void)setOtherTweetsBarItems;

- (void)showPickerView;
- (void)pickerDone;
- (void)pickerCancel;
- (void)hidePicker;

- (void)startConnectionCheckTimer;
- (void)stopConnectionCheckTimer;
- (void)checkConnection;

- (void)startOnlineCheckTimer;
- (void)stopOnlineCheckTimer;
- (void)checkOnline;

@end