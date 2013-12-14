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

@interface AddEventViewController : UIViewController<GoogleOAuthDelegate, UIPickerViewDataSource, UIPickerViewDelegate>

@property (weak, nonatomic) IBOutlet UITextField *summary;
@property (weak, nonatomic) IBOutlet UITextField *where;
@property (weak, nonatomic) IBOutlet UITextView *description;

@property (weak, nonatomic) IBOutlet UISwitch *allDayEventSwitch;

@property (weak, nonatomic) IBOutlet UIDatePicker *startTimePicker;
@property (weak, nonatomic) IBOutlet UIDatePicker *endTimePicker;

@property (weak, nonatomic) IBOutlet UIPickerView *categoryPicker;


@property (weak, nonatomic) IBOutlet UILabel *repeatLabel;
@property (weak, nonatomic) IBOutlet UILabel *numberOfRepeatLabel;

@property (weak, nonatomic) IBOutlet UISlider *repeatSlider;
@property (weak, nonatomic) IBOutlet UISlider *numberOfRepeatSlider;


-(IBAction) addEvent;
- (IBAction)allDayEventToggle:(id)sender;

- (IBAction)repeatSliderChanged:(id)sender;
- (IBAction)numberOfRepeatSliderChanged:(id)sender;



@end
