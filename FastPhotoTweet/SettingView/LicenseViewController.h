//
//  LicenseViewController.h
//  FastPhotoTweet
//
//  Created by @peace3884 on 12/04/30.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

@interface LicenseViewController : UIViewController

@property (retain, nonatomic) IBOutlet UINavigationBar *bar;
@property (retain, nonatomic) IBOutlet UIBarButtonItem *closeButton;
@property (retain, nonatomic) IBOutlet UITextView *textView;

- (IBAction)pushCloseButton:(id)sender;

@end
