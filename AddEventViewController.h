//
//  AddEventViewController.h
//  campuslife
//
//  Created by Super Student on 12/2/13.
//  Copyright (c) 2013 LCSC. All rights reserved.
//

//This class is for the AddEvent page that is connected to the Calendar page!

#import <UIKit/UIKit.h>
#import "GoogleOAuth.h"

@interface AddEventViewController : UIViewController<GoogleOAuthDelegate>

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
