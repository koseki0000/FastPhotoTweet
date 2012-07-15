//
//  TimelineViewController.h
//  FastPhotoTweet
//
//  Created by @peace3884 on 12/07/08.
//

#import <UIKit/UIKit.h>
#import "QuartzCore/CALayer.h"
#import <Twitter/Twitter.h>
#import <Accounts/Accounts.h>
#import "AppDelegate.h"
#import "TimelineCellController.h"
#import "TWTwitterHeader.h"
#import "UtilityClass.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"
#import <CFNetwork/CFNetwork.h>
#import "JSON.h"
#import "Reachability.h"
#import "WebViewExController.h"

@interface TimelineViewController : UIViewController <UIActionSheetDelegate, UITextFieldDelegate> {
    
    AppDelegate *appDelegate;
    
    NSUserDefaults *d;
    NSMutableArray *timelineArray;
    NSMutableArray *iconUrls;
    NSMutableArray *inReplyTo;
    NSMutableDictionary *allTimelines;
    NSMutableDictionary *sinceIds;
    NSMutableDictionary *icons;
    NSArray *mentionsArray;
    NSDictionary *currentTweet;
    NSDictionary *selectTweet;
    NSString *userStreamAccount;
    NSString *lastUpdateAccount;
    NSString *timelineTopTweetId;
    
    UIPasteboard *pboard;
    UIImage *startImage;
    UIImage *stopImage;
    UIImage *defaultActionButtonImage;
    UIAlertView *twilogSearch;
    UITextField *twilogSearchText;
    
    ACAccount *twAccount;
    
    BOOL userStream;
    BOOL openStreamAfter;
    BOOL webBrowserMode;
    BOOL inReplyToMode;
    BOOL inReplyToModeFirts;
    
    int selectRow;
    int longPressControl;
}

@property (retain, nonatomic) IBOutlet UIToolbar *topBar;
@property (retain, nonatomic) IBOutlet UITableView *timeline;
@property (retain, nonatomic) IBOutlet UIBarButtonItem *flexibleSpace;
@property (retain, nonatomic) IBOutlet UIBarButtonItem *fixedSpace;
@property (retain, nonatomic) IBOutlet UIBarButtonItem *postButton;
@property (retain, nonatomic) IBOutlet UIBarButtonItem *reloadButton;
@property (retain, nonatomic) IBOutlet UIBarButtonItem *openStreamButton;
@property (retain, nonatomic) IBOutlet UIBarButtonItem *actionButton;
@property (retain, nonatomic) IBOutlet UIBarButtonItem *closeInReplyToButton;
@property (retain, nonatomic) IBOutlet UIImageView *accountIconView;
@property (retain, nonatomic) IBOutlet UISegmentedControl *timelineSegment;
@property (strong, nonatomic) NSURLConnection *connection;

- (IBAction)pushPostButton:(UIBarButtonItem *)sender;
- (IBAction)pushReloadButton:(UIBarButtonItem *)sender;
- (IBAction)pushOpenStreamButton:(UIBarButtonItem *)sender;
- (IBAction)pushActionButton:(UIBarButtonItem *)sender;
- (IBAction)pushCloseInReplyToButton:(UIBarButtonItem *)sender;

- (IBAction)swipeTimelineRight:(UISwipeGestureRecognizer *)sender;
- (IBAction)swipeTimelineLeft:(UISwipeGestureRecognizer *)sender;
- (IBAction)longPressTimeline:(UILongPressGestureRecognizer *)sender;

- (IBAction)changeSegment:(UISegmentedControl *)sender;

- (void)setNotifications;
- (void)createTimeline;
- (void)loadTimeline:(NSNotification *)center;
- (void)loadMentions:(NSNotification *)center;
- (void)loadFavorites:(NSNotification *)center;
- (void)getIconUrlWithTimeline;
- (void)saveIcon:(NSMutableArray *)tweetData;
- (void)getInReplyToChain:(NSDictionary *)tweetData;
- (void)scrollTimelineForNewTweet;
- (void)openStream;
- (void)closeStream;

- (BOOL)reachability;

- (void)receiveProfile:(NSNotification *)notification;
- (void)enterBackground:(NSNotification *)notification;
- (void)becomeActive:(NSNotification *)notification;

- (void)getMyAccountIcon;

@end
