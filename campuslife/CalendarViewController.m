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
#import "AddEventParentViewController.h"

@interface CalendarViewController ()


@property (nonatomic, setter=setSignedIn:) BOOL signedIn;

@property (nonatomic) BOOL authenticating;

@property (nonatomic) int jsonsToIgnore;

//This variable correlates with the one from MonthlyEvents.h/m
@property (nonatomic) int curArrayId;

@property (nonatomic) MonthlyEvents *events;

@property (nonatomic) Authentication *auth;

@property (nonatomic) int reqsSent;

@property (nonatomic) NSDate *start;

@property (nonatomic) NSDate * firstDateOfMonth;

@property (nonatomic) NSDate * lastDateOfMonth;

@property (nonatomic) BOOL screenLocked;

//This is for delaying requests each time you switch between months.
@property (nonatomic) NSTimer *delayTimer;

@property (nonatomic) NSTimeInterval timeLastMonthSwitch;

@property (nonatomic) BOOL monthNeedsLoaded;

//These are for keeping track of the jsons that aren't being sent back to us.
@property (nonatomic) NSTimer *timer;

@property (nonatomic) NSTimeInterval timeLastReqSent;

@end

@implementation CalendarViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    //NSLog(@"authorizing user");
    
    [[self navigationController] setNavigationBarHidden:YES animated:NO];
    
    _auth = [Authentication getSharedInstance];
    
    // Initialize the googleOAuth object.
    // Pay attention so as to initialize it with the initWithFrame: method, not just init.
    GoogleOAuth *googleOAuth = [[GoogleOAuth alloc] initWithFrame:self.view.frame];
    // Set self as the delegate.
    [googleOAuth setGOAuthDelegate:self];
    
    //Stores the authenticator so that it can be used
    [_auth setAuthenticator:googleOAuth];
    
    [_auth setActivitiesCalId:@"l9qpkh5gb7dhjqv8nm0mn098fk@group.calendar.google.com"];
    [_auth setEntertainmentCalId:@"m6h2d5afcjfnmaj8qr7o96q89c@group.calendar.google.com"];
    [_auth setResidenceCalId:@"gqv0n6j15pppdh0t8adgc1n1ts@group.calendar.google.com"];
    [_auth setAthleticsCalId:@"d6jbgjhudph2mpef1cguhn4g9g@group.calendar.google.com"];
    [_auth setAcademicsCalId:@"0rn5mgclnhc7htmh0ht0cc5pgk@group.calendar.google.com"];
    [_auth setCampusRecCalId:@"h4j413d3q0uftb2crk0t92jjlc@group.calendar.google.com"];

    
    [self setSignedIn:NO];
    self.signInOutButton.title = @"Sign In";
    
    _events = [MonthlyEvents getSharedInstance];
    
    Preferences *prefs = [Preferences getSharedInstance];
    
    //Here we load the actual state of the selected buttons.
    [_cat1Btn setSelected:[prefs getPreference:1]];
    [_cat2Btn setSelected:[prefs getPreference:2]];
    [_cat3Btn setSelected:[prefs getPreference:3]];
    [_cat4Btn setSelected:[prefs getPreference:4]];
    [_cat5Btn setSelected:[prefs getPreference:5]];
    [_cat6Btn setSelected:[prefs getPreference:6]];
    
    _leftArrow.enabled = NO;
    _rightArrow.enabled = NO;
    
    _jsonsToIgnore = 0;
    _reqsSent = 0;

    _curArrayId = 1;
    
    _screenLocked = NO;
    
    //We don't need to refresh the calendar since
    _shouldRefresh = NO;
    
    [self signOutOrSignIn:NULL];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(returnToCalendar)name:UIApplicationWillEnterForegroundNotification object:nil];
    
    _timer = [NSTimer scheduledTimerWithTimeInterval: 1
                                             target: self
                                           selector: @selector(onTick:)
                                           userInfo: nil
                                            repeats: YES];
    
    _monthNeedsLoaded = NO;
    
    _timeLastMonthSwitch = 0;
    _timeLastReqSent = 0;
    
    _delayTimer = [NSTimer scheduledTimerWithTimeInterval: 0.05
                                              target: self
                                            selector: @selector(onTickForDelay:)
                                            userInfo: nil
                                             repeats: YES];
    
    NSLog(@"viewDidLoad was called");
}

- (void) viewDidAppear:(BOOL)animated {
    //NSLog(@"view appeared");
    
    [[self navigationController] setNavigationBarHidden:YES animated:NO];
    
    [_auth setDelegate:self];
    
    if (_shouldRefresh) {
        [_activityIndicator startAnimating];
        
        [_events resetEvents];
        
        _curArrayId = 1;
        
        [self getEventsForMonth:[_events getSelectedMonth] :[_events getSelectedYear]];
        
        _shouldRefresh = NO;
    }
    
    NSLog(@"viewDidAppear was called");
}

- (void)onTick:(NSTimer*)timer
{
    //Check a bunch of conditions that altogether mean that the json that we're expecting
    //  hasn't been heard from for over 3 seconds. This hopefully means it won't be coming back.
    if (_signedIn && _reqsSent != 0
        && _timeLastReqSent + 5 < [[NSDate date] timeIntervalSince1970])
    {
        //Reset variables
        _jsonsToIgnore = 0;
        _reqsSent = 0;
        
        [_events resetEvents];
        
        _curArrayId = 1;
        
        //Resend the requests that failed.
        if (_authenticating)
        {
            _reqsSent += 1;
            
            //This is a dummy update that will be to see if the user is able to manage events.
            [[_auth getAuthenticator] callAPI:[NSString stringWithFormat:@"https://www.googleapis.com/calendar/v3/calendars/%@/events/79uiotmngl52ana82ob7ibhc1s/move", [_auth getEntertainmentCalId]]
                               withHttpMethod:httpMethod_POST
                           postParameterNames:[NSArray arrayWithObjects:@"destination", nil]
                          postParameterValues:[NSArray arrayWithObjects:[NSString stringWithFormat:@"%@",[_auth getEntertainmentCalId]], nil]
                                  requestBody:nil];
            
            _timeLastReqSent = [[NSDate date] timeIntervalSince1970];
        }
        else
        {
            [self getEventsForMonth:[_events getSelectedMonth] :[_events getSelectedYear]];
        }
        _timeLastReqSent = [[NSDate date] timeIntervalSince1970];
    }
}

- (void)onTickForDelay:(NSTimer*)timer
{
    if (_signedIn && _monthNeedsLoaded
        && _timeLastMonthSwitch + 0.1 < [[NSDate date] timeIntervalSince1970])
    {
        _curArrayId = 1;
        if ([_events doesMonthNeedLoaded:_curArrayId])
        {
            [self getEventsForMonth:[_events getSelectedMonth] :[_events getSelectedYear]];
        }
        else
        {
            [_collectionView reloadData];
            [_activityIndicator stopAnimating];
            _screenLocked = NO;
            
            _curArrayId = 2;
            if ([_events doesMonthNeedLoaded:_curArrayId])
            {
                [self getEventsForMonth:[_events getSelectedMonth] :[_events getSelectedYear]];
            }
            else
            {
                _curArrayId = 0;
                if ([_events doesMonthNeedLoaded:_curArrayId])
                {
                    [self getEventsForMonth:[_events getSelectedMonth] :[_events getSelectedYear]];
                }
            }
        }
        
        _monthNeedsLoaded = NO;
    }
}



