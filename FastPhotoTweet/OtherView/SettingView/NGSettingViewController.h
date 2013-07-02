//
//  NGSettingViewController.h
//  FastPhotoTweet
//
//  Created by @peace3884 on 12/07/15.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "EmptyCheck.h"
#import "ShowAlert.h"
#import "SwipeShiftTextField.h"
#import "NSString+WordCollect.h"

@interface NGSettingViewController : UIViewController <UITextFieldDelegate, UINavigationBarDelegate> {
    
    NSUserDefaults *d;
    
    NSMutableArray *ngSettingArray;
}

@property (weak, nonatomic) IBOutlet UIScrollView *sv;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *addButton;
@property (weak, nonatomic) IBOutlet UISegmentedControl *ngTypeSegment;
@property (weak, nonatomic) IBOutlet SwipeShiftTextField *ngWordField;
@property (weak, nonatomic) IBOutlet SwipeShiftTextField *userField;
@property (weak, nonatomic) IBOutlet SwipeShiftTextField *exclusionUserField;
@property (weak, nonatomic) IBOutlet UILabel *regexpLabel;
@property (weak, nonatomic) IBOutlet UISwitch *regexpSwitch;
@property (weak, nonatomic) IBOutlet UITableView *addedNgSettings;
@property (weak, nonatomic) IBOutlet UILabel *reTweetText;
@property (weak, nonatomic) IBOutlet UISwitch *reTweetSwitch;

- (IBAction)doneButtonVisible:(UITextField *)sender;
- (IBAction)changeSegment:(UISegmentedControl *)sender;
- (IBAction)pushAddButton:(UIBarButtonItem *)sender;

- (CGFloat)heightForContents:(NSString *)contents;

@end
