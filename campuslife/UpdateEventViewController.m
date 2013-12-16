//
//  UpdateEventViewController.m
//  campuslife
//
//  Created by Super Student on 12/8/13.
//  Copyright (c) 2013 LCSC. All rights reserved.
//

#import "UpdateEventViewController.h"
#import "Authentication.h"
#import "MonthlyEvents.h"

static const CGFloat KEYBOARD_ANIMATION_DURATION = 0.3;
static const CGFloat MINIMUM_SCROLL_FRACTION = 0.2;
static const CGFloat MAXIMUM_SCROLL_FRACTION = 0.8;
static const CGFloat PORTRAIT_KEYBOARD_HEIGHT = 216;
static const CGFloat LANDSCAPE_KEYBOARD_HEIGHT = 162;

@interface UpdateEventViewController () {
    CGFloat animatedDistance;
}

@property (nonatomic) Authentication *auth;

//The stepper button will cycle through the possible categories.
@property (nonatomic, strong) NSArray *categories;

@end

@implementation UpdateEventViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    [[self navigationController] setNavigationBarHidden:NO animated:NO];
    
    UITapGestureRecognizer *tapRec = [[UITapGestureRecognizer alloc]
                                      initWithTarget:self action:@selector(tap:)];
    [self.view addGestureRecognizer: tapRec];
    
    _auth = [Authentication getSharedInstance];
    
    _categories = [[NSArray alloc] initWithObjects:@"Entertainment", @"Academics", @"Activities", @"Residence", @"Athletics", nil];
    
    
    //One of the only differences between this viewController and the one for adding events is that text fields will be populated
    //  with information that was previously for the event.
    
    _summary.text = _eventInfo[@"summary"];
    _where.text = _eventInfo[@"location"];
    _description.text = _eventInfo[@"description"];
    
    for (int i=0; i<[_categories count]; i++) {
        if ([_categories[i] isEqualToString:_eventInfo[@"category"]]) {
            [_categoryPicker selectRow:i inComponent:0 animated:NO];
            
            //NSLog(@"Row Value: %d", i);
        }
    }
    
    //If dateTime exists, then the event isn't an all day event.
    if ([_eventInfo[@"start"] objectForKey:@"dateTime"] != nil) {
        NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
        //[dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
        [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss"];
        NSDate *eventDate = [dateFormatter dateFromString:[_eventInfo[@"start"][@"dateTime"] substringToIndex:19]];
        
        [_startTimePicker setDate:eventDate];
        
        eventDate =[dateFormatter dateFromString:[_eventInfo[@"end"][@"dateTime"] substringToIndex:19]];
        
        [_endTimePicker setDate:eventDate];
    }
    //If dateTime doesn't exist, then it's an all night event.
    else {
        NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
        //[dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
        [dateFormatter setDateFormat:@"yyyy-MM-dd"];
        NSDate *eventDate = [dateFormatter dateFromString:_eventInfo[@"start"][@"date"]];
        
        [_startTimePicker setDate:eventDate animated:NO];
        
        eventDate = [dateFormatter dateFromString:_eventInfo[@"end"][@"date"]];
        
        [_endTimePicker setDate:eventDate animated:NO];
        
        [_allDayEventSwitch setOn:YES];
        
        _startTimePicker.datePickerMode = UIDatePickerModeDate;
        _endTimePicker.datePickerMode = UIDatePickerModeDate;
            
        _repeatLabel.hidden = YES;
        _repeatSlider.hidden = YES;
        
        _numberOfRepeatLabel.hidden = YES;
        _numberOfRepeatSlider.hidden = YES;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(IBAction) addEvent {
    BOOL readyToAddEvent = NO;
    
    //Check if fields are left blank. Notice the description and where fields aren't required.
    if ([_summary.text isEqualToString:@""])
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Blank Field"
                                                        message: @"The Summary field is empty, please fill it in and try again."
                                                       delegate: nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }
    //We will do some other checking on the start and end times to see if they are valid.
    else
    {
        //See if comparing the dates is needed.
        if (_allDayEventSwitch.on)
        {
            NSDateFormatter *yearFormatter = [[NSDateFormatter alloc] init];
            [yearFormatter setDateFormat:@"yyyy"];
            
            //Check if the end year is less than the start year
            if ([[yearFormatter stringFromDate:_endTimePicker.date] intValue]
                < [[yearFormatter stringFromDate:_startTimePicker.date] intValue])
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Invalid Date"
                                                                message: @"The end year is less than the start year."
                                                               delegate: nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
                [alert show];
            }
            else if ([[yearFormatter stringFromDate:_endTimePicker.date] intValue]
                     == [[yearFormatter stringFromDate:_startTimePicker.date] intValue])
            {
                NSDateFormatter *monthFormatter = [[NSDateFormatter alloc] init];
                [monthFormatter setDateFormat:@"MM"];
                //Now we check the months.
                if ([[monthFormatter stringFromDate:_endTimePicker.date] intValue]
                    < [[monthFormatter stringFromDate:_startTimePicker.date] intValue])
                {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Invalid Date"
                                                                    message: @"The end month is less than the start month."
                                                                   delegate: nil
                                                          cancelButtonTitle:@"OK"
                                                          otherButtonTitles:nil];
                    [alert show];
                }
                else if ([[monthFormatter stringFromDate:_endTimePicker.date] intValue]
                         == [[monthFormatter stringFromDate:_startTimePicker.date] intValue])
                {
                    NSDateFormatter *dayFormatter = [[NSDateFormatter alloc] init];
                    [dayFormatter setDateFormat:@"dd"];
                    //Now we check the days.
                    if ([[dayFormatter stringFromDate:_endTimePicker.date] intValue]
                        < [[dayFormatter stringFromDate:_startTimePicker.date] intValue])
                    {
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Invalid Date"
                                                                        message: @"The end day is less than the start day."
                                                                       delegate: nil
                                                              cancelButtonTitle:@"OK"
                                                              otherButtonTitles:nil];
                        [alert show];
                    }
                    else
                    {
                        //If all the previous checks are alright, then we can add an event.
                        readyToAddEvent = YES;
                    }
                }
                else {
                    readyToAddEvent = YES;
                }
            }
            else {
                readyToAddEvent = YES;
            }
        }
        //So we only must compare the times.
        else
        {
            NSDateFormatter *timeFormatter = [[NSDateFormatter alloc] init];
            [timeFormatter setDateFormat:@"HHmm"];
            //Now we check the times.
            if ([[timeFormatter stringFromDate:_endTimePicker.date] intValue]
                < [[timeFormatter stringFromDate:_startTimePicker.date] intValue])
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Invalid Time"
                                                                message: @"The end time is less than the start time."
                                                               delegate: nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
                [alert show];
            }
            else
            {
                //If all the previous checks are alright, then we can add an event.
                readyToAddEvent = YES;
            }
        }
    }

    if (readyToAddEvent) {
        [[_auth getAuthenticator] callAPI:[NSString stringWithFormat:@"https://www.googleapis.com/calendar/v3/calendars/lcmail.lcsc.edu_09hhfhm9kcn5h9dhu83ogsd0u8@group.calendar.google.com/events/%@", _eventInfo[@"id"]]
                           withHttpMethod:httpMethod_DELETE
                       postParameterNames:[NSArray arrayWithObjects: nil]
                      postParameterValues:[NSArray arrayWithObjects: nil]];
        
        //Events have specified time constraints unless they are all day events.
        if (!_allDayEventSwitch.on) {
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"MM/dd/yyyy HH:mm"];
            
            NSDateFormatter *timeFormatter = [[NSDateFormatter alloc] init];
            [timeFormatter setDateFormat:@"HH:mm"];

            NSString *quickAddText = @"";

            //No Repeat
            if ((int)(roundf(_repeatSlider.value*100.0)/100.0) == 0) {
                quickAddText = [[NSString alloc] initWithFormat:@"%@-%@ Abstract:%@; Desc:%@; Loc:%@; Category:%@;",
                                      [dateFormatter stringFromDate:_startTimePicker.date],
                                      [timeFormatter stringFromDate:_endTimePicker.date],
                                      _summary.text,
                                      _description.text,
                                      _where.text,
                                      _categories[[_categoryPicker selectedRowInComponent:0]]];
            }
            //Daily Repeat
            else if ((int)(roundf(_repeatSlider.value*100.0)/100.0) == 1) {
                quickAddText = [[NSString alloc] initWithFormat:@"%@-%@ repeat daily for %d days Abstract:%@; Desc:%@; Loc:%@; Category:%@;",
                                [dateFormatter stringFromDate:_startTimePicker.date],
                                [timeFormatter stringFromDate:_endTimePicker.date],
                                (int)(roundf(_numberOfRepeatSlider.value*100.0)/100.0),
                                _summary.text,
                                _description.text,
                                _where.text,
                                _categories[[_categoryPicker selectedRowInComponent:0]]];
            }
            //Weekly Repeat
            else if ((int)(roundf(_repeatSlider.value*100.0)/100.0) == 2) {
                quickAddText = [[NSString alloc] initWithFormat:@"%@-%@ repeat weekly for %d weeks Abstract:%@; Desc:%@; Loc:%@; Category:%@;",
                                [dateFormatter stringFromDate:_startTimePicker.date],
                                [timeFormatter stringFromDate:_endTimePicker.date],
                                (int)(roundf(_numberOfRepeatSlider.value*100.0)/100.0),
                                _summary.text,
                                _description.text,
                                _where.text,
                                _categories[[_categoryPicker selectedRowInComponent:0]]];
            }
            //Monthly Repeat
            else if ((int)(roundf(_repeatSlider.value*100.0)/100.0) == 3) {
                quickAddText = [[NSString alloc] initWithFormat:@"%@-%@ repeat monthly for %d months Abstract:%@; Desc:%@; Loc:%@; Category:%@;",
                                [dateFormatter stringFromDate:_startTimePicker.date],
                                [timeFormatter stringFromDate:_endTimePicker.date],
                                (int)(roundf(_numberOfRepeatSlider.value*100.0)/100.0),
                                _summary.text,
                                _description.text,
                                _where.text,
                                _categories[[_categoryPicker selectedRowInComponent:0]]];
            }
            
            NSLog(@"The quickAdd text: %@", quickAddText);
            
            [[_auth getAuthenticator] callAPI:@"https://www.googleapis.com/calendar/v3/calendars/lcmail.lcsc.edu_09hhfhm9kcn5h9dhu83ogsd0u8@group.calendar.google.com/events/quickAdd"
                               withHttpMethod:httpMethod_POST
                           postParameterNames:[NSArray arrayWithObjects:@"text", nil]
                          postParameterValues:[NSArray arrayWithObjects:quickAddText, nil]];
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"New Event"
                                                            message: @"Your event has been sent to the Google Calendar!"
                                                           delegate: nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
            
            [self.navigationController popToRootViewControllerAnimated:YES];
        }
        else {
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"MM/dd/yyyy"];
            
            NSString *quickAddText = [[NSString alloc] initWithFormat:@"%@-%@ Abstract:%@; Desc:%@; Loc:%@; Category:%@;",
                                      [dateFormatter stringFromDate:_startTimePicker.date],
                                      [dateFormatter stringFromDate:_endTimePicker.date],
                                      _summary.text,
                                      _description.text,
                                      _where.text,
                                      _categories[[_categoryPicker selectedRowInComponent:0]]];
            
            NSLog(@"The quickAdd text: %@", quickAddText);
            
            [[_auth getAuthenticator] callAPI:@"https://www.googleapis.com/calendar/v3/calendars/lcmail.lcsc.edu_09hhfhm9kcn5h9dhu83ogsd0u8@group.calendar.google.com/events/quickAdd"
                               withHttpMethod:httpMethod_POST
                           postParameterNames:[NSArray arrayWithObjects:@"text", nil]
                          postParameterValues:[NSArray arrayWithObjects:quickAddText, nil]];
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"New Event"
                                                            message: @"Your all day event has been sent to the Google Calendar!"
                                                           delegate: nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
            
            [self.navigationController popToRootViewControllerAnimated:YES];
        }
    }
}

