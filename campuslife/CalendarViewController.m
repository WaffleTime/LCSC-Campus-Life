//
//  ViewController.m
//  LCSC Campus Life
//
//  Created by Super Student on 10/29/13.
//  Copyright (c) 2013 LCSC. All rights reserved.
//

//This is for checking to see if an ipad is being used.
#define IDIOM    UI_USER_INTERFACE_IDIOM()
#define IPAD     UIUserInterfaceIdiomPad


#import "CalendarViewController.h"
#import "MonthlyEvents.h"
#import "Preferences.h"
#import "Authentication.h"

@interface CalendarViewController ()


@property (nonatomic, setter=setSignedIn:) BOOL signedIn;

@property (nonatomic) MonthlyEvents *events;

@property (nonatomic) Authentication *auth;

@end

@implementation CalendarViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    NSLog(@"authorizing user");
    
    [[self navigationController] setNavigationBarHidden:YES animated:NO];
    
    _auth = [Authentication getSharedInstance];
    
    // Initialize the googleOAuth object.
    // Pay attention so as to initialize it with the initWithFrame: method, not just init.
    GoogleOAuth *googleOAuth = [[GoogleOAuth alloc] initWithFrame:self.view.frame];
    // Set self as the delegate.
    [googleOAuth setGOAuthDelegate:self];
    
    [googleOAuth authorizeUserWithClienID:@"408837038497.apps.googleusercontent.com"
                           andClientSecret:@"boEOJa_DKR9c06vLWbBdmC92"
                             andParentView:self.view
                                 andScopes:[NSArray arrayWithObject:@"https://www.googleapis.com/auth/calendar"]];
    
    //Stores the authenticator so that it can be used
    [_auth setAuthenticator:googleOAuth];
    
    [self setSignedIn:NO];
    self.signInOutButton.title = @"Sign In";
    
    _events = [MonthlyEvents getSharedInstance];

    if (IDIOM == IPAD) {
        [_cat1Btn setBackgroundImage:[UIImage imageNamed:@"selected-ipad.png"]
                            forState:UIControlStateSelected];
        [_cat2Btn setBackgroundImage:[UIImage imageNamed:@"selected-ipad.png"]
                            forState:UIControlStateSelected];
        [_cat3Btn setBackgroundImage:[UIImage imageNamed:@"selected-ipad.png"]
                            forState:UIControlStateSelected];
        [_cat4Btn setBackgroundImage:[UIImage imageNamed:@"selected-ipad.png"]
                            forState:UIControlStateSelected];
        [_cat5Btn setBackgroundImage:[UIImage imageNamed:@"selected-ipad.png"]
                            forState:UIControlStateSelected];
    }
    else {
        [_cat1Btn setBackgroundImage:[UIImage imageNamed:@"selected.png"]
                                     forState:UIControlStateSelected];
        [_cat2Btn setBackgroundImage:[UIImage imageNamed:@"selected.png"]
                            forState:UIControlStateSelected];
        [_cat3Btn setBackgroundImage:[UIImage imageNamed:@"selected.png"]
                            forState:UIControlStateSelected];
        [_cat4Btn setBackgroundImage:[UIImage imageNamed:@"selected.png"]
                                     forState:UIControlStateSelected];
        [_cat5Btn setBackgroundImage:[UIImage imageNamed:@"selected.png"]
                                     forState:UIControlStateSelected];
    }
    
    Preferences *prefs = [Preferences getSharedInstance];
    
    //Here we load the actual state of the selected buttons.
    [_cat1Btn setSelected:[prefs getPreference:1]];
    [_cat2Btn setSelected:[prefs getPreference:2]];
    [_cat3Btn setSelected:[prefs getPreference:3]];
    [_cat4Btn setSelected:[prefs getPreference:4]];
    [_cat5Btn setSelected:[prefs getPreference:5]];
}

- (void) viewDidAppear:(BOOL)animated {
    NSLog(@"view appeared");
    
    [[self navigationController] setNavigationBarHidden:YES animated:NO];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)signOutOrSignIn:(id)sender {
    if (_signedIn) {
        // Revoke the access token.
        [[_auth getAuthenticator] revokeAccessToken];
        
        [self setSignedIn:NO];
        
        self.signInOutButton.title = @"Sign In";
        
        [_collectionView reloadData];
        
        //NSLog(@"Signed out we did");
    }
    else {
        [[_auth getAuthenticator] authorizeUserWithClienID:@"408837038497.apps.googleusercontent.com"
                                           andClientSecret:@"boEOJa_DKR9c06vLWbBdmC92"
                                             andParentView:self.view
                                                 andScopes:[NSArray arrayWithObject:@"https://www.googleapis.com/auth/calendar"]];
        
        [self setSignedIn:NO];
        self.signInOutButton.title = @"Sign In";
        
        //NSLog(@"Signed in we did");
    }
}

