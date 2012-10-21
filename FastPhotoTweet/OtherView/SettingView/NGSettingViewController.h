//
//  NGSettingViewController.h
//  FastPhotoTweet
//
//  Created by @peace3884 on 12/07/15.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "RegularExpression.h"
#import "DeleteWhiteSpace.h"
#import "EmptyCheck.h"
#import "ShowAlert.h"

@interface NGSettingViewController : UIViewController <UITextFieldDelegate, UINavigationBarDelegate> {
    
    NSUserDefaults *d;
    
    NSMutableArray *ngSettingArray;
}

@property (retain, nonatomic) IBOutlet UIScrollView *sv;
@property (retain, nonatomic) IBOutlet UINavigationBar *topBar;
@property (retain, nonatomic) IBOutlet UIBarButtonItem *closeButton;
@property (retain, nonatomic) IBOutlet UIBarButtonItem *addButton;
@property (retain, nonatomic) IBOutlet UISegmentedControl *ngTypeSegment;
@property (retain, nonatomic) IBOutlet UITextField *ngWordField;
@property (retain, nonatomic) IBOutlet UITextField *userField;
@property (retain, nonatomic) IBOutlet UITextField *exclusionUserField;
@property (retain, nonatomic) IBOutlet UILabel *regexpLabel;
@property (retain, nonatomic) IBOutlet UISwitch *regexpSwitch;
@property (retain, nonatomic) IBOutlet UITableView *addedNgSettings;

- (IBAction)doneButtonVisible:(UITextField *)sender;

- (IBAction)changeSegment:(UISegmentedControl *)sender;

- (IBAction)pushAddButton:(UIBarButtonItem *)sender;
- (IBAction)pushCloseButton:(UIBarButtonItem *)sender;

- (IBAction)upView:(id)sender;

- (CGFloat)heightForContents:(NSString *)contents;

@end