- (IBAction)allDayEventToggle:(id)sender {
    if (_allDayEventSwitch.on) {
        _startTimePicker.datePickerMode = UIDatePickerModeDate;
        _endTimePicker.datePickerMode = UIDatePickerModeDate;
        
        _repeatLabel.hidden = YES;
        _repeatSlider.hidden = YES;
        
        _numberOfRepeatLabel.hidden = YES;
        _numberOfRepeatSlider.hidden = YES;
    }
    else {
        _startTimePicker.datePickerMode = UIDatePickerModeDateAndTime;
        _endTimePicker.datePickerMode = UIDatePickerModeTime;
        
        _repeatLabel.hidden = NO;
        _repeatSlider.hidden = NO;
        
        _numberOfRepeatLabel.hidden = NO;
        _numberOfRepeatSlider.hidden = NO;
    }
}

- (IBAction)repeatSliderChanged:(UISlider *)sender {
    //Check to see if the second slider needs to be shown.
    if ([_numberOfRepeatLabel.text isEqualToString:@" "]
        && (int)(roundf(sender.value*100.0)/100.0) != 0) {
        _numberOfRepeatSlider.hidden = NO;
    }
    switch((int)(roundf(sender.value*100.0)/100.0)) {
        case 0:
            _numberOfRepeatLabel.text = @" ";
            _numberOfRepeatSlider.hidden = YES;
            
            _repeatLabel.text = @"No Repeat";
            break;
        case 1:
            _repeatLabel.text = @"Daily Repeat";
            
            _numberOfRepeatSlider.value = 2.5;
            _numberOfRepeatSlider.maximumValue = 14.5;
            
            _numberOfRepeatLabel.text = @"For 2 Days";
            break;
        case 2:
            _repeatLabel.text = @"Weekly Repeat";
            
            _numberOfRepeatSlider.value = 2.5;
            _numberOfRepeatSlider.maximumValue = 8.5;
            
            _numberOfRepeatLabel.text = @"For 2 Weeks";
            break;
        case 3:
            _repeatLabel.text = @"Monthly Repeat";
            
            _numberOfRepeatSlider.value = 2.5;
            _numberOfRepeatSlider.maximumValue = 12.5;
            
            _numberOfRepeatLabel.text = @"For 2 Months";
            break;
            
    }
}

