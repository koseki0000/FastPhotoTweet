//
//  ListViewController.h
//  FastPhotoTweet
//
//  Created by @peace3884 12/09/09.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"

@interface ListViewController : BaseViewController

@property (nonatomic) BOOL listSelectMode;

@property (retain, nonatomic) IBOutlet UINavigationBar *topBar;
@property (retain, nonatomic) IBOutlet UIBarButtonItem *closeButton;
@property (retain, nonatomic) IBOutlet UITableView *listTable;

- (IBAction)pushCloseButton:(id)sender;

- (id)initWithListSelectMode:(BOOL)listSelectMode;

@end
