//
//  HistoryTableViewCell.h
//  MedsAI
//
//  Created by Vlad on 18/03/2018.
//  Copyright © 2018 Mountain Viewer. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HistoryTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *image;
@property (weak, nonatomic) IBOutlet UILabel *title;
@property (weak, nonatomic) IBOutlet UILabel* manuf;

@end