- (IBAction)numberOfRepeatSliderChanged:(UISlider *)sender {
    if ((int)(roundf(_repeatSlider.value*100.0)/100.0) == 1) {
        _numberOfRepeatLabel.text = [NSString stringWithFormat:@"For %d Days", (int)(roundf(sender.value*100.0)/100.0)];
    }
    else if ((int)(roundf(_repeatSlider.value*100.0)/100.0) == 2) {
        _numberOfRepeatLabel.text = [NSString stringWithFormat:@"For %d Weeks", (int)(roundf(sender.value*100.0)/100.0)];
    }
    else if ((int)(roundf(_repeatSlider.value*100.0)/100.0) == 3) {
        _numberOfRepeatLabel.text = [NSString stringWithFormat:@"For %d Months", (int)(roundf(sender.value*100.0)/100.0)];
    }
}

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    //One column
    return 1;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    //set number of rows
    return _categories.count;
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    //set item per row
    return [_categories objectAtIndex:row];
}



- (void)textFieldDidBeginEditing:(UITextField *)textField {
    CGRect textFieldRect = [self.view.window convertRect:textField.bounds fromView:textField];
    CGRect viewRect = [self.view.window convertRect:self.view.bounds fromView:self.view];
    
    CGFloat midline = textFieldRect.origin.y + 0.5 * textFieldRect.size.height;
    
    CGFloat numerator = midline - viewRect.origin.y
    - MINIMUM_SCROLL_FRACTION * viewRect.size.height;
    
    CGFloat denominator = (MAXIMUM_SCROLL_FRACTION - MINIMUM_SCROLL_FRACTION)
    * viewRect.size.height;
    
    CGFloat heightFraction = numerator / denominator;
    
    if (heightFraction < 0.0)
    {
        heightFraction = 0.0;
    }
    else if (heightFraction > 1.0)
    {
        heightFraction = 1.0;
    }
    
    UIInterfaceOrientation orientation =[[UIApplication sharedApplication] statusBarOrientation];
    
    if (orientation == UIInterfaceOrientationPortrait ||
        orientation == UIInterfaceOrientationPortraitUpsideDown)
    {
        animatedDistance = floor(PORTRAIT_KEYBOARD_HEIGHT * heightFraction);
    }
    else
    {
        animatedDistance = floor(LANDSCAPE_KEYBOARD_HEIGHT * heightFraction);
    }
    
    CGRect viewFrame = self.view.frame;
    viewFrame.origin.y -= animatedDistance;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:KEYBOARD_ANIMATION_DURATION];
    
    [self.view setFrame:viewFrame];
    
    [UIView commitAnimations];
}


