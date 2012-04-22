//
//  SettingViewController.h
//  FastPhotoTweet
//
//  Created by @peace3884 on 12/02/23.
//

#import <UIKit/UIKit.h>
#import <Accounts/Accounts.h>
#import "TableViewCell.h"
#import "TableViewCellController.h"
#import "ShowAlert.h"

@interface IDChangeViewController : UIViewController {
    
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