- (IBAction)radioSelected:(UIButton *)sender {
    Preferences *prefs = [Preferences getSharedInstance];
    
    switch (sender.tag) {
        case 1:
            [prefs negatePreference:1];
            [_cat1Btn setSelected:[prefs getPreference:1]];
            break;
        case 2:
            [prefs negatePreference:2];
            [_cat2Btn setSelected:[prefs getPreference:2]];
            break;
        case 3:
            [prefs negatePreference:3];
            [_cat3Btn setSelected:[prefs getPreference:3]];
            break;
        case 4:
            [prefs negatePreference:4];
            [_cat4Btn setSelected:[prefs getPreference:4]];
            break;
        case 5:
            [prefs negatePreference:5];
            [_cat5Btn setSelected:[prefs getPreference:5]];
            break;
    }
    
    [_collectionView reloadData];
}

- (IBAction)backMonthOffset:(id)sender {
    [_activityIndicator startAnimating];
    
    [_events offsetMonth:-1];
    
    _monthLabel.text = [_events getMonthBarDate];
    
    [self getEventsForMonth:[_events getSelectedMonth] :[_events getSelectedYear]];
    
    //NSLog(@"went to previous month");
}

- (IBAction)forwardMonthOffset:(id)sender {
    [_activityIndicator startAnimating];
    
    [_events offsetMonth:1];
    
    _monthLabel.text = [_events getMonthBarDate];
    
    [self getEventsForMonth:[_events getSelectedMonth] :[_events getSelectedYear]];
    
    //NSLog(@"went to next month");
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    int cells;
    
    if (_signedIn) {
        cells = 35;
        
        //NSLog(@"The number of cells required:%d", [events getFirstWeekDay] + [events getDaysOfMonth]-1);
        
        if ([_events getFirstWeekDay] + [_events getDaysOfMonth]-1 >= 35) {
            cells = 42;
        }
    }
    else {
        cells = 0;
    }
    
    return cells;
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    UICollectionViewCell *cell;
    
    //NSLog(@"The first weekday is:%d", [events getFirstWeekDay]);
    
    //NSLog(@"Check to see if cell is for next month:%d >= %d", indexPath.row+1 - [events getFirstWeekDay], [events getDaysOfMonth]);
    
    //Check to see if this cell is for a day of the previous month
    if (indexPath.row+1 - [_events getFirstWeekDay] <= 0) {
        cell = (UICollectionViewCell *)[_collectionView dequeueReusableCellWithReuseIdentifier:@"OtherMonthCell" forIndexPath:indexPath];
        
        UILabel *dayLbl = (UILabel *)[cell viewWithTag:100];
        
        dayLbl.text = [NSString stringWithFormat:@"%d", (int)indexPath.row+1 - [_events getFirstWeekDay] + [_events getDaysOfPreviousMonth]];
    }
    //Check to see if this cell is for a day of the next month
    else if (indexPath.row+1 - [_events getFirstWeekDay] > [_events getDaysOfMonth]) {
        cell = (UICollectionViewCell *)[_collectionView dequeueReusableCellWithReuseIdentifier:@"OtherMonthCell" forIndexPath:indexPath];
        
        UILabel *dayLbl = (UILabel *)[cell viewWithTag:100];

        dayLbl.text = [NSString stringWithFormat:@"%d", (int)indexPath.row+1 - [_events getFirstWeekDay] - [_events getDaysOfMonth]];
    }
    else {
        cell = (UICollectionViewCell *)[_collectionView dequeueReusableCellWithReuseIdentifier:@"CurrentDayCell" forIndexPath:indexPath];
        
        UILabel *dayLbl = (UILabel *)[cell viewWithTag:100];
        
        dayLbl.text = [NSString stringWithFormat:@"%d", (int)indexPath.row+1 - [_events getFirstWeekDay]];
        
        //Grab the squares for each category.
        UIView *cat1 = (UIView *)[cell viewWithTag:11];
        if (!cat1.hidden) {
            cat1.hidden = YES;
        }
        UIView *cat2 = (UIView *)[cell viewWithTag:12];
        if (!cat2.hidden) {
            cat2.hidden = YES;
        }
        UIView *cat3 = (UIView *)[cell viewWithTag:13];
        if (!cat3.hidden) {
            cat3.hidden = YES;
        }
        UIView *cat4 = (UIView *)[cell viewWithTag:14];
        if (!cat4.hidden) {
            cat4.hidden = YES;
        }
        UIView *cat5 = (UIView *)[cell viewWithTag:15];
        if (!cat5.hidden) {
            cat5.hidden = YES;
        }
        
        //This holds the preferences based on the legend at the top.
        Preferences *prefs = [Preferences getSharedInstance];
        
        //Showing relevant category by making the colorful squares not hidden anymore.
        NSArray *dayEvents = [_events getEventsForDay:(int)indexPath.row+1 - [_events getFirstWeekDay]];

        //Iterate through all events and determine categories that are present.
        for (int i=0; i<[dayEvents count]; i++) {
            //NSString *category = [[dayEvents objectAtIndex:i] objectForKey:@"category"];
            
            //NSLog(@"The event's colorId is %d", [[[dayEvents objectAtIndex:i] objectForKey:@"colorId"] intValue]);
            
            //The colorId denotes the category
            switch ([[[dayEvents objectAtIndex:i] objectForKey:@"colorId"] intValue]) {
                //We'll unhide the category squares that are found.
                //Case Entertainment
                case 11:
                    if (cat1.hidden) {
                        //Check to see if this category is selected.
                        if ([prefs getPreference:1]) {
                            cat1.hidden = NO;
                        }
                    }
                    break;
                //case Academics
                case 9:
                    if (cat2.hidden) {
                        //Check to see if this category is selected.
                        if ([prefs getPreference:2]) {
                            cat2.hidden = NO;
                        }
                    }
                    break;
                //case Activities
                case 5:
                    if (cat3.hidden) {
                        //Check to see if this category is selected.
                        if ([prefs getPreference:3]) {
                            cat3.hidden = NO;
                        }
                    }
                    break;
                //case Residence
                case 6:
                    if (cat4.hidden) {
                        //Check to see if this category is selected.
                        if ([prefs getPreference:4]) {
                            cat4.hidden = NO;
                        }
                    }
                    break;
                //case Athletics
                case 10:
                    if (cat5.hidden) {
                        //Check to see if this category is selected.
                        if ([prefs getPreference:5]) {
                            cat5.hidden = NO;
                        }
                    }
                    break;
            }
        }
    }
    
    return cell;
}