- (void)textFieldDidEndEditing:(UITextField *)textField {
    CGRect viewFrame = self.view.frame;
    viewFrame.origin.y += animatedDistance;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:KEYBOARD_ANIMATION_DURATION];
    
    [self.view setFrame:viewFrame];
    
    [UIView commitAnimations];
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}


- (void)textViewDidBeginEditing:(UITextField *)textField {
    CGRect textFieldRect = [self.view.window convertRect:textField.bounds fromView:textField];
    CGRect viewRect = [self.view.window convertRect:self.view.bounds fromView:self.view];
    
    CGFloat midline = textFieldRect.origin.y + 0.5 * textFieldRect.size.height;
    
    CGFloat numerator = midline - viewRect.origin.y
    - MINIMUM_SCROLL_FRACTION * viewRect.size.height;
    
    CGFloat denominator = (MAXIMUM_SCROLL_FRACTION - MINIMUM_SCROLL_FRACTION)
    * viewRect.size.height;
    
    CGFloat heightFraction = numerator / denominator;
    
    if (heightFraction < 0.0)
    {
        heightFraction = 0.0;
    }
    else if (heightFraction > 1.0)
    {
        heightFraction = 1.0;
    }
    
    UIInterfaceOrientation orientation =[[UIApplication sharedApplication] statusBarOrientation];
    
    if (orientation == UIInterfaceOrientationPortrait ||
        orientation == UIInterfaceOrientationPortraitUpsideDown)
    {
        animatedDistance = floor(PORTRAIT_KEYBOARD_HEIGHT * heightFraction);
    }
    else
    {
        animatedDistance = floor(LANDSCAPE_KEYBOARD_HEIGHT * heightFraction);
    }
    
    CGRect viewFrame = self.view.frame;
    viewFrame.origin.y -= animatedDistance;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:KEYBOARD_ANIMATION_DURATION];
    
    [self.view setFrame:viewFrame];
    
    [UIView commitAnimations];
}

