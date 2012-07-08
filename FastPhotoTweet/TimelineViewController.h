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

@interface TimelineViewController : UIViewController {
    
    AppDelegate *appDelegate;
    
    NSUserDefaults *d;
    NSMutableArray *timelineArray;
    NSMutableArray *iconUrls;
    NSMutableDictionary *icons;
    NSDictionary *currentTweet;
    
    UIPasteboard *pboard;
    UIImage *startImage;
    UIImage *stopImage;
    
    ACAccount *twAccount;
    
    BOOL userStream;
}

@property (retain, nonatomic) IBOutlet UIToolbar *topBar;
@property (retain, nonatomic) IBOutlet UITableView *timeline;
@property (retain, nonatomic) IBOutlet UIBarButtonItem *flexibleSpace;
@property (retain, nonatomic) IBOutlet UIBarButtonItem *postButton;
@property (retain, nonatomic) IBOutlet UIBarButtonItem *openStreamButton;
@property (strong, nonatomic) NSURLConnection *connection;

- (IBAction)pushPostButton:(id)sender;
- (IBAction)pushOpenStreamButton:(id)sender;

- (void)createTimeline;
- (void)loadTimeline:(NSNotification *)center;
- (void)saveIcon:(NSMutableArray *)tweetData;

@end
