//
//  ResendCell.h
//  FastPhotoTweet
//
//  Created by Yuki Higurashi on 12/04/28.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ResendCell : UITableViewCell {
    
    IBOutlet UIImageView *imageView;
	IBOutlet UILabel *textLabel;
}

@property (retain, nonatomic) IBOutlet UIImageView *imageView;
@property (retain, nonatomic) IBOutlet UILabel *textLabel;

@end
