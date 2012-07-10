//
//  TimelineCell.h
//  FastPhotoTweet
//
//  Created by @peace3884 on 12/07/08.
//

#import <UIKit/UIKit.h>

@interface TimelineCell : UITableViewCell {
    
	IBOutlet UILabel *infoLabel;
	IBOutlet UILabel *textLabel;
}

@property (retain, nonatomic) UILabel *infoLabel;
@property (retain, nonatomic) UILabel *textLabel;
@property (retain, nonatomic) IBOutlet UIImageView *iconView;

@end