- (void)applicationWillEnterForeground:(UIApplication *)application
{
    NSLog(@"app will enter foreground");
    
    [super viewDidAppear:YES];
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (void)returnToCalendar
{
    if (_signedIn)
    {
        [self.navigationController popToRootViewControllerAnimated:YES];
        
        NSDate *date = [NSDate date];
        NSDateComponents *dateComponents = [[NSCalendar currentCalendar] components:NSYearCalendarUnit | NSMonthCalendarUnit fromDate:date];
        NSInteger year = [dateComponents year];
        NSInteger month = [dateComponents month];
        
        [_events setYear:(int)year];
        [_events setMonth:(int)month];
        
        [_events resetEvents];
        
        _curArrayId = 1;
        
        [_activityIndicator startAnimating];
        
        [self getEventsForMonth:[_events getSelectedMonth] :[_events getSelectedYear]];
    }
    else
    {
        [self signOutOrSignIn:NULL];
        NSLog(@"returnToCalendar didn't run");
    }
}

- (IBAction)signOutOrSignIn:(id)sender {
    if (_signedIn) {
        // Revoke the access token.
        [[_auth getAuthenticator] revokeAccessToken];
        
        [self setSignedIn:NO];
        
        self.signInOutButton.title = @"Sign In";
        
        _addEventButton.title = @" ";
        _addEventButton.enabled = NO;
        
        _leftArrow.enabled = NO;
        _rightArrow.enabled = NO;
        
        _swipeLeft.enabled = NO;
        _swipeRight.enabled = NO;
        
        _monthLabel.text = @" ";
        
        [_collectionView reloadData];
        
        //Just setting the default.
        [_auth setUserCanManageEvents:NO];
        
        [_auth setAuthCals:[[NSMutableDictionary alloc] initWithObjectsAndKeys:@"NO", @"Academics", @"NO", @"Activities", @"NO", @"Athletics", @"NO", @"Entertainment", @"NO", @"Residence", @"NO", @"Campus Rec", nil]];
        
        //NSLog(@"Signed out we did");
    }

    [self setSignedIn:NO];
    self.signInOutButton.title = @"Sign In";
    
    [_activityIndicator startAnimating];
    
    [[_auth getAuthenticator] authorizeUserWithClienID:@"836202105226-07ulfvopjkp1qpr2f08i8df1rv5ebphs.apps.googleusercontent.com"
                                       andClientSecret:@"M8h6QjrFfVgKQ9slzyU6hO4q"
                                         andParentView:self.view
                                             andScopes:[NSArray arrayWithObject:@"https://www.googleapis.com/auth/calendar"]];
    //NSLog(@"Signed in we did");
}

- (IBAction)radioSelected:(UIButton *)sender {
    Preferences *prefs = [Preferences getSharedInstance];

    switch (sender.tag) {
        case 1:
            [prefs negatePreference:1]; //                              <-- Entertainment
            [_cat1Btn setSelected:[prefs getPreference:1]];
            [_cat1Btn setHighlighted:NO];
            break;
        case 2:
            [prefs negatePreference:2]; //                              <-- Academics
            [_cat2Btn setSelected:[prefs getPreference:2]];
            [_cat2Btn setHighlighted:NO];
            break;
        case 3:
            [prefs negatePreference:3]; //                              <-- Activities
            [_cat3Btn setSelected:[prefs getPreference:3]];
            [_cat3Btn setHighlighted:NO];
            break;
        case 4:
            [prefs negatePreference:4]; //                              <-- Residence
            [_cat4Btn setSelected:[prefs getPreference:4]];
            [_cat4Btn setHighlighted:NO];
            break;
        case 5:
            [prefs negatePreference:5]; //                              <-- Athletics
            [_cat5Btn setSelected:[prefs getPreference:5]];
            [_cat5Btn setHighlighted:NO];
            break;
        case 6:
            [prefs negatePreference:6]; //                              <-- Campus Rec
            [_cat6Btn setSelected:[prefs getPreference:6]];
            [_cat6Btn setHighlighted:NO];
            break;
    }
    
    [_collectionView reloadData];
}

- (IBAction)backMonthOffset:(id)sender {
    if (_authenticating != YES) {
        //NSLog(@"went to previous month, jsons received: %d", _reqsSent);
        _screenLocked = YES;
        
        [_activityIndicator startAnimating];
        
        [_events offsetMonth:-1];
        
        _monthLabel.text = [NSString stringWithFormat:@"%@ %d", [_events getMonthBarDate], [_events getSelectedYear]];
        
        _timeLastMonthSwitch = [[NSDate date] timeIntervalSince1970];
        _monthNeedsLoaded = YES;
    }
}

- (IBAction)forwardMonthOffset:(id)sender {
    if (_authenticating != YES) {
        //NSLog(@"went to next month, jsons received: %d", _reqsSent);
        _screenLocked = YES;
        
        [_activityIndicator startAnimating];
        
        [_events offsetMonth:1];
        
        _monthLabel.text = [NSString stringWithFormat:@"%@ %d", [_events getMonthBarDate], [_events getSelectedYear]];
        
        _timeLastMonthSwitch = [[NSDate date] timeIntervalSince1970];
        _monthNeedsLoaded = YES;
    }
}



- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    int cells;
    
    if (_signedIn && ![_events doesMonthNeedLoaded:1]) {
        cells = 35;
        
        //NSLog(@"The number of cells required:%d", [events getFirstWeekDay] + [events getDaysOfMonth]-1);
        
        if ([_events getFirstWeekDay:1] + [_events getDaysOfMonth]-1 >= 35) {
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
    if (indexPath.row+1 - [_events getFirstWeekDay:1] <= 0) {
        cell = (UICollectionViewCell *)[_collectionView dequeueReusableCellWithReuseIdentifier:@"OtherMonthCell" forIndexPath:indexPath];
        
        UILabel *dayLbl = (UILabel *)[cell viewWithTag:100];
        
        dayLbl.text = [NSString stringWithFormat:@"%d", (int)indexPath.row+1 - [_events getFirstWeekDay:1] + [_events getDaysOfPreviousMonth]];
    }
    //Check to see if this cell is for a day of the next month
    else if (indexPath.row+1 - [_events getFirstWeekDay:1] > [_events getDaysOfMonth]) {
        cell = (UICollectionViewCell *)[_collectionView dequeueReusableCellWithReuseIdentifier:@"OtherMonthCell" forIndexPath:indexPath];
        
        UILabel *dayLbl = (UILabel *)[cell viewWithTag:100];
        
        dayLbl.text = [NSString stringWithFormat:@"%d", (int)indexPath.row+1 - [_events getFirstWeekDay:1] - [_events getDaysOfMonth]];
    }
    else {
        cell = (UICollectionViewCell *)[_collectionView dequeueReusableCellWithReuseIdentifier:@"CurrentDayCell" forIndexPath:indexPath];
        
        UILabel *dayLbl = (UILabel *)[cell viewWithTag:100];
        
        dayLbl.text = [NSString stringWithFormat:@"%d", (int)indexPath.row+1 - [_events getFirstWeekDay:1]];
        
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
        UIView *cat6 = (UIView *)[cell viewWithTag:16];
        if (!cat6.hidden) {
            cat6.hidden = YES;
        }
        
        //This holds the preferences based on the legend at the top.
        Preferences *prefs = [Preferences getSharedInstance];
        
        //Showing relevant category by making the colorful squares not hidden anymore.
        NSArray *dayEvents = [_events getEventsForDay:(int)indexPath.row+1 - [_events getFirstWeekDay:1]];
        
        //Iterate through all events and determine categories that are present.
        for (int i=0; i<[dayEvents count]; i++) {
            //NSString *category = [[dayEvents objectAtIndex:i] objectForKey:@"category"];
            
            //NSLog(@"The event's colorId is %d", [[[dayEvents objectAtIndex:i] objectForKey:@"colorId"] intValue]);
            
            if ([[[dayEvents objectAtIndex:i] objectForKey:@"category"] isEqualToString:@"Entertainment"]) {
                if (cat1.hidden) {
                    //Check to see if this category is selected.
                    if ([prefs getPreference:1]) {
                        cat1.hidden = NO;
                    }
                }
            }
            else if ([[[dayEvents objectAtIndex:i] objectForKey:@"category"] isEqualToString:@"Academics"]) {
                if (cat2.hidden) {
                    //Check to see if this category is selected.
                    if ([prefs getPreference:2]) {
                        cat2.hidden = NO;
                    }
                }
            }
            else if ([[[dayEvents objectAtIndex:i] objectForKey:@"category"] isEqualToString:@"Student Activities"]) {
                if (cat3.hidden) {
                    //Check to see if this category is selected.
                    if ([prefs getPreference:3]) {
                        cat3.hidden = NO;
                    }
                }
            }
            else if ([[[dayEvents objectAtIndex:i] objectForKey:@"category"] isEqualToString:@"Residence Life"]) {
                if (cat4.hidden) {
                    //Check to see if this category is selected.
                    if ([prefs getPreference:4]) {
                        cat4.hidden = NO;
                    }
                }
            }
            else if ([[[dayEvents objectAtIndex:i] objectForKey:@"category"] isEqualToString:@"Warrior Athletics"]) {
                if (cat5.hidden) {
                    //Check to see if this category is selected.
                    if ([prefs getPreference:5]) {
                        cat5.hidden = NO;
                    }
                }
            }
            else if ([[[dayEvents objectAtIndex:i] objectForKey:@"category"] isEqualToString:@"Campus Rec"]) {
                if (cat6.hidden) {
                    //Check to see if this category is selected.
                    if ([prefs getPreference:6]) {
                        cat6.hidden = NO;
                    }
                }
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
        
        [_events setSelectedDay:(int)indexPath.row+1 - [_events getFirstWeekDay:1]];
        
        //NSLog(@"The selected day is %d", (int)indexPath.row+1 - [_events getFirstWeekDay]);
    }
}


- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    BOOL canSegue = YES;
    
    if (_screenLocked) {
        canSegue = NO;
    }
    else if ([identifier isEqualToString:@"CalendarToDayEvents"]) {
        NSArray *indexPaths = [_collectionView indexPathsForSelectedItems];
        NSIndexPath *indexPath = [indexPaths objectAtIndex:0];
        
        //Check to see if this cell is for a day of the previous month
        if (indexPath.row+1 - [_events getFirstWeekDay:1] <= 0) {
            //Offset month if a previous month's cell is clicked
            [self backMonthOffset:nil];
            canSegue = NO;
        }
        //Check to see if this cell is for a day of the next month
        else if (indexPath.row+1 - [_events getFirstWeekDay:1] > [_events getDaysOfMonth]) {
            //Offset month if a future month's cell is clicked
            [self forwardMonthOffset:nil];
            canSegue = NO;
        }
    }
    return canSegue;
}


//This is strictly for locating things like Category: and ShortDesc: within
//  the summary of the.
- (int)getIndexOfSubstringInString:(NSString *)substring :(NSString *)string {
    BOOL substringFound = NO;
    
    int substringStartIndex = -1;
    
    //Iterate through the string to find the first character in the substring.
    for (int i=0; i<[string length]; i++) {
        //Check to see if the substring character has been found.
        if ([string characterAtIndex:i] == [substring characterAtIndex:0]) {
            //If the substring length is greater than the remaining characters in the string,
            //  there is no possible way that the substring exists there (and an exception will be thrown.)
            //Only search for the substring if the remaining chars is >= to the substring length.
            if ([string length] - i >= [substring length]) {
                //Check to see if the following characters in the string are also in the substring.
                //  This can start at 1 because the 0th index of the substring has already been determined
                //  to be in the string.
                for (int j=1; j<[substring length]; j++) {
                    //Check if one the following characters in the substring aren't within the string.
                    if ([string characterAtIndex:i+j] != [substring characterAtIndex:j]) {
                        //If this is true, then i isn't the index of the first character in the substring
                        //  within the string.
                        break;
                    }
                    else {
                        //If this was the very last character in the substring and it's in the string, the
                        //  substring has been found. (The loop stops when it finds a char in the substring that's
                        //  not in the string.)
                        if (j == [substring length]-1) {
                            substringFound = YES;
                            substringStartIndex = i;
                        }
                    }
                }
            }
            //If we've found the substring, we can stop the loop.
            if (substringFound) {
                break;
            }
        }
    }
    
    return substringStartIndex;
}


//This is meant for parsing the summary, pulling out a chunk of information and putting it back
//  into the dictionary under a new key.
//@param eventDict This dictionary represents a single event that was received from Google Calendar's
//  json that will be given to us. The summary exists within this under the "summary" key.
//@param newKey This will be the key for the information that is pulled out of the summary and
//  placed back into the dictionary.
//@param possibleKeys Since human error is bound to happen, these are all the possible keys for
//  the single chunk of information that we're pulling out of the summary and placing back into
//  the dictionary under a new key.
//@return eventDict will be returned, but it will possibly have a new key (or an altered object
//  for a key if the user has permission to change events.)
-(NSDictionary *)parseSummaryForKey:(NSDictionary *)eventDict :(NSString *)newKey :(NSArray *)possibleKeys {
    NSMutableDictionary *dCurrentEvent = [[NSMutableDictionary alloc] initWithDictionary:eventDict];
    
    NSString *summary = [dCurrentEvent objectForKey:@"summary"];
    
    BOOL substringFound = NO;
    int substringStartIndex = 0;
    //This is the length of the key that was found to exist in the summary.
    int foundKeyLength = 0;
    
    //Loop through each possible key looking for the substring.
    //Then we'll break out of the look when it's found.
    for (int i=0; i<[possibleKeys count]; i++) {
        substringStartIndex = [self getIndexOfSubstringInString:[possibleKeys objectAtIndex:i] :summary];
        
        //-1 means a substring wasn't found.
        if (substringStartIndex != -1) {
            substringFound = YES;
            foundKeyLength = (int)[[possibleKeys objectAtIndex:i] length];
            break;
        }
    }
    
    if (substringFound) {
        //This block gets the first word after the "Category:", which is the category.
        NSString *infoWithExtraStuff = [summary substringWithRange:NSMakeRange(substringStartIndex+foundKeyLength,
                                                                               [summary length] - (substringStartIndex+foundKeyLength))];
        NSString *info = [[infoWithExtraStuff componentsSeparatedByString:@";"] objectAtIndex:0];
        
        int trailingSpaces = 0;
        
        //Determine number of trailing spaces, so we can not include them in the category.
        for (int j=(int)[info length]-1; j>=0; j--) {
            if ([info characterAtIndex:j] != ';') {
                break;
            }
            else {
                trailingSpaces += 1;
            }
        }
        
        //Add the category item to the dictionary.
        [dCurrentEvent setObject:[info substringWithRange:NSMakeRange(0, [info length] - trailingSpaces)]
                          forKey:newKey];
    }
    else {
        //If none of the possible keys were valid, then we can just assume say that there's
        //  no category and move on essentially.
        [dCurrentEvent setObject:@"N/A" forKey:newKey];
    }
    
    return (NSDictionary *)dCurrentEvent;
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
    if (month+(_curArrayId-1) == 0)
    {
        _firstDateOfMonth = [self returnDateForMonth:12 year:year-1 day:1];
        _lastDateOfMonth = [self returnDateForMonth:13 year:year-1 day:0];
    }
    else if (month+(_curArrayId-1) == 13)
    {
        _firstDateOfMonth = [self returnDateForMonth:1 year:year+1 day:1];
        _lastDateOfMonth = [self returnDateForMonth:2 year:year+1 day:0];
    }
    else
    {
        _firstDateOfMonth = [self returnDateForMonth:month+(_curArrayId-1) year:year day:1];
        _lastDateOfMonth = [self returnDateForMonth:month+1+(_curArrayId-1) year:year day:0];
    }
    
    //NSLog(@"Getting events for selected month, month:%@, year:%@", [self toStringFromDateTime:firstDateOfMonth], [self toStringFromDateTime:lastDateOfMonth]);
    
    //_start = [NSDate date];
    
    if (_reqsSent != 0) {
        _jsonsToIgnore = 1;
    }
    else if ([_events doesMonthNeedLoaded:_curArrayId])
    {
        if (_curArrayId == 1)
        {
            _screenLocked = YES;
        }
        
        // If user authorization is successful, then make an API call to get the event list for the current month.
        // For more infomation about this API call, visit:
        // https://developers.google.com/google-apps/calendar/v3/reference/calendarList/list
        
        [[_auth getAuthenticator] callAPI:[NSString stringWithFormat:@"https://www.googleapis.com/calendar/v3/calendars/%@/events", [_auth getActivitiesCalId]]
                           withHttpMethod:httpMethod_GET
                       postParameterNames:[NSArray arrayWithObjects:@"timeMax", @"timeMin", nil]
                      postParameterValues:[NSArray arrayWithObjects:[self toStringFromDateTime:_lastDateOfMonth], [self toStringFromDateTime:_firstDateOfMonth], nil]
                              requestBody:nil];
        
        [[_auth getAuthenticator] callAPI:[NSString stringWithFormat:@"https://www.googleapis.com/calendar/v3/calendars/%@/events", [_auth getEntertainmentCalId]]
                           withHttpMethod:httpMethod_GET
                       postParameterNames:[NSArray arrayWithObjects:@"timeMax", @"timeMin", nil]
                      postParameterValues:[NSArray arrayWithObjects:[self toStringFromDateTime:_lastDateOfMonth], [self toStringFromDateTime:_firstDateOfMonth], nil]
                              requestBody:nil];
        
        [[_auth getAuthenticator] callAPI:[NSString stringWithFormat:@"https://www.googleapis.com/calendar/v3/calendars/%@/events", [_auth getResidenceCalId]]
                           withHttpMethod:httpMethod_GET
                       postParameterNames:[NSArray arrayWithObjects:@"timeMax", @"timeMin", nil]
                      postParameterValues:[NSArray arrayWithObjects:[self toStringFromDateTime:_lastDateOfMonth], [self toStringFromDateTime:_firstDateOfMonth], nil]
                              requestBody:nil];
        
        [[_auth getAuthenticator] callAPI:[NSString stringWithFormat:@"https://www.googleapis.com/calendar/v3/calendars/%@/events", [_auth getAthleticsCalId]]
                           withHttpMethod:httpMethod_GET
                       postParameterNames:[NSArray arrayWithObjects:@"timeMax", @"timeMin", nil]
                      postParameterValues:[NSArray arrayWithObjects:[self toStringFromDateTime:_lastDateOfMonth], [self toStringFromDateTime:_firstDateOfMonth], nil]
                              requestBody:nil];
        
        [[_auth getAuthenticator] callAPI:[NSString stringWithFormat:@"https://www.googleapis.com/calendar/v3/calendars/%@/events", [_auth getAcademicsCalId]]
                           withHttpMethod:httpMethod_GET
                       postParameterNames:[NSArray arrayWithObjects:@"timeMax", @"timeMin", nil]
                      postParameterValues:[NSArray arrayWithObjects:[self toStringFromDateTime:_lastDateOfMonth], [self toStringFromDateTime:_firstDateOfMonth], nil]
                              requestBody:nil];
        
        [[_auth getAuthenticator] callAPI:[NSString stringWithFormat:@"https://www.googleapis.com/calendar/v3/calendars/%@/events", [_auth getCampusRecCalId]]
                           withHttpMethod:httpMethod_GET
                       postParameterNames:[NSArray arrayWithObjects:@"timeMax", @"timeMin", nil]
                      postParameterValues:[NSArray arrayWithObjects:[self toStringFromDateTime:_lastDateOfMonth], [self toStringFromDateTime:_firstDateOfMonth], nil]
                              requestBody:nil];
        
        _timeLastReqSent = [[NSDate date] timeIntervalSince1970];
        
        _reqsSent += 1;
    }
    else
    {
        _reqsSent = 0;
        if (_curArrayId == 1)
        {
            [_collectionView reloadData];
            [_activityIndicator stopAnimating];
            _screenLocked = NO;
            
            _curArrayId = 2;
             if ([_events doesMonthNeedLoaded:_curArrayId])
             {
                [self getEventsForMonth:[_events getSelectedMonth] :[_events getSelectedYear]];
             }
             else
             {
                 _curArrayId = 0;
                 if ([_events doesMonthNeedLoaded:_curArrayId])
                 {
                     [self getEventsForMonth:[_events getSelectedMonth] :[_events getSelectedYear]];
                 }
             }
        }
        else if (_curArrayId == 2)
        {
            _curArrayId = 0;
            if ([_events doesMonthNeedLoaded:_curArrayId])
            {
                [self getEventsForMonth:[_events getSelectedMonth] :[_events getSelectedYear]];
            }
        }
    }
}


#pragma mark - GoogleOAuth class delegate method implementation

-(void)authorizationWasSuccessful {
    //If we reach this point and the user is not signed in, that means the user just signed in or out.
    //The problem is that when we go to sign out, an empty json is sent after we've already set _signedIn to No.
    //  So we'll just ignore cases when we get an empty json file while we're signed out.
    //  This won't be triggered while we're signed in and getting empty json strings for empty months.
    if (!_signedIn) {
        [self setSignedIn:YES];
        
        _leftArrow.enabled = YES;
        _rightArrow.enabled = YES;
        
        _swipeLeft.enabled = YES;
        _swipeRight.enabled = YES;
        
        self.signInOutButton.title = @"Sign Out";
        
        _authenticating = YES;
        
        _screenLocked = YES;
        
        NSDate *date = [NSDate date];
        NSDateComponents *dateComponents = [[NSCalendar currentCalendar] components:NSYearCalendarUnit | NSMonthCalendarUnit fromDate:date];
        NSInteger year = [dateComponents year];
        NSInteger month = [dateComponents month];
        
        [_events setYear:(int)year];
        [_events setMonth:(int)month];
        
        [_events resetEvents];
        
        _reqsSent += 1;
        
        //This is a dummy update that will be to see if the user is able to manage events.
        [[_auth getAuthenticator] callAPI:[NSString stringWithFormat:@"https://www.googleapis.com/calendar/v3/calendars/%@/events/79uiotmngl52ana82ob7ibhc1s/move", [_auth getEntertainmentCalId]]
                           withHttpMethod:httpMethod_POST
                       postParameterNames:[NSArray arrayWithObjects:@"destination", nil]
                      postParameterValues:[NSArray arrayWithObjects:[NSString stringWithFormat:@"%@",[_auth getEntertainmentCalId]], nil]
                              requestBody:nil];

        _timeLastReqSent = [[NSDate date] timeIntervalSince1970];
    }
    //NSLog(@"Getting the events for the current month");
}

-(void)responseFromServiceWasReceived:(NSString *)responseJSONAsString andResponseJSONAsData:(NSData *)responseJSONAsData {
    NSError *error;
    
    NSLog(@"json incoming");
    //NSLog(@"%@",responseJSONAsString);
    
    if (_signedIn)
    {
        if ([responseJSONAsString rangeOfString:@"calendar#events"].location != NSNotFound) {
            //NSLog(@"%@",responseJSONAsString);
            //NSLog(@"%@",responseJSONAsString);
            // Get the JSON data as a dictionary.
            NSDictionary *eventsInfoDict = [NSJSONSerialization JSONObjectWithData:responseJSONAsData options:NSJSONReadingMutableContainers error:&error];
            
            if (_jsonsToIgnore != 0) {
                _jsonsToIgnore -= 1;
                //NSLog(@"reqsSent and one being ignored, %d", _reqsSent);
                _reqsSent = 0;
                
                [_events resetEvents];

                _curArrayId = 1;
                [self getEventsForMonth:[_events getSelectedMonth] :[_events getSelectedYear]];
            }
            else if (error) {
                // This is the case that an error occured during converting JSON data to dictionary.
                // Simply log the error description.
                //NSLog(@"%@", [error localizedDescription]);
            }
            else{
                //Get the events as an array
                NSArray *eventsInfo = [eventsInfoDict objectForKey:@"items"];
                
                //NSLog(@"Putting the events into _calendarEvents.");
                
                NSString *category = @"";
                
                //NSLog(@"Jsons previously received: %d", _jsonsReceived);
                
                BOOL expectedJsonReceived = YES;
                
                if (_reqsSent == 1) {
                    if ([self getIndexOfSubstringInString:@"Entertainment" :eventsInfoDict[@"summary"]] != -1) {
                        //Only refresh the events if this is the first json received.
                        [_events refreshArrayOfEvents:_curArrayId];
                        category = @"Entertainment";
                        //NSLog(@"Refresh events");
                    }
                    else {
                        expectedJsonReceived = NO;
                    }
                }
                else if (_reqsSent == 2) {
                    if ([self getIndexOfSubstringInString:@"Academics" :eventsInfoDict[@"summary"]] != -1) {
                        category = @"Academics";
                    }
                    else {
                        expectedJsonReceived = NO;
                    }
                }
                else if (_reqsSent == 3) {
                    if ([self getIndexOfSubstringInString:@"Activities" :eventsInfoDict[@"summary"]] != -1) {
                        category = @"Student Activities";
                    }
                    else {
                        expectedJsonReceived = NO;
                    }
                }
                else if (_reqsSent == 4) {
                    if ([self getIndexOfSubstringInString:@"Residence Life" :eventsInfoDict[@"summary"]] != -1) {
                        category = @"Residence Life";
                    }
                    else {
                        expectedJsonReceived = NO;
                    }
                }
                else if (_reqsSent == 5) {
                    if ([self getIndexOfSubstringInString:@"Athletics" :eventsInfoDict[@"summary"]] != -1) {
                        category = @"Warrior Athletics";
                    }
                    else {
                        expectedJsonReceived = NO;
                    }
                }
                else if (_reqsSent == 6) {
                    if ([self getIndexOfSubstringInString:@"Campus Recreation" :eventsInfoDict[@"summary"]] != -1) {
                        category = @"Campus Rec";
                    }
                    else {
                        expectedJsonReceived = NO;
                    }
                }
                
                if (expectedJsonReceived)
                {
                    if (_curArrayId == 1)
                    {
                        _monthLabel.text = [NSString stringWithFormat:@"%@ %d", [_events getMonthBarDate], [_events getSelectedYear]];
                    }
                    
                    int selectedMonth = [_events getSelectedMonth] + (_curArrayId-1);
                    int selectedYear = [_events getSelectedYear];
                    
                    if (selectedMonth == 0)
                    {
                        selectedMonth = 12;
                        selectedYear -= 1;
                    }
                    else if (selectedMonth == 13)
                    {
                        selectedMonth = 1;
                        selectedYear += 1;
                    }
                    
                    //Loop through the events
                    for (int i=0; i<[eventsInfo count]; i++) {
                        //Now we must parse the summary and alter the dictionary so that it can be
                        //  used in the rest of the program easier. So we'll call parseSummaryForKey in this class
                        //  to pull info out of the Summary field in the Dictionary and place
                        //  it back into the dictionary mapped to a new key.
                        
                        NSMutableDictionary *currentEventInfo = [[NSMutableDictionary alloc] initWithDictionary:[eventsInfo objectAtIndex:i]];
                        
                        [currentEventInfo setObject:category forKey:@"category"];
                        
                        //NSLog(@"%@", currentEventInfo);
                        
                        int startDay = 0;
                        int startMonth = 0;
                        int startYear = 0;
                        
                        int endDay = 0;
                        
                        //Determine if the event isn't an all day event type.
                        if ([[currentEventInfo objectForKey:@"start"] objectForKey:@"dateTime"] != nil) {
                            startDay = (int)[[[[currentEventInfo objectForKey:@"start"]
                                          objectForKey:@"dateTime"]
                                         substringWithRange:NSMakeRange(8, 2)]
                                        integerValue];
                            
                            startMonth = [[currentEventInfo[@"start"][@"dateTime"] substringWithRange:NSMakeRange(5, 2)] intValue];
                            
                            startYear = [[currentEventInfo[@"start"][@"dateTime"] substringWithRange:NSMakeRange(0, 4)] intValue];
                            
                            //The endDay must not be the day of the month that it is on, but the number of days from the first day
                            //  of the startMonth.
                            if (startYear == [[currentEventInfo[@"end"][@"dateTime"] substringWithRange:NSMakeRange(0, 4)] intValue]) {
                                for (int month=startMonth; month<[[currentEventInfo[@"end"][@"dateTime"] substringWithRange:NSMakeRange(5, 2)] intValue]; month++) {
                                    endDay += [_events getDaysOfMonth:month :startYear];
                                }
                                //Account for days in endMonth
                                endDay += [[[[currentEventInfo objectForKey:@"end"]
                                             objectForKey:@"dateTime"]
                                            substringWithRange:NSMakeRange(8, 2)]
                                           integerValue];
                            }
                            else {
                                //At the very beginning we'll be working with probably not a full year.
                                for (int month=startMonth; month<13; month++) {
                                    endDay += [_events getDaysOfMonth:month :startYear];
                                }
                                
                                //Start by accounting for year differences.
                                for (int year=startYear+1; year<[[currentEventInfo[@"end"][@"dateTime"] substringWithRange:NSMakeRange(0, 4)] intValue]+1; year++) {
                                    int endMonth = 12;
                                    //This makes sure that we stop on the month prior to the selected month
                                    //  and then add in the days for that month.
                                    if (year == [[currentEventInfo[@"end"][@"dateTime"] substringWithRange:NSMakeRange(0, 4)] intValue]) {
                                        endMonth = [[currentEventInfo[@"end"][@"dateTime"] substringWithRange:NSMakeRange(5, 2)] intValue]-1;
                                        //Account for days in endMonth
                                        endDay += [[[[currentEventInfo objectForKey:@"end"]
                                                     objectForKey:@"dateTime"]
                                                    substringWithRange:NSMakeRange(8, 2)]
                                                   integerValue];
                                    }
                                    
                                    //This only takes into account full months strictly inbetween the start and end months.
                                    for (int month=1; month<endMonth+1; month++) {
                                        endDay += [_events getDaysOfMonth:month :year];
                                    }
                                }
                            }
                        }
                        else if ([[currentEventInfo objectForKey:@"start"] objectForKey:@"date"] != nil) {
                            startDay = (int)[[[[currentEventInfo objectForKey:@"start"]
                                          objectForKey:@"date"]
                                         substringWithRange:NSMakeRange(8, 2)]
                                        integerValue];
                            
                            startMonth = [[currentEventInfo[@"start"][@"date"] substringWithRange:NSMakeRange(5, 2)] intValue];
                            
                            startYear = [[currentEventInfo[@"start"][@"date"] substringWithRange:NSMakeRange(0, 4)] intValue];
                            
                            //The endDay must not be the day of the month that it is on, but the number of days from the first day
                            //  of the startMonth.
                            if (startYear == [[currentEventInfo[@"end"][@"date"] substringWithRange:NSMakeRange(0, 4)] intValue]) {
                                for (int month=startMonth; month<[[currentEventInfo[@"end"][@"date"] substringWithRange:NSMakeRange(5, 2)] intValue]; month++) {
                                    endDay += [_events getDaysOfMonth:month :startYear];
                                }
                                //Account for days in endMonth
                                endDay += [[[[currentEventInfo objectForKey:@"end"]
                                             objectForKey:@"date"]
                                            substringWithRange:NSMakeRange(8, 2)]
                                           integerValue];
                            }
                            else {
                                //At the very beginning we'll be working with probably not a full year.
                                for (int month=startMonth; month<13; month++) {
                                    endDay += [_events getDaysOfMonth:month :startYear];
                                }
                                
                                //Start by accounting for year differences.
                                for (int year=startYear+1; year<[[currentEventInfo[@"end"][@"date"] substringWithRange:NSMakeRange(0, 4)] intValue]+1; year++) {
                                    int endMonth = 12;
                                    //This makes sure that we stop on the month prior to the selected month
                                    //  and then add in the days for that month.
                                    if (year == [[currentEventInfo[@"end"][@"date"] substringWithRange:NSMakeRange(0, 4)] intValue]) {
                                        endMonth = [[currentEventInfo[@"end"][@"date"] substringWithRange:NSMakeRange(5, 2)] intValue]-1;
                                        //Account for days in endMonth
                                        endDay += [[[[currentEventInfo objectForKey:@"end"]
                                                     objectForKey:@"date"]
                                                    substringWithRange:NSMakeRange(8, 2)]
                                                   integerValue];
                                    }
                                    
                                    //This only takes into account full months strictly inbetween the start and end months.
                                    for (int month=1; month<endMonth+1; month++) {
                                        endDay += [_events getDaysOfMonth:month :year];
                                    }
                                }
                            }
                            //This makes the end day exclusive! As per the google calendar's standard.
                            endDay -= 1;
                        }
                        else if ([[currentEventInfo objectForKey:@"status"] isEqualToString:@"cancelled"])
                        {
                            continue;
                        }
                        else
                        {
                            continue;
                        }
                        
                        float freq = 1.0;
                        int repeat = 1;
                        
                        //If an event is reocurring, then we must account for that.
                        if ([currentEventInfo objectForKey:@"recurrence"] != nil) {
                            //NSLog(@"recurrence: %@", currentEventInfo[@"recurrence"][0]);
                            
                            //The beginning of the substring that represents the freq of the recurrence.
                            int freqSubstringIndx = 11;
                            
                            //Thankfully there is only one semicolon in the string. So we use that to find the length of the frequency.
                            int freqLen = (int)[currentEventInfo[@"recurrence"][0] rangeOfString:@";"].location;
                            
                            freqLen -= freqSubstringIndx;
                            
                            //This will prevent any problems regarding the recurrence value.
                            //  Events that repeat forever will not be usable.
                            if (freqLen <= 250) {
                                NSString *frequency = [currentEventInfo[@"recurrence"][0] substringWithRange:NSMakeRange(freqSubstringIndx, freqLen)];
                                
                                //This 6 offsets the index so that it represents the beginning of the date we want.
                                int untilSubstringIndx = [self getIndexOfSubstringInString:@"UNTIL=":currentEventInfo[@"recurrence"][0]];
                                
                                if ([frequency isEqualToString:@"DAILY"]) {
                                    freq = 1.0;
                                }
                                else if ([frequency isEqualToString:@"WEEKLY"]) {
                                    freq = 7.0;
                                }
                                else if ([frequency isEqualToString:@"MONTHLY"]) {
                                    freq = 31;
                                }
                                else if ([frequency isEqualToString:@"YEARLY"]) {
                                    freq = 365;
                                }
                                
                                
                                
                                if (freq == 31) {
                                    //Count the months between the start day and end day.
                                    if (startYear == selectedYear) {
                                        for (int month=startMonth; month<selectedMonth; month++) {
                                            repeat += 1;
                                        }
                                    }
                                    else {
                                        //At the very beginning we'll be working with probably not a full year.
                                        for (int month=startMonth; month<13; month++) {
                                            repeat += 1;
                                        }
                                        
                                        //Start by accounting for year differences.
                                        for (int year=startYear+1; year<[_events getSelectedYear]+1; year++) {
                                            int endMonth = 12;
                                            //This makes sure that we stop on the month prior to the selected month
                                            //  and then add in the days for that month.
                                            if (year == selectedYear) {
                                                endMonth = selectedMonth-1;
                                            }
                                            //This only takes into account full months strictly inbetween the start and end months.
                                            for (int month=1; month<endMonth+1; month++) {
                                                repeat += 1;
                                            }
                                        }
                                    }
                                }
                                else if (freq == 365) {
                                    if (startYear != selectedYear){
                                        for (int year=startYear; year<selectedYear; year++) {
                                            repeat += 1;
                                        }
                                    }
                                }
                                else if (untilSubstringIndx != -1) {
                                    //In here we'll determine the number of ocurrences.
                                    
                                    untilSubstringIndx += 6;
                                    //Get the until substring
                                    NSString *untilString = [currentEventInfo[@"recurrence"][0] substringFromIndex:untilSubstringIndx];
                                    
                                    //Determine if the start and end are within the selected month.
                                    if (startYear == [[untilString substringWithRange:NSMakeRange(0,4)] intValue]
                                        && startMonth == [[untilString substringWithRange:NSMakeRange(4,2)] intValue]
                                        && startYear == selectedYear
                                        && startMonth == selectedMonth) {
                                        repeat = (([[untilString substringWithRange:NSMakeRange(6,2)] intValue] - startDay)/freq) + 1;
                                    }
                                    //If they aren't then we need to determine the amount of days between the start and end.
                                    else {
                                        //Add up all of the days for the months inbetween the start and end. Then do the same formula to calculate the repeat.
                                        
                                        //We know that at least the startMonth is not within the selected month.
                                        
                                        //These days is just the length from start to finish no matter if there are some holes in the middle.
                                        float daysInEventDuration = 0.0;
                                        
                                        if (startYear == selectedYear) {
                                            //Account for days in startMonth
                                            daysInEventDuration += [_events getDaysOfMonth:startMonth :startYear]-startDay+1;
                                            
                                            if (selectedMonth < [[untilString substringWithRange:NSMakeRange(4,2)] intValue]) {
                                                for (int month=startMonth+1; month<[_events getSelectedMonth]+1; month++) {
                                                    daysInEventDuration += [_events getDaysOfMonth:month :startYear];
                                                }
                                            }
                                            else {
                                                for (int month=startMonth+1; month<[_events getSelectedMonth]; month++) {
                                                    daysInEventDuration += [_events getDaysOfMonth:month :startYear];
                                                }
                                                //Account for days in endMonth
                                                daysInEventDuration += [[untilString substringWithRange:NSMakeRange(6,2)] intValue];
                                            }
                                        }
                                        else {
                                            //Account for days in startMonth
                                            daysInEventDuration += [_events getDaysOfMonth:startMonth :startYear]-startDay+1;
                                            
                                            //At the very beginning we'll be working with probably not a full year.
                                            for (int month=startMonth+1; month<13; month++) {
                                                daysInEventDuration += [_events getDaysOfMonth:month :startYear];
                                            }
                                            
                                            //Start by accounting for year differences.
                                            for (int year=startYear+1; year<[_events getSelectedYear]+1; year++) {
                                                int endMonth = 12;
                                                //This makes sure that we stop on the month prior to the selected month
                                                //  and then add in the days for that month.
                                                if (year == selectedYear) {
                                                    endMonth = selectedMonth-1;
                                                    //Account for days in endMonth
                                                    daysInEventDuration += [[untilString substringWithRange:NSMakeRange(6,2)] intValue];
                                                }
                                                
                                                //This only takes into account full months strictly inbetween the start and end months.
                                                for (int month=1; month<endMonth+1; month++) {
                                                    daysInEventDuration += [_events getDaysOfMonth:month :year];
                                                }
                                            }
                                        }
                                        
                                        repeat = (daysInEventDuration / freq) + 1;
                                        
                                        //NSLog(@"The repeat number is %d", repeat);
                                    }
                                }
                                int substringIndx = [self getIndexOfSubstringInString:@"INTERVAL=":currentEventInfo[@"recurrence"][0]];
                                if (substringIndx != -1)
                                {
                                    NSString *substring = [currentEventInfo[@"recurrence"][0] substringFromIndex:substringIndx+9];
                                    substringIndx = [self getIndexOfSubstringInString:@";":currentEventInfo[@"recurrence"][0]];
                                    if (substringIndx == -1)
                                    {
                                        substringIndx = [substring length];
                                    }
                                    freq *= [[substring substringWithRange:NSMakeRange(0,substringIndx)] intValue];
                                }
                            }
                        }
                        
                        //This will hold the number of days into the next month.
                        int wrappedDays = endDay-[_events getDaysOfMonth:startMonth :startYear];

                        //The e variable isn't being set properly. So fix it!
                        
                        int s = 0;
                        int e = 0;
                        
                        //The outer loop loops through the reocurrences.
                        for (int rep=0; rep<repeat; rep++) {
                            BOOL iterateOverDays = YES;
                            
                            //Are we dealing with a monthly repeat?
                            if (freq >= 28 && freq <= 31) {
                                freq = [_events getDaysOfMonth:startMonth :startYear];
                            }
                            else if (freq >= 365 && freq <= 366) {
                                if (startYear % 4 == 0) {
                                    freq = 366;
                                }
                                else {
                                    freq = 365;
                                }
                            }

                            
                            //Here we setup the s and e variables for the for loop.
                            if (startYear == selectedYear) {
                                //The startMonth is with respect to the startDay. The endDay quite possible
                                //  can be going into the next month.
                                if (startMonth == selectedMonth) {
                                    s = startDay;
                                    
                                    //Check if the endDay will be moving into the next month.
                                    if (endDay > [_events getDaysOfMonth:startMonth :startYear]) {
                                        e = [_events getDaysOfMonth:startMonth :startYear];
                                    }
                                    else {
                                        e = endDay;
                                    }
                                }
                                //Check if the startMonth is the previous month and the endDay will roll over into the next month.
                                else if (startMonth + 1 == selectedMonth
                                         && endDay > [_events getDaysOfMonth:startMonth :startYear]) {
                                    //We don't care about the days in the previous month, only that
                                    //  the rolled over days are going to be in the selected month.
                                    s = 1;
                                    
                                    //endDay is for sure going to be above the daysInMonth.
                                    e = endDay%[_events getDaysOfMonth:startMonth :startYear];
                                }
                                else {
                                    //We'll skip this iterating, because we won't add anything.
                                    iterateOverDays = NO;
                                }
                            }
                            else if (startYear == selectedYear-1
                                     && startMonth == 12
                                     && endDay > [_events getDaysOfMonth:startMonth :startYear]) {
                                //We don't care about the days in the previous month, only that
                                //  the rolled over days are going to be in the selected month.
                                s = 1;
                                
                                //endDay is for sure going to be above the daysInMonth.
                                e = endDay%[_events getDaysOfMonth:startMonth :startYear];
                            }
                            else {
                                //We'll skip this iterating, because we won't add anything.
                                iterateOverDays = NO;
                            }
                            if (iterateOverDays) {
                                //Add events for the startday all the way up to the end day.
                                for (int day=s; day<e+1; day++) {
                                    if (day != 0) {
                                        //This then uses that day as an index and inserts the currentEvent into that indice's array.
                                        [_events AppendEvent:day :currentEventInfo :_curArrayId];
                                    }
                                }
                            }
                            
                            //Setup the start and end vars for the next repeat.
                            startDay = startDay + freq;
                            
                            endDay = endDay + freq;
                            
                            BOOL nextDateUpdated = NO;
                            
                            while (!nextDateUpdated)
                            {
                                //Check if we're moving into a new month.
                                if (startDay%[_events getDaysOfMonth:startMonth :startYear] < startDay) {
                                    //Then we mod the startDay to get the day of the next month it will be on.
                                    startDay = startDay-[_events getDaysOfMonth:startMonth :startYear];
                                    endDay = endDay-[_events getDaysOfMonth:startMonth :startYear];
                                    startMonth += 1;
                                    
                                    //Check to see if we transitioned to a new year.
                                    if (startMonth > 12) {
                                        startMonth = 1;
                                        startYear += 1;
                                    }
                                    if (wrappedDays > 0) {
                                        if (startMonth != 1) {
                                            endDay += [_events getDaysOfMonth:startMonth :startYear] - [_events getDaysOfMonth:startMonth-1 :startYear];
                                        }
                                        else {
                                            endDay += [_events getDaysOfMonth:startMonth :startYear] - [_events getDaysOfMonth:12 :startYear-1];
                                        }
                                    }
                                }
                                else
                                {
                                    nextDateUpdated = YES;
                                }
                            }
                        }
                        /*
                        //Alternative method for adding monthly events to the calendar.
                        else if ([otherRepeatType isEqualToString:@"MONTHLY"]) {
                            int untilSubstringIndx = [self getIndexOfSubstringInString:@"UNTIL=":currentEventInfo[@"recurrence"][0]] + 6;
                            NSString *untilString = [currentEventInfo[@"recurrence"][0] substringFromIndex:untilSubstringIndx];
                            
                            if ([_events getSelectedMonth] > [[untilString substringWithRange:NSMakeRange(4,2)] intValue]) {
                                for (int day=startDay; day<endDay+1; day++) {
                                    //This then uses that day as an index and inserts the currentEvent into that indice's array.
                                    [_events AppendEvent:day :currentEventInfo];
                                }
                            }
                        }
                        //Alternative method for adding yearly events to the calendar.
                        else if ([otherRepeatType isEqualToString:@"YEARLY"]) {
                            
                        }
                        */
                    }
                    //NSLog(@"These are our calendar events: %@",_calendarEvents);
                    
                    //if (_reqsSent == 4 || _reqsSent == 5) {_reqsSent += 1;}
                    //if (_reqsSent == 4 || _reqsSent == 5) {_reqsSent += 1;}
                    
                    if (_reqsSent == 6) {
                        //This is a performance test for how long it took to make the 6 http requests!
                        //NSDate *methodFinish = [NSDate date];
                        //NSTimeInterval executionTime = [methodFinish timeIntervalSinceDate:_start];
                        //NSLog(@"%f is the time it took to make the calls.", executionTime);
                        
                        _reqsSent = 0;
                        if (_curArrayId == 1)
                        {
                            [_collectionView reloadData];
                            [_activityIndicator stopAnimating];
                            _screenLocked = NO;
                            
                            _curArrayId = 2;
                            if ([_events doesMonthNeedLoaded:_curArrayId])
                            {
                                [self getEventsForMonth:[_events getSelectedMonth] :[_events getSelectedYear]];
                            }
                            else
                            {
                                _curArrayId = 0;
                                if ([_events doesMonthNeedLoaded:_curArrayId])
                                {
                                    [self getEventsForMonth:[_events getSelectedMonth] :[_events getSelectedYear]];
                                }
                            }
                        }
                        else if (_curArrayId == 2)
                        {
                            _curArrayId = 0;
                            if ([_events doesMonthNeedLoaded:_curArrayId])
                            {
                                [self getEventsForMonth:[_events getSelectedMonth] :[_events getSelectedYear]];
                            }
                        }
                    }
                    else {
                        
                        
                        if (_reqsSent == 1) {
                            // If user authorization is successful, then make an API call to get the event list for the current month.
                            // For more infomation about this API call, visit:
                            // https://developers.google.com/google-apps/calendar/v3/reference/calendarList/list
                            [[_auth getAuthenticator] callAPI:[NSString stringWithFormat:@"https://www.googleapis.com/calendar/v3/calendars/%@/events", [_auth getAcademicsCalId]]
                                               withHttpMethod:httpMethod_GET
                                           postParameterNames:[NSArray arrayWithObjects:@"timeMax", @"timeMin", nil]
                                          postParameterValues:[NSArray arrayWithObjects:[self toStringFromDateTime:_lastDateOfMonth], [self toStringFromDateTime:_firstDateOfMonth], nil]
                                                  requestBody:nil];
                        }
                        else if(_reqsSent == 2) {
                            // If user authorization is successful, then make an API call to get the event list for the current month.
                            // For more infomation about this API call, visit:
                            // https://developers.google.com/google-apps/calendar/v3/reference/calendarList/list
                            [[_auth getAuthenticator] callAPI:[NSString stringWithFormat:@"https://www.googleapis.com/calendar/v3/calendars/%@/events", [_auth getActivitiesCalId]]
                                               withHttpMethod:httpMethod_GET
                                           postParameterNames:[NSArray arrayWithObjects:@"timeMax", @"timeMin", nil]
                                          postParameterValues:[NSArray arrayWithObjects:[self toStringFromDateTime:_lastDateOfMonth], [self toStringFromDateTime:_firstDateOfMonth], nil]
                                                  requestBody:nil];
                        }
                        else if (_reqsSent == 3) {
                            // If user authorization is successful, then make an API call to get the event list for the current month.
                            // For more infomation about this API call, visit:
                            // https://developers.google.com/google-apps/calendar/v3/reference/calendarList/list
                            [[_auth getAuthenticator] callAPI:[NSString stringWithFormat:@"https://www.googleapis.com/calendar/v3/calendars/%@/events", [_auth getResidenceCalId]]
                                               withHttpMethod:httpMethod_GET
                                           postParameterNames:[NSArray arrayWithObjects:@"timeMax", @"timeMin", nil]
                                          postParameterValues:[NSArray arrayWithObjects:[self toStringFromDateTime:_lastDateOfMonth], [self toStringFromDateTime:_firstDateOfMonth], nil]
                                                  requestBody:nil];
                        }
                        else if(_reqsSent == 4) {
                            // If user authorization is successful, then make an API call to get the event list for the current month.
                            // For more infomation about this API call, visit:
                            // https://developers.google.com/google-apps/calendar/v3/reference/calendarList/list
                            [[_auth getAuthenticator] callAPI:[NSString stringWithFormat:@"https://www.googleapis.com/calendar/v3/calendars/%@/events", [_auth getAthleticsCalId]]
                                               withHttpMethod:httpMethod_GET
                                           postParameterNames:[NSArray arrayWithObjects:@"timeMax", @"timeMin", nil]
                                          postParameterValues:[NSArray arrayWithObjects:[self toStringFromDateTime:_lastDateOfMonth], [self toStringFromDateTime:_firstDateOfMonth], nil]
                                                  requestBody:nil];
                        }
                        else if(_reqsSent == 5) {
                            // If user authorization is successful, then make an API call to get the event list for the current month.
                            // For more infomation about this API call, visit:
                            // https://developers.google.com/google-apps/calendar/v3/reference/calendarList/list
                            [[_auth getAuthenticator] callAPI:[NSString stringWithFormat:@"https://www.googleapis.com/calendar/v3/calendars/%@/events", [_auth getCampusRecCalId]]
                                               withHttpMethod:httpMethod_GET
                                           postParameterNames:[NSArray arrayWithObjects:@"timeMax", @"timeMin", nil]
                                          postParameterValues:[NSArray arrayWithObjects:[self toStringFromDateTime:_lastDateOfMonth], [self toStringFromDateTime:_firstDateOfMonth], nil]
                                                  requestBody:nil];
                        }
                        _timeLastReqSent = [[NSDate date] timeIntervalSince1970];
                        _reqsSent += 1;
                    }
                }
                else
                {
                    //Reset variables
                    _jsonsToIgnore = 0;
                    _reqsSent = 0;
                    
                    [_events resetEvents];
                    
                    _curArrayId = 1;
                    
                    [self getEventsForMonth:[_events getSelectedMonth] :[_events getSelectedYear]];
                }
            }
        }
        //This type of json is retrieved if an update was made to an event (currently only for authenticating.)
        else if ([responseJSONAsString rangeOfString:@"calendar#event"].location != NSNotFound) {
            [_auth setUserCanManageEvents:YES];

            _addEventButton.title = @"Add Event";
            _addEventButton.enabled = YES;
            
            if (_reqsSent == 6) {
                _reqsSent = 0;
                _authenticating = NO;
                [[_auth getAuthCals] setObject:@"YES" forKey:@"Campus Rec"];
                _curArrayId = 1;
                //NSLog(@"The user can manage Campus Rec events!");
                [self getEventsForMonth:[_events getSelectedMonth] :[_events getSelectedYear]];
            }
            else {
                if (_reqsSent == 1) {
                    // If user authorization is successful, then make an API call to get the event list for the current month.
                    // For more infomation about this API call, visit:
                    // https://developers.google.com/google-apps/calendar/v3/reference/calendarList/list
                    [[_auth getAuthenticator] callAPI:[NSString stringWithFormat:@"https://www.googleapis.com/calendar/v3/calendars/%@/events/2krf6iakqog30751k9skgrsj6c/move", [_auth getAcademicsCalId]]
                                       withHttpMethod:httpMethod_POST
                                   postParameterNames:[NSArray arrayWithObjects:@"destination", nil]
                                  postParameterValues:[NSArray arrayWithObjects:[NSString stringWithFormat:@"%@",[_auth getAcademicsCalId]], nil]
                                          requestBody:nil];
                    
                    [[_auth getAuthCals] setObject:@"YES" forKey:@"Entertainment"];
                    
                    //NSLog(@"The user can manage Entertainment events!");
                }
                else if(_reqsSent == 2) {
                    // If user authorization is successful, then make an API call to get the event list for the current month.
                    // For more infomation about this API call, visit:
                    // https://developers.google.com/google-apps/calendar/v3/reference/calendarList/list
                    [[_auth getAuthenticator] callAPI:[NSString stringWithFormat:@"https://www.googleapis.com/calendar/v3/calendars/%@/events/6fhomj6btb4eueb4rl0t1mqsdg/move", [_auth getActivitiesCalId]]
                                       withHttpMethod:httpMethod_POST
                                   postParameterNames:[NSArray arrayWithObjects:@"destination", nil]
                                  postParameterValues:[NSArray arrayWithObjects:[NSString stringWithFormat:@"%@",[_auth getActivitiesCalId]], nil]
                                          requestBody:nil];
                    [[_auth getAuthCals] setObject:@"YES" forKey:@"Academics"];
                    //NSLog(@"The user can manage Academics events!");
                }
                else if (_reqsSent == 3) {
                    // If user authorization is successful, then make an API call to get the event list for the current month.
                    // For more infomation about this API call, visit:
                    // https://developers.google.com/google-apps/calendar/v3/reference/calendarList/list
                    [[_auth getAuthenticator] callAPI:[NSString stringWithFormat:@"https://www.googleapis.com/calendar/v3/calendars/%@/events/mg2obo46a6nqb32v33otufivq8/move", [_auth getResidenceCalId]]
                                       withHttpMethod:httpMethod_POST
                                   postParameterNames:[NSArray arrayWithObjects:@"destination", nil]
                                  postParameterValues:[NSArray arrayWithObjects:[NSString stringWithFormat:@"%@",[_auth getResidenceCalId]], nil]
                                          requestBody:nil];
                    [[_auth getAuthCals] setObject:@"YES" forKey:@"Student Activities"];
                    
                    //NSLog(@"The user can manage Activities events!");
                }
                else if(_reqsSent == 4) {
                    // If user authorization is successful, then make an API call to get the event list for the current month.
                    // For more infomation about this API call, visit:
                    // https://developers.google.com/google-apps/calendar/v3/reference/calendarList/list
                    [[_auth getAuthenticator] callAPI:[NSString stringWithFormat:@"https://www.googleapis.com/calendar/v3/calendars/%@/events/m2vg4ncj8bu7oechv50ltk84j4/move", [_auth getAthleticsCalId]]
                                       withHttpMethod:httpMethod_POST
                                   postParameterNames:[NSArray arrayWithObjects:@"destination", nil]
                                  postParameterValues:[NSArray arrayWithObjects:[NSString stringWithFormat:@"%@",[_auth getAthleticsCalId]], nil]
                                          requestBody:nil];
                    [[_auth getAuthCals] setObject:@"YES" forKey:@"Residence Life"];
                    
                    //NSLog(@"The user can manage Residences events!");
                }
                else if(_reqsSent == 5) {
                    // If user authorization is successful, then make an API call to get the event list for the current month.
                    // For more infomation about this API call, visit:
                    // https://developers.google.com/google-apps/calendar/v3/reference/calendarList/list
                    [[_auth getAuthenticator] callAPI:[NSString stringWithFormat:@"https://www.googleapis.com/calendar/v3/calendars/%@/events/650gme9itnmk2ofvo2crjrm2io/move", [_auth getCampusRecCalId]]
                                       withHttpMethod:httpMethod_POST
                                   postParameterNames:[NSArray arrayWithObjects:@"destination", nil]
                                  postParameterValues:[NSArray arrayWithObjects:[NSString stringWithFormat:@"%@",[_auth getCampusRecCalId]], nil]
                                          requestBody:nil];
                    [[_auth getAuthCals] setObject:@"YES" forKey:@"Warrior Athletics"];
                    
                    //NSLog(@"The user can manage Athletics events!");
                }
                _timeLastReqSent = [[NSDate date] timeIntervalSince1970];
                _reqsSent += 1;
            }
        }
    }
}

-(void)accessTokenWasRevoked{
    [_events resetEvents];
    _jsonsToIgnore = 0;
    _reqsSent = 0;
}


-(void)errorOccuredWithShortDescription:(NSString *)errorShortDescription andErrorDetails:(NSString *)errorDetails{
    // Just log the error messages.
    //NSLog(@"Error:%@", errorShortDescription);
    //NSLog(@"Details:%@", errorDetails);
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle: errorShortDescription
                                                    message: errorDetails
                                                   delegate: nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}


-(void)errorInResponseWithBody:(NSString *)errorMessage{
    // Just log the error message.
    //NSLog(@"Error:%@", errorMessage);
    
    if ([self getIndexOfSubstringInString:@"403" :errorMessage] != -1
        && [self getIndexOfSubstringInString:@"Forbidden" :errorMessage] != -1)
    {
        if (_reqsSent == 6) {
            _reqsSent = 0;
            _authenticating = NO;
            [[_auth getAuthCals] setObject:@"YES" forKey:@"Campus Rec"];
            
            _curArrayId = 1;
            //NSLog(@"The user can manage Campus Rec events!");
            [self getEventsForMonth:[_events getSelectedMonth] :[_events getSelectedYear]];
        }
        else {
            if (_reqsSent == 1) {
                // If user authorization is successful, then make an API call to get the event list for the current month.
                // For more infomation about this API call, visit:
                // https://developers.google.com/google-apps/calendar/v3/reference/calendarList/list
                [[_auth getAuthenticator] callAPI:[NSString stringWithFormat:@"https://www.googleapis.com/calendar/v3/calendars/%@/events/2krf6iakqog30751k9skgrsj6c/move", [_auth getAcademicsCalId]]
                                   withHttpMethod:httpMethod_POST
                               postParameterNames:[NSArray arrayWithObjects:@"destination", nil]
                              postParameterValues:[NSArray arrayWithObjects:[NSString stringWithFormat:@"%@",[_auth getAcademicsCalId]], nil]
                                      requestBody:nil];
                [[_auth getAuthCals] setObject:@"NO" forKey:@"Entertainment"];
                
                //NSLog(@"The user can't manage Entertainment events!");
            }
            else if(_reqsSent == 2) {
                // If user authorization is successful, then make an API call to get the event list for the current month.
                // For more infomation about this API call, visit:
                // https://developers.google.com/google-apps/calendar/v3/reference/calendarList/list
                [[_auth getAuthenticator] callAPI:[NSString stringWithFormat:@"https://www.googleapis.com/calendar/v3/calendars/%@/events/6fhomj6btb4eueb4rl0t1mqsdg/move", [_auth getActivitiesCalId]]
                                   withHttpMethod:httpMethod_POST
                               postParameterNames:[NSArray arrayWithObjects:@"destination", nil]
                              postParameterValues:[NSArray arrayWithObjects:[NSString stringWithFormat:@"%@",[_auth getActivitiesCalId]], nil]
                                      requestBody:nil];
                [[_auth getAuthCals] setObject:@"NO" forKey:@"Academics"];
                
                //NSLog(@"The user can't manage Academics events!");
            }
            else if (_reqsSent == 3) {
                // If user authorization is successful, then make an API call to get the event list for the current month.
                // For more infomation about this API call, visit:
                // https://developers.google.com/google-apps/calendar/v3/reference/calendarList/list
                [[_auth getAuthenticator] callAPI:[NSString stringWithFormat:@"https://www.googleapis.com/calendar/v3/calendars/%@/events/mg2obo46a6nqb32v33otufivq8/move", [_auth getResidenceCalId]]
                                   withHttpMethod:httpMethod_POST
                               postParameterNames:[NSArray arrayWithObjects:@"destination", nil]
                              postParameterValues:[NSArray arrayWithObjects:[NSString stringWithFormat:@"%@",[_auth getResidenceCalId]], nil]
                                      requestBody:nil];
                [[_auth getAuthCals] setObject:@"NO" forKey:@"Student Activities"];
                
                //NSLog(@"The user can't manage Athletics events!");
            }
            else if(_reqsSent == 4) {
                // If user authorization is successful, then make an API call to get the event list for the current month.
                // For more infomation about this API call, visit:
                // https://developers.google.com/google-apps/calendar/v3/reference/calendarList/list
                [[_auth getAuthenticator] callAPI:[NSString stringWithFormat:@"https://www.googleapis.com/calendar/v3/calendars/%@/events/m2vg4ncj8bu7oechv50ltk84j4/move", [_auth getAthleticsCalId]]
                                   withHttpMethod:httpMethod_POST
                               postParameterNames:[NSArray arrayWithObjects:@"destination", nil]
                              postParameterValues:[NSArray arrayWithObjects:[NSString stringWithFormat:@"%@",[_auth getAthleticsCalId]], nil]
                                      requestBody:nil];
                
                [[_auth getAuthCals] setObject:@"NO" forKey:@"Residence Life"];
                
                //NSLog(@"The user can't manage Residence events!");
            }
            else if(_reqsSent == 5) {
                // If user authorization is successful, then make an API call to get the event list for the current month.
                // For more infomation about this API call, visit:
                // https://developers.google.com/google-apps/calendar/v3/reference/calendarList/list
                [[_auth getAuthenticator] callAPI:[NSString stringWithFormat:@"https://www.googleapis.com/calendar/v3/calendars/%@/events/650gme9itnmk2ofvo2crjrm2io/move", [_auth getCampusRecCalId]]
                                   withHttpMethod:httpMethod_POST
                               postParameterNames:[NSArray arrayWithObjects:@"destination", nil]
                              postParameterValues:[NSArray arrayWithObjects:[NSString stringWithFormat:@"%@",[_auth getCampusRecCalId]], nil]
                                      requestBody:nil];
                [[_auth getAuthCals] setObject:@"YES" forKey:@"Warrior Athletics"];
                
                //NSLog(@"The user can manage Athletics events!");
            }
            _timeLastReqSent = [[NSDate date] timeIntervalSince1970];
            _reqsSent += 1;
        }
    }
}

@end