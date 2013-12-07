//
//  AddEventViewController.m
//  campuslife
//
//  Created by Super Student on 12/2/13.
//  Copyright (c) 2013 LCSC. All rights reserved.
//


#import "AddEventViewController.h"
#import "Authentication.h"
#import "MonthlyEvents.h"

static const CGFloat KEYBOARD_ANIMATION_DURATION = 0.3;
static const CGFloat MINIMUM_SCROLL_FRACTION = 0.2;
static const CGFloat MAXIMUM_SCROLL_FRACTION = 0.8;
static const CGFloat PORTRAIT_KEYBOARD_HEIGHT = 216;
static const CGFloat LANDSCAPE_KEYBOARD_HEIGHT = 162;

@interface AddEventViewController () {
    CGFloat animatedDistance;
}

@property (nonatomic) Authentication *auth;

//The stepper button will cycle through the possible categories.
@property (nonatomic, strong) NSArray *categories;

@end

@implementation AddEventViewController

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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(IBAction) addEvent {
    
    NSString *quickAddText = [[NSString alloc] initWithFormat:@"%@/%@/%@ %@:%@%@-%@:%@%@",
                              _month.text,
                              _day.text,
                              _year.text,
                              _fromHour.text,
                              _fromMinute.text,
                              _fromPeriod.titleLabel,
                              _toHour.text,
                              _toMinute.text,
                              _toPeriod.titleLabel];
    
    [[_auth getAuthenticator] callAPI:@"https://www.googleapis.com/calendar/v3/calendars/lcmail.lcsc.edu_09hhfhm9kcn5h9dhu83ogsd0u8@group.calendar.google.com/events/quickAdd"
                       withHttpMethod:httpMethod_POST
                   postParameterNames:[NSArray arrayWithObjects:@"text", nil]
                  postParameterValues:[NSArray arrayWithObjects:@"12/7/13 12pm-1pm Cake Dance", nil]];
}

- (IBAction)categoryStepper:(UIStepper *)sender {
    _category.text = _categories[(int)[sender value]];
}

- (IBAction)periodToggle:(UIButton *)sender {
    if ([sender.titleLabel.text isEqual:@"AM"]) {
        [sender setTitle:@"PM" forState:UIControlStateNormal];
    }
    else {
        [sender setTitle:@"AM" forState:UIControlStateNormal];
    }
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
    
    //These tags are associated with the text fields that represent the day/time of the event.
    if (textField.tag >= 21 && textField.tag <= 27) {
        NSUInteger newLength = [textField.text length] + [string length] - range.length;
        charShouldChange = (newLength > 2) ? NO : YES;
        
        //Only restrict characters if the string is still valid.
        if (charShouldChange) {
            //If month tag.
            if (textField.tag == 21) {
                //Is the month invalid?
                if ([[_month.text stringByAppendingString:string] intValue] > 12
                    || [[_month.text stringByAppendingString:string] intValue] < 1) {
                    charShouldChange = NO;
                    _month.text = @"";
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Invalid Entry"
                                                                    message: @"Re-enter the month."
                                                                   delegate: nil
                                                          cancelButtonTitle:@"OK"
                                                          otherButtonTitles:nil];
                    [alert show];
                }
            }
            //If day tag.
            else if (textField.tag == 22) {
                MonthlyEvents *events = [MonthlyEvents getSharedInstance];
                int maxDays = 31;
                
                //Sets the maxDays correctl provided that a month was entered in.
                if (![_month.text isEqualToString:@""]) {
                    maxDays = [events getDaysOfMonth:[_month.text intValue]];
                }
                
                if ([[_day.text stringByAppendingString:string] intValue] > maxDays
                    || [[_day.text stringByAppendingString:string] intValue] < 1) {
                    charShouldChange = NO;
                    _day.text = @"";
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Invalid Entry"
                                                                    message: @"Re-enter the day."
                                                                   delegate: nil
                                                          cancelButtonTitle:@"OK"
                                                          otherButtonTitles:nil];
                    [alert show];
                }
            }
            //Ignore correcting the year field. Good luck with that one people.
            //If from hour tag.
            else if (textField.tag == 24) {
                if ([[_fromHour.text stringByAppendingString:string] intValue] > 12
                    || [[_fromHour.text stringByAppendingString:string] intValue] < 1) {
                    charShouldChange = NO;
                    _fromHour.text = @"";
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Invalid Entry"
                                                                    message: @"Re-enter the from hour."
                                                                   delegate: nil
                                                          cancelButtonTitle:@"OK"
                                                          otherButtonTitles:nil];
                    [alert show];
                }
            }
            //If from minute tag.
            else if (textField.tag == 25) {
                if ([[_fromMinute.text stringByAppendingString:string] intValue] > 59
                    || [[_fromMinute.text stringByAppendingString:string] intValue] < 0) {
                    charShouldChange = NO;
                    _fromMinute.text = @"";
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Invalid Entry"
                                                                    message: @"Re-enter the from minute."
                                                                   delegate: nil
                                                          cancelButtonTitle:@"OK"
                                                          otherButtonTitles:nil];
                    [alert show];
                }
            }
            //If to hour tag.
            else if (textField.tag == 26) {
                if ([[_toHour.text stringByAppendingString:string] intValue] > 12
                    || [[_toHour.text stringByAppendingString:string] intValue] < 1) {
                    charShouldChange = NO;
                    _toHour.text = @"";
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Invalid Entry"
                                                                    message: @"Re-enter the to hour."
                                                                   delegate: nil
                                                          cancelButtonTitle:@"OK"
                                                          otherButtonTitles:nil];
                    [alert show];
                }
            }
            //If to minute tag.
            else if (textField.tag == 27) {
                if ([[_toMinute.text stringByAppendingString:string] intValue] > 59
                    || [[_toMinute.text stringByAppendingString:string] intValue] < 0) {
                    charShouldChange = NO;
                    _toMinute.text = @"";
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Invalid Entry"
                                                                    message: @"Re-enter the to minute."
                                                                   delegate: nil
                                                          cancelButtonTitle:@"OK"
                                                          otherButtonTitles:nil];
                    [alert show];
                }
            }
        }
    }
    return charShouldChange;
}

- (BOOL)textView:(UITextView *)textView shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSUInteger newLength = [textView.text length] + [string length] - range.length;
    return (newLength > 2) ? NO : YES;
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
}


-(void)errorInResponseWithBody:(NSString *)errorMessage{
    // Just log the error message.
    NSLog(@"%@", errorMessage);
}



@end
