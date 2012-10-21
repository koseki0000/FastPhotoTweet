//
//  TimelineCellController.h
//  FastPhotoTweet
//
//  Created by @peace3884 on 11/07/16.
//

#import <UIKit/UIKit.h>
#import "TableViewCell.h"

@interface TableViewCellController : UIViewController {
    
	IBOutlet TableViewCell *cell;
}

@property (nonatomic, retain) TableViewCell *cell;

@end