-(void) prepareForSegue:(UIStoryboardPopoverSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"CalendarToDayEvents"]) {
        NSArray *indexPaths = [_collectionView indexPathsForSelectedItems];
        NSIndexPath *indexPath = [indexPaths objectAtIndex:0];
        
        //Day_Event_ViewController *destViewController = (Day_Event_ViewController *)[segue destinationViewController];
        
        //[destViewController setDay:indexPath.row+1 - [events getFirstWeekDay] ];
        
        [_events setSelectedDay:(int)indexPath.row+1 - [_events getFirstWeekDay]];
        
        NSLog(@"The selected day is %d", (int)indexPath.row+1 - [_events getFirstWeekDay]);
    }
}


- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    BOOL canSegue = YES;
    
    if ([identifier isEqualToString:@"CalendarToDayEvents"]) {
        NSArray *indexPaths = [_collectionView indexPathsForSelectedItems];
        NSIndexPath *indexPath = [indexPaths objectAtIndex:0];
        
        //Check to see if this cell is for a day of the previous month
        if (indexPath.row+1 - [_events getFirstWeekDay] <= 0) {
            //Offset month if a previous month's cell is clicked
            [self backMonthOffset:nil];
            canSegue = NO;
        }
        //Check to see if this cell is for a day of the next month
        else if (indexPath.row+1 - [_events getFirstWeekDay] > [_events getDaysOfMonth]) {
            //Offset month if a future month's cell is clicked
            [self forwardMonthOffset:nil];
            canSegue = NO;
        }
    }
    return canSegue;
}


- (NSDate *)returnDateForMonth:(NSInteger)month year:(NSInteger)year day:(NSInteger)day {
    
    NSDateComponents *components = [[NSDateComponents alloc] init];
    
    [components setDay:day];
    [components setMonth:month];
    [components setYear:year];
    
    NSCalendar *gregorian = [[NSCalendar alloc]
                             initWithCalendarIdentifier:NSGregorianCalendar];
    return [gregorian dateFromComponents:components];
}

- (NSString*)toStringFromDateTime:(NSDate*)dateTime {
    // Purpose: Return a string of the specified date-time in UTC (Zulu) time zone in ISO 8601 format.
    // Example: 2013-10-25T06:59:43.431Z
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    //[dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSZZZ"];
    NSString* sDateTime = [dateFormatter stringFromDate:dateTime];
    return sDateTime;
}

