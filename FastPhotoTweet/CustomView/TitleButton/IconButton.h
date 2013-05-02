//
//  IconButton.h
//  FastPhotoTweet
//
//  Created by peace3884 on 12/10/18.
//
//

#import <UIKit/UIButton.h>
#import "TWTweet.h"

@interface IconButton : UIButton

@property (assign, nonatomic) TWTweet *targetTweet;

@end
