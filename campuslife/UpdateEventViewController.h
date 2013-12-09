//
//  UpdateEventViewController.h
//  campuslife
//
//  Created by Super Student on 12/8/13.
//  Copyright (c) 2013 LCSC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UpdateEventViewController : UIViewController

//This will be given to us from the previous class (EventDetailViewController)
@property (nonatomic, strong) NSDictionary *eventInfo;


@property (weak, nonatomic) IBOutlet UITextField *summary;
@property (weak, nonatomic) IBOutlet UITextField *where;
@property (weak, nonatomic) IBOutlet UITextView *description;

@property (weak, nonatomic) IBOutlet UILabel *category;

@property (weak, nonatomic) IBOutlet UITextField *month;
@property (weak, nonatomic) IBOutlet UITextField *day;
@property (weak, nonatomic) IBOutlet UITextField *year;

@property (weak, nonatomic) IBOutlet UITextField *fromHour;
@property (weak, nonatomic) IBOutlet UITextField *fromMinute;
@property (weak, nonatomic) IBOutlet UIButton *fromPeriod;


@property (weak, nonatomic) IBOutlet UITextField *toHour;
@property (weak, nonatomic) IBOutlet UITextField *toMinute;
@property (weak, nonatomic) IBOutlet UIButton *toPeriod;

-(IBAction) addEvent;

- (IBAction)categoryStepper:(id)sender;

- (IBAction)periodToggle:(UIButton *)sender;

@end
