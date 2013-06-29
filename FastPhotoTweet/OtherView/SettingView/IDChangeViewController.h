//
//  SettingViewController.h
//  FastPhotoTweet
//
//  Created by @peace3884 on 12/02/23.
//

#import <UIKit/UIKit.h>
#import <Accounts/Accounts.h>
#import "ShowAlert.h"
#import "AppDelegate.h"
#import "BaseViewController.h"

@interface IDChangeViewController : BaseViewController {
    
    AppDelegate *appDelegate;
    
    NSUserDefaults *d;
    NSMutableArray *accountList;
    NSString *screenName;
    
    BOOL twitpicLinkMode;
}

@property (retain, nonatomic) IBOutlet UIScrollView *sv;
@property (retain, nonatomic) IBOutlet UINavigationItem *topBar;
@property (retain, nonatomic) IBOutlet UIBarButtonItem *closeButton;
@property (retain, nonatomic) IBOutlet UITableView *tv;

- (IBAction)pushCloseButton:(id)sender;

@end
