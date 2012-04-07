//
//  SettingViewController.h
//  FastPhotoTweet
//
//  Created by @peace3884 on 12/02/23.
//

#import <UIKit/UIKit.h>
#import "TableViewCell.h"
#import "TableViewCellController.h"

@interface SettingViewController : UIViewController <UIActionSheetDelegate> {
    
    NSUserDefaults *d;
    NSMutableArray *settingArray;
    
    int actionSheetNo;
    
    TableViewCell *cell;
}

@property (retain, nonatomic) IBOutlet UITableView *tv;
@property (retain, nonatomic) IBOutlet UINavigationBar *bar;
@property (retain, nonatomic) IBOutlet UIBarButtonItem *saveButton;

- (NSString *)getSettingState:(int)index;

- (IBAction)pushDoneButton:(id)sender;

@end
