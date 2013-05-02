//
//  SettingViewController.h
//  FastPhotoTweet
//
//  Created by @peace3884 on 12/02/23.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "TableViewCell.h"
#import "TableViewCellController.h"
#import "EmptyCheck.h"
#import "OAuthSetupViewController.h"
#import "IDChangeViewController.h"
#import "LicenseViewController.h"
#import "SpecialThanksViewController.h"
#import "NGSettingViewController.h"
#import "AppDelegate.h"
#import "UIViewSubViewRemover.h"
#import "TWAccounts.h"

@interface SettingViewController : BaseViewController <UIActionSheetDelegate, UITextFieldDelegate> {
    
    AppDelegate *appDelegate;
    GrayView *grayView;
    
    NSUserDefaults *d;
    NSMutableArray *settingArray;
    
    UIAlertView *alert;
    UITextField *alertText;
    
    int actionSheetNo;
    int alertTextNo;
}

@property (retain, nonatomic) IBOutlet UITableView *tv;
@property (nonatomic) BOOL listSelectMode;

- (NSString *)getSettingState:(int)settingState;

@end
