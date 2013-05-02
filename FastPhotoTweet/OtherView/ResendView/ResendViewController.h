//
//  ResendViewController.h
//  FastPhotoTweet
//
//  Created by @peace3884 on 12/04/28.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "BaseViewController.h"

@interface ResendViewController : BaseViewController

@property (retain, nonatomic) IBOutlet UITableView *resendTable;
@property (retain, nonatomic) IBOutlet UINavigationBar *bar;
@property (retain, nonatomic) IBOutlet UIBarButtonItem *closeButton;
@property (retain, nonatomic) IBOutlet UIBarButtonItem *trashButton;

- (IBAction)pushTrashButton:(id)sender;
- (IBAction)pushCloseButon:(id)sender;

@end
