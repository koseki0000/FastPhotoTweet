//
//  TimelineCellController.h
//  FastPhotoTweet
//
//  Created by @peace3884 on 12/07/08.
//

#import <UIKit/UIKit.h>
#import "TimelineCell.h"

@interface TimelineCellController : UIViewController {
    
	IBOutlet TimelineCell *cell;
}

@property (nonatomic, retain) TimelineCell *cell;

@end