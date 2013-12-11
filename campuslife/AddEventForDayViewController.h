//
//  AddEventForDayViewController.h
//  campuslife
//
//  Created by Super Student on 12/2/13.
//  Copyright (c) 2013 LCSC. All rights reserved.
//

//This class is for the AddEvent page that is connected to the Calendar page!

#import <UIKit/UIKit.h>
#import "GoogleOAuth.h"

@interface AddEventForDayViewController : UIViewController<GoogleOAuthDelegate, UIPickerViewDataSource, UIPickerViewDelegate>

@property (weak, nonatomic) IBOutlet UITextField *summary;
@property (weak, nonatomic) IBOutlet UITextField *where;
@property (weak, nonatomic) IBOutlet UITextView *description;

@property (weak, nonatomic) IBOutlet UISwitch *allDayEventSwitch;

@property (weak, nonatomic) IBOutlet UIDatePicker *startTimePicker;
@property (weak, nonatomic) IBOutlet UIDatePicker *endTimePicker;

@property (weak, nonatomic) IBOutlet UIPickerView *categoryPicker;

-(IBAction) addEvent;

@end
