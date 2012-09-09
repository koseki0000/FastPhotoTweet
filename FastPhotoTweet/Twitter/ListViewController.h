//
//  ListViewController.h
//  FastPhotoTweet
//
//  Created by @peace3884 12/09/09.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "TWList.h"

@interface ListViewController : UIViewController {
    
    AppDelegate *appDelegate;
    
    NSArray *listAll;
}

@property (retain, nonatomic) IBOutlet UINavigationBar *topBar;
@property (retain, nonatomic) IBOutlet UIBarButtonItem *closeButton;
@property (retain, nonatomic) IBOutlet UITableView *listTable;

- (IBAction)pushCloseButton:(id)sender;

@end
