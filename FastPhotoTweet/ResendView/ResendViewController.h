//
//  ResendViewController.h
//  FastPhotoTweet
//
//  Created by Yuki Higurashi on 12/04/28.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

@interface ResendViewController : UIViewController {
    
    AppDelegate * appDelegate;
}

@property (retain, nonatomic) IBOutlet UITableView *resendTable;
@property (retain, nonatomic) IBOutlet UINavigationBar *bar;
@property (retain, nonatomic) IBOutlet UIBarButtonItem *closeButton;
@property (retain, nonatomic) IBOutlet UIBarButtonItem *trashButton;

- (IBAction)pushTrashButton:(id)sender;
- (IBAction)pushCloseButon:(id)sender;

@end
