//
//  TimelineCell.h
//  FastPhotoTweet
//
//  Created by @peace3884 on 11/07/16.
//

#import <UIKit/UIKit.h>

@interface TableViewCell : UITableViewCell {
    
	IBOutlet UILabel *numberLabel;
	IBOutlet UILabel *textLabel;
}

@property (nonatomic, retain) UILabel *numberLabel;
@property (nonatomic, retain) UILabel *textLabel;

@end
