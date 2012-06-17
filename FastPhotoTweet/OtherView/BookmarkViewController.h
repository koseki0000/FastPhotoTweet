//
//  BookmarkViewController.h
//  FastPhotoTweet
//
//  Created by @peace3884 on 12/06/02.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "EmptyCheck.h"
#import "RegularExpression.h"

@interface BookmarkViewController : UIViewController <UIActionSheetDelegate> {
    
    AppDelegate * appDelegate;
    
    NSUserDefaults *d;
    NSMutableArray *bookMarkArray;
    
    int actionSheetNo;
    int selectRow;
}

@property (retain, nonatomic) IBOutlet UINavigationBar *topBar;
@property (retain, nonatomic) IBOutlet UIBarButtonItem *closeButton;
@property (retain, nonatomic) IBOutlet UITableView *tv;

- (IBAction)pushCloseButton:(id)sender;

@end
