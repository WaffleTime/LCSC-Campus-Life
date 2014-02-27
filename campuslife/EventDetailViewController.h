//
//  EventDetailViewController.h
//  LCSC Campus Life
//
//  Created by Super Student on 11/12/13.
//  Copyright (c) 2013 LCSC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EventDetailViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITextView *descriptionTextView;
@property (weak, nonatomic) IBOutlet UILabel *summaryLabel;
@property (weak, nonatomic) IBOutlet UILabel *locLabel;
@property (weak, nonatomic) IBOutlet UILabel *categoryLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;

@property (weak, nonatomic) IBOutlet UILabel *repeatLabel;

@property (weak, nonatomic) IBOutlet UILabel *allDayLabel;

@property (weak, nonatomic) IBOutlet UILabel *fromTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *toTimeLabel;

@property (weak, nonatomic) IBOutlet UIButton *addEventButton;

@property (copy, nonatomic,setter = setEvent:) NSDictionary *eventDict;

- (int)getIndexOfSubstringInString:(NSString *)substring :(NSString *)string;

@end
