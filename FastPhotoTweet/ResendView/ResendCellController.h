//
//  ResendCellController.h
//  FastPhotoTweet
//
//  Created by Yuki Higurashi on 12/04/28.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ResendCell.h"

@interface ResendCellController : UIViewController {
    
    IBOutlet ResendCell *cell;
}

@property (nonatomic, retain) ResendCell *cell;

@end