//This limits the characters within the date and time text fields to two characters and will display an alert if an invalid number is entered.
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    BOOL charShouldChange = YES;
    
    //This accounts for the year field (because it allows 4 characters.)
    if (textField.tag == 30) {
        NSUInteger newLength = [textField.text length] + [string length] - range.length;
        charShouldChange = (newLength > 4) ? NO : YES;
    }
    else if (textField.tag == 1){
        NSUInteger newLength = [textField.text length] + [string length] - range.length;
        charShouldChange = (newLength > 54) ? NO : YES;
    }
    else if (textField.tag == 2){
        NSUInteger newLength = [textField.text length] + [string length] - range.length;
        charShouldChange = (newLength > 28) ? NO : YES;
    }
    return charShouldChange;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    return textView.text.length + (text.length - range.length) <= 120;
}

- (void)textViewDidEndEditing:(UITextField *)textField {
    CGRect viewFrame = self.view.frame;
    viewFrame.origin.y += animatedDistance;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:KEYBOARD_ANIMATION_DURATION];
    
    [self.view setFrame:viewFrame];
    
    [UIView commitAnimations];
}


-(void)tap:(UITapGestureRecognizer *)tapRec{
    [[self view] endEditing: YES];
}



#pragma mark - GoogleOAuth class delegate method implementation

-(void)authorizationWasSuccessful {
}

-(void)responseFromServiceWasReceived:(NSString *)responseJSONAsString andResponseJSONAsData:(NSData *)responseJSONAsData{
    NSLog(@"%@", responseJSONAsString);
}

-(void)accessTokenWasRevoked{
}


-(void)errorOccuredWithShortDescription:(NSString *)errorShortDescription andErrorDetails:(NSString *)errorDetails{
    // Just log the error messages.
    NSLog(@"%@", errorShortDescription);
    NSLog(@"%@", errorDetails);
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle: errorShortDescription
                                                    message: errorDetails
                                                   delegate: nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}


-(void)errorInResponseWithBody:(NSString *)errorMessage{
    // Just log the error message.
    NSLog(@"%@", errorMessage);
}



@end
