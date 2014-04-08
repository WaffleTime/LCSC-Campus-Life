//
//  EventDetailTableViewController.h
//  campuslife
//
//  Created by Super Student on 3/4/14.
//  Copyright (c) 2014 LCSC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EventDetailTableViewController : UITableViewController

@property (nonatomic, setter = setDay:) NSInteger day;

@property (copy, nonatomic,setter = setEvent:) NSDictionary *eventDict;

@property (weak, nonatomic) IBOutlet UIButton *updateEvent;

@end
