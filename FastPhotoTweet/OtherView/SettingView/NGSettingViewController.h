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
#import "SSTextField.h"
#import "NSString+WordCollect.h"

@interface NGSettingViewController : UIViewController <UITextFieldDelegate, UINavigationBarDelegate> {
    
    NSUserDefaults *d;
    
    NSMutableArray *ngSettingArray;
}

@property (weak, nonatomic) IBOutlet UIScrollView *sv;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *addButton;
@property (weak, nonatomic) IBOutlet UISegmentedControl *ngTypeSegment;
@property (weak, nonatomic) IBOutlet SSTextField *ngWordField;
@property (weak, nonatomic) IBOutlet SSTextField *userField;
@property (weak, nonatomic) IBOutlet SSTextField *exclusionUserField;
@property (weak, nonatomic) IBOutlet UILabel *regexpLabel;
@property (weak, nonatomic) IBOutlet UISwitch *regexpSwitch;
@property (weak, nonatomic) IBOutlet UITableView *addedNgSettings;

- (IBAction)doneButtonVisible:(UITextField *)sender;
- (IBAction)changeSegment:(UISegmentedControl *)sender;
- (IBAction)pushAddButton:(UIBarButtonItem *)sender;

- (CGFloat)heightForContents:(NSString *)contents;

@end