- (void) getEventsForMonth:(NSInteger) month :(NSInteger) year {
    NSDate * firstDateOfMonth = [self returnDateForMonth:month year:year day:1];
    NSDate * lastDateOfMonth = [self returnDateForMonth:month+1 year:year day:0];
    
    //NSLog(@"Getting events for selected month, month:%@, year:%@", [self toStringFromDateTime:firstDateOfMonth], [self toStringFromDateTime:lastDateOfMonth]);
    
    // If user authorization is successful, then make an API call to get the event list for the current month.
    // For more infomation about this API call, visit:
    // https://developers.google.com/google-apps/calendar/v3/reference/calendarList/list
    [[_auth getAuthenticator] callAPI:@"https://www.googleapis.com/calendar/v3/calendars/lcmail.lcsc.edu_09hhfhm9kcn5h9dhu83ogsd0u8@group.calendar.google.com/events"
                       withHttpMethod:httpMethod_GET
                   postParameterNames:[NSArray arrayWithObjects:@"timeMax", @"timeMin", nil]
                  postParameterValues:[NSArray arrayWithObjects:[self toStringFromDateTime:lastDateOfMonth], [self toStringFromDateTime:firstDateOfMonth], nil]];
}


#pragma mark - GoogleOAuth class delegate method implementation

-(void)authorizationWasSuccessful {
    NSCalendar * calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDate *date = [NSDate date];
    
    unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit;
    NSDateComponents *comps = [calendar components:unitFlags fromDate:date];
    
    [self getEventsForMonth:comps.month :comps.year];
    
    //NSLog(@"Getting the events for the current month");
}

-(void)responseFromServiceWasReceived:(NSString *)responseJSONAsString andResponseJSONAsData:(NSData *)responseJSONAsData{
    NSError *error;
    
    //If we reach this point and the user is not signed in, that means the user just signed in or out.
    //The problem is that when we go to sign out, an empty json is sent after we've already set _signedIn to No.
    //  So we'll just ignore cases when we get an empty json file while we're signed out.
    //  This won't be triggered while we're signed in and getting empty json strings for empty months.
    if (!_signedIn) {
        
        //If the response json isn't empty, then we signed in.
        if (![responseJSONAsString isEqualToString:@""]) {
            [self setSignedIn:YES];
        
            self.signInOutButton.title = @"Sign Out";
        }
    }
    
    if ([responseJSONAsString rangeOfString:@"calendar#events"].location != NSNotFound) {
        // Get the JSON data as a dictionary.
        NSDictionary *eventsInfoDict = [NSJSONSerialization JSONObjectWithData:responseJSONAsData options:NSJSONReadingMutableContainers error:&error];
        
        if (error) {
            // This is the case that an error occured during converting JSON data to dictionary.
            // Simply log the error description.
            NSLog(@"%@", [error localizedDescription]);
        }
        else{
            //Get the events as an array
            NSArray *eventsInfo = [eventsInfoDict objectForKey:@"items"];
            
            //NSLog(@"Putting the events into _calendarEvents.");
            
            [_events refreshArrayOfEvents];
            
            _monthLabel.text = [_events getMonthBarDate];
            
            //Loop through the events
            for (int i=0; i<[eventsInfo count]; i++) {
                //NSMutableDictionary *mCurrentEvent = [[NSMutableDictionary alloc] initWithDictionary:[eventsInfo objectAtIndex:i]];
                
                NSInteger day;
                
                if ([[[eventsInfo objectAtIndex:i] objectForKey:@"start"] objectForKey:@"dateTime"] != nil) {
                    day = [[[[[eventsInfo objectAtIndex:i]
                                        objectForKey:@"start"]
                                       objectForKey:@"dateTime"]
                                      substringWithRange:NSMakeRange(8, 2)]
                                     integerValue];
                }
                else {
                    day = [[[[[eventsInfo objectAtIndex:i]
                                        objectForKey:@"start"]
                                       objectForKey:@"date"]
                                      substringWithRange:NSMakeRange(8, 2)]
                                     integerValue];
                }
                //NSLog(@"The day of the event is %ld", day);
                
                //This then uses that day as an index and inserts the currentEvent into that indice's array.
                [_events AppendEvent:day :[eventsInfo objectAtIndex:i]];
            }
            //NSLog(@"These are our calendar events: %@",_calendarEvents);
            
            [_collectionView reloadData];
        }
        
        [_activityIndicator stopAnimating];
    }
}

-(void)accessTokenWasRevoked{
    [_events refreshArrayOfEvents];
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
