//
//  AddEventForDayViewController.m
//  campuslife
//
//  Created by Super Student on 12/2/13.
//  Copyright (c) 2013 LCSC. All rights reserved.
//

//This is for checking to see if an ipad is being used.
#define IDIOM    UI_USER_INTERFACE_IDIOM()
#define IPAD     UIUserInterfaceIdiomPad


#import "AddEventForDayViewController.h"
#import "Authentication.h"
#import "MonthlyEvents.h"

static const CGFloat KEYBOARD_ANIMATION_DURATION = 0.3;
static const CGFloat MINIMUM_SCROLL_FRACTION = 0.2;
static const CGFloat MAXIMUM_SCROLL_FRACTION = 0.8;
static const CGFloat PORTRAIT_KEYBOARD_HEIGHT = 216;
static const CGFloat LANDSCAPE_KEYBOARD_HEIGHT = 162;

@interface AddEventForDayViewController () {
    CGFloat animatedDistance;
}

@property (nonatomic) Authentication *auth;

//The stepper button will cycle through the possible categories.
@property (nonatomic, strong) NSArray *categories;

@end

@implementation AddEventForDayViewController

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
    
    [_auth setDelegate:self];
    
    _categories = [[NSArray alloc] initWithObjects:@"Entertainment", @"Academics", @"Activities", @"Residence", @"Athletics", nil];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    if (IDIOM != IPAD) {
        [_scrollView layoutIfNeeded];
        _scrollView.contentSize = CGSizeMake(320, 1050);
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
    if ([_summary.text isEqualToString:@""]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Blank Field"
                                                        message: @"The Summary field is empty, please fill it in and try again."
                                                       delegate: nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }
    else {
        if (!_allDayEventSwitch.on) {
            NSDateFormatter *timeFormatter = [[NSDateFormatter alloc] init];
            [timeFormatter setDateFormat:@"HHmm"];
            //Check the times to see if they are valid.
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
        MonthlyEvents *events = [MonthlyEvents getSharedInstance];
        
        //Events have specified time constraints unless they are all day events.
        if (!_allDayEventSwitch.on) {
            NSDateFormatter *timeFormatter = [[NSDateFormatter alloc] init];
            [timeFormatter setDateFormat:@"HH:mm"];
            
            NSString *quickAddText = [[NSString alloc] initWithFormat:@"%d/%d/%d %@-%@ Abstract:%@; Desc:%@; Loc:%@; Category:%@;",
                                      events.getSelectedMonth,
                                      events.getSelectedDay,
                                      events.getSelectedYear,
                                      [timeFormatter stringFromDate:_startTimePicker.date],
                                      [timeFormatter stringFromDate:_endTimePicker.date],
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
                                                            message: @"Your event has been sent to the Google Calendar!"
                                                           delegate: nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
        }
        else {
            NSString *quickAddText = [[NSString alloc] initWithFormat:@"%d/%d/%d Abstract:%@; Desc:%@; Loc:%@; Category:%@;",
                                      events.getSelectedMonth,
                                      events.getSelectedDay,
                                      events.getSelectedYear,
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
        }
    }
}

- (IBAction)allDayEventToggle:(id)sender {
    _startTimePicker.hidden = _allDayEventSwitch.on;
    _endTimePicker.hidden = _allDayEventSwitch.on;
    
    if (_allDayEventSwitch.on) {
        _startTimeLabel.text = @" ";
        _endTimeLabel.text = @" ";
    }
    else {
        _startTimeLabel.text = @"Start of Event";
        _endTimeLabel.text = @"End of Event";
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
    
    if (textField.tag == 1){
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
