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

@interface TimelineViewController : UIViewController <UIActionSheetDelegate> {
    
    AppDelegate *appDelegate;
    
    NSUserDefaults *d;
    NSMutableArray *timelineArray;
    NSMutableArray *iconUrls;
    NSMutableDictionary *allTimelines;
    NSMutableDictionary *icons;
    NSDictionary *currentTweet;
    NSString *userStreamUser;
    
    UIPasteboard *pboard;
    UIImage *startImage;
    UIImage *stopImage;
    
    ACAccount *twAccount;
    
    BOOL userStream;
    BOOL actionSheetVisible;
    
    int longPressControl;
    int selectRow;
}

@property (retain, nonatomic) IBOutlet UIToolbar *topBar;
@property (retain, nonatomic) IBOutlet UITableView *timeline;
@property (retain, nonatomic) IBOutlet UIBarButtonItem *flexibleSpace;
@property (retain, nonatomic) IBOutlet UIBarButtonItem *postButton;
@property (retain, nonatomic) IBOutlet UIBarButtonItem *reloadButton;
@property (retain, nonatomic) IBOutlet UIBarButtonItem *openStreamButton;
@property (retain, nonatomic) IBOutlet UIBarButtonItem *actionButton;
@property (strong, nonatomic) NSURLConnection *connection;

- (IBAction)pushPostButton:(UIBarButtonItem *)sender;
- (IBAction)pushReloadButton:(UIBarButtonItem *)sender;
- (IBAction)pushOpenStreamButton:(UIBarButtonItem *)sender;
- (IBAction)pushActionButton:(UIBarButtonItem *)sender;

- (void)createTimeline;
- (void)loadTimeline:(NSNotification *)center;
- (void)saveIcon:(NSMutableArray *)tweetData;

@end
