//
//  TimelineViewController.h
//  FastPhotoTweet
//
//  Created by @peace3884 on 12/07/08.
//

#import <CoreFoundation/CoreFoundation.h>
#import <UIKit/UIKit.h>
#import <QuartzCore/CALayer.h>
#import <Twitter/Twitter.h>
#import <Accounts/Accounts.h>
#import "AppDelegate.h"

#import "TimelineAttributedCell.h"
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

#import "Three20UI/TTTableHeaderDragRefreshView.h"
#import <Three20UI/TTActivityLabel.h>
#import <Three20Style/Three20Style.h>
#import <Three20UICommon/Three20UICommon.h>

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

@property int selectRow;
@property int longPressControl;

@property (retain, nonatomic) ActivityGrayView *grayView;
@property (retain, nonatomic) NSMutableArray *timelineArray;
@property (retain, nonatomic) NSMutableArray *inReplyTo;
@property (retain, nonatomic) NSMutableArray *reqedUser;
@property (retain, nonatomic) NSMutableArray *iconUrls;
@property (retain, nonatomic) NSMutableArray *currentList;
@property (retain, nonatomic) NSMutableArray *searchStreamTemp;
@property CFMutableDictionaryRef icons;
//@property (retain, nonatomic) NSMutableDictionary *icons;
@property (retain, nonatomic) NSMutableDictionary *allLists;
@property (retain, nonatomic) NSArray *mentionsArray;
@property (retain, nonatomic) NSArray *selectTweetIds;
@property (retain, nonatomic) NSArray *tweetInUrls;
@property (retain, nonatomic) NSDictionary *currentTweet;
@property (retain, nonatomic) NSDictionary *selectTweet;
@property (retain, nonatomic) NSString *lastUpdateAccount;
@property (retain, nonatomic) NSString *selectAccount;
@property (retain, nonatomic) NSString *alertSearchUserName;
@property (retain, nonatomic) NSTimer *searchStreamTimer;
@property (retain, nonatomic) NSTimer *connectionCheckTimer;
@property (retain, nonatomic) NSTimer *onlineCheckTimer;
@property (strong, nonatomic) NSURLConnection *connection;
@property (retain, nonatomic) UIImage *startImage;
@property (retain, nonatomic) UIImage *stopImage;
@property (retain, nonatomic) UIImage *listImage;

@property (retain, nonatomic) UIAlertView *alertSearch;
@property (retain, nonatomic) SSTextField *alertSearchText;
@property (retain, nonatomic) UIView *pickerBase;
@property (retain, nonatomic) UIToolbar *pickerBar;
@property (retain, nonatomic) UIPickerView *eventPicker;
@property (retain, nonatomic) UIBarButtonItem *pickerBarDoneButton;
@property (retain, nonatomic) UIBarButtonItem *pickerBarCancelButton;
@property (retain, nonatomic) TTTableHeaderDragRefreshView *headerView;
@property (retain, nonatomic) UIView *activityTable;

@property (retain, nonatomic) ImageWindow *imageWindow;

@property (retain, nonatomic) IBOutlet UIToolbar *topBar;
@property (retain, nonatomic) IBOutlet UITableView *timeline;
@property (retain, nonatomic) IBOutlet UIBarButtonItem *flexibleSpace;
@property (retain, nonatomic) IBOutlet UIBarButtonItem *fixedSpace;
@property (retain, nonatomic) IBOutlet UIBarButtonItem *postButton;
@property (retain, nonatomic) IBOutlet UIBarButtonItem *reloadButton;
@property (retain, nonatomic) IBOutlet UIBarButtonItem *timelineControlButton;
@property (retain, nonatomic) IBOutlet UIBarButtonItem *actionButton;
@property (retain, nonatomic) IBOutlet UIBarButtonItem *closeOtherTweetsButton;
@property (retain, nonatomic) IBOutlet UIImageView *accountIconView;
@property (retain, nonatomic) IBOutlet UISegmentedControl *timelineSegment;

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
- (void)getIconWithSequential;
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
- (UIColor *)getTextColor:(int)color;

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

- (void)receiveProfile:(NSNotification *)notification;
- (void)enterBackground:(NSNotification *)notification;
- (void)becomeActive:(NSNotification *)notification;

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

typedef enum {
    CellTextColorBlack,
    CellTextColorRed,
    CellTextColorBlue,
    CellTextColorGreen,
    CellTextColorGold
}CellTextColor;


