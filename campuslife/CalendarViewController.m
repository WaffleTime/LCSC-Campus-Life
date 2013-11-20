//
//  ViewController.m
//  LCSC Campus Life
//
//  Created by Super Student on 10/29/13.
//  Copyright (c) 2013 LCSC. All rights reserved.
//

#import "CalendarViewController.h"
#import "MonthlyEvents.h"
#import "Preferences.h"

@interface CalendarViewController ()

// A GoogleOAuth object that handles everything regarding the Google.
@property (nonatomic, strong) GoogleOAuth *googleOAuth;

@property (nonatomic, setter=setSignedIn:) BOOL signedIn;

@end

@implementation CalendarViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    NSLog(@"authorizing user");
    
    [[self navigationController] setNavigationBarHidden:YES animated:NO];
    
    // Initialize the googleOAuth object.
    // Pay attention so as to initialize it with the initWithFrame: method, not just init.
    _googleOAuth = [[GoogleOAuth alloc] initWithFrame:self.view.frame];
    // Set self as the delegate.
    [_googleOAuth setGOAuthDelegate:self];
    
    [_googleOAuth authorizeUserWithClienID:@"408837038497.apps.googleusercontent.com"
                           andClientSecret:@"boEOJa_DKR9c06vLWbBdmC92"
                             andParentView:self.view
                                 andScopes:[NSArray arrayWithObject:@"https://www.googleapis.com/auth/calendar"]];
    
    [self setSignedIn:NO];
    self.signInOutButton.title = @"Sign In";

    [_cat1Btn setBackgroundImage:[UIImage imageNamed:@"EntertainmentSelected.png"]
                                 forState:UIControlStateSelected];
    [_cat2Btn setBackgroundImage:[UIImage imageNamed:@"AcademicsSelected.png"]
                        forState:UIControlStateSelected];
    [_cat3Btn setBackgroundImage:[UIImage imageNamed:@"ActivitiesSelected.png"]
                        forState:UIControlStateSelected];
    [_cat4Btn setBackgroundImage:[UIImage imageNamed:@"ResidenceSelected.png"]
                                 forState:UIControlStateSelected];
    [_cat5Btn setBackgroundImage:[UIImage imageNamed:@"AthleticsSelected.png"]
                                 forState:UIControlStateSelected];
    
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
        [_googleOAuth revokeAccessToken];
        
        [self setSignedIn:NO];
        
        self.signInOutButton.title = @"Sign In";
        
        //NSLog(@"Signed out we did");
    }
    else {
        [_googleOAuth authorizeUserWithClienID:@"408837038497.apps.googleusercontent.com"
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
    
    MonthlyEvents *events = [MonthlyEvents getSharedInstance];
    
    [events offsetMonth:-1];
    
    _monthLabel.text = [events getMonthBarDate];
    
    [self getEventsForMonth:[events getSelectedMonth] :[events getSelectedYear]];
    
    //NSLog(@"went to previous month");
}

- (IBAction)forwardMonthOffset:(id)sender {
    [_activityIndicator startAnimating];
    
    MonthlyEvents *events = [MonthlyEvents getSharedInstance];
    
    [events offsetMonth:1];
    
    _monthLabel.text = [events getMonthBarDate];
    
    [self getEventsForMonth:[events getSelectedMonth] :[events getSelectedYear]];
    
    //NSLog(@"went to next month");
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    int cells;
    
    if (_signedIn) {
        cells = 35;

        MonthlyEvents *events = [MonthlyEvents getSharedInstance];
        //NSLog(@"The number of cells required:%d", [events getFirstWeekDay] + [events getDaysOfMonth]-1);
        
        if ([events getFirstWeekDay] + [events getDaysOfMonth]-1 >= 35) {
            cells = 42;
        }
    }
    else {
        cells = 0;
    }
    
    return cells;
}

/*
 - (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
 {
     UICollectionReusableView *reusableview = nil;
     
     if (kind == UICollectionElementKindSectionHeader) {
         UICollectionReusableView *headerview = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"Legend" forIndexPath:indexPath];
         
         reusableview = headerview;
     }
     
 return reusableview;
 }
*/


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    UICollectionViewCell *cell;
    
    MonthlyEvents *events = [MonthlyEvents getSharedInstance];
    
    //NSLog(@"The first weekday is:%d", [events getFirstWeekDay]);
    
    //NSLog(@"Check to see if cell is for next month:%d >= %d", indexPath.row+1 - [events getFirstWeekDay], [events getDaysOfMonth]);
    
    //Check to see if this cell is for a day of the previous month
    if (indexPath.row+1 - [events getFirstWeekDay] <= 0) {
        cell = (UICollectionViewCell *)[_collectionView dequeueReusableCellWithReuseIdentifier:@"OtherMonthCell" forIndexPath:indexPath];
        
        UILabel *dayLbl = (UILabel *)[cell viewWithTag:100];
        
        dayLbl.text = [NSString stringWithFormat:@"%d", (int)indexPath.row+1 - [events getFirstWeekDay] + [events getDaysOfPreviousMonth]];
    }
    //Check to see if this cell is for a day of the next month
    else if (indexPath.row+1 - [events getFirstWeekDay] > [events getDaysOfMonth]) {
        cell = (UICollectionViewCell *)[_collectionView dequeueReusableCellWithReuseIdentifier:@"OtherMonthCell" forIndexPath:indexPath];
        
        UILabel *dayLbl = (UILabel *)[cell viewWithTag:100];

        dayLbl.text = [NSString stringWithFormat:@"%d", (int)indexPath.row+1 - [events getFirstWeekDay] - [events getDaysOfMonth]];
    }
    else {
        cell = (UICollectionViewCell *)[_collectionView dequeueReusableCellWithReuseIdentifier:@"CurrentDayCell" forIndexPath:indexPath];
        
        UILabel *dayLbl = (UILabel *)[cell viewWithTag:100];
        
        dayLbl.text = [NSString stringWithFormat:@"%d", (int)indexPath.row+1 - [events getFirstWeekDay]];
        
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
        NSArray *dayEvents = [events getEventsForDay:(int)indexPath.row+1 - [events getFirstWeekDay]];

        //Iterate through all events and determine categories that are present.
        for (int i=0; i<[dayEvents count]; i++) {
            NSString *category = [[dayEvents objectAtIndex:i] objectForKey:@"category"];
            
            //We'll unhide the category squares that are found.
            if ([category isEqual:@"Entertainment"]) {
                if (cat1.hidden) {
                    //Check to see if this category is selected.
                    if ([prefs getPreference:1]) {
                        cat1.hidden = NO;
                    }
                }
            }
            else if ([category isEqual:@"Academics"]) {
                if (cat2.hidden) {
                    //Check to see if this category is selected.
                    if ([prefs getPreference:2]) {
                        cat2.hidden = NO;
                    }
                }
            }
            else if ([category isEqual:@"Activities"]) {
                if (cat3.hidden) {
                    //Check to see if this category is selected.
                    if ([prefs getPreference:3]) {
                        cat3.hidden = NO;
                    }
                }
            }
            else if ([category isEqual:@"Residence"]) {
                if (cat4.hidden) {
                    //Check to see if this category is selected.
                    if ([prefs getPreference:4]) {
                        cat4.hidden = NO;
                    }
                }
            }
            else if ([category isEqual:@"Athletics"]) {
                if (cat5.hidden) {
                    //Check to see if this category is selected.
                    if ([prefs getPreference:5]) {
                        cat5.hidden = NO;
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
        
        MonthlyEvents *events = [MonthlyEvents getSharedInstance];
        
        //[destViewController setDay:indexPath.row+1 - [events getFirstWeekDay] ];
        
        [events setSelectedDay:(int)indexPath.row+1 - [events getFirstWeekDay]];
    }
}


- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    BOOL canSegue = YES;
    
    if ([identifier isEqualToString:@"CalendarToDayEvents"]) {
        NSArray *indexPaths = [_collectionView indexPathsForSelectedItems];
        NSIndexPath *indexPath = [indexPaths objectAtIndex:0];
        
        MonthlyEvents *events = [MonthlyEvents getSharedInstance];
        
        //Check to see if this cell is for a day of the previous month
        if (indexPath.row+1 - [events getFirstWeekDay] <= 0) {
            //Offset month if a previous month's cell is clicked
            [self backMonthOffset:nil];
            canSegue = NO;
        }
        //Check to see if this cell is for a day of the next month
        else if (indexPath.row+1 - [events getFirstWeekDay] > [events getDaysOfMonth]) {
            //Offset month if a future month's cell is clicked
            [self forwardMonthOffset:nil];
            canSegue = NO;
        }
    }
    return canSegue;
}

/*
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
 
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{

}
*/

- (int)getIndexOfSubstringInString:(NSString *)substring :(NSString *)string {
    BOOL substringFound = NO;
    
    int substringStartIndex = -1;
    
    //Iterate through the string to find the first character in the substring.
    for (int i=0; i<[string length]; i++) {
        //Check to see if the substring character has been found.
        if ([string characterAtIndex:i] == [substring characterAtIndex:0]) {
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
            //If we've found the substring, we can stop the loop.
            if (substringFound) {
                break;
            }
        }
    }
    
    return substringStartIndex;
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
    [_googleOAuth callAPI:@"https://www.googleapis.com/calendar/v3/calendars/lcmail.lcsc.edu_09hhfhm9kcn5h9dhu83ogsd0u8@group.calendar.google.com/events"
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
            
            //This sets up the _calendarEvents array for new events for the given month.
            MonthlyEvents *events = [MonthlyEvents getSharedInstance];
            [events refreshArrayOfEvents];
            
            _monthLabel.text = [events getMonthBarDate];
            
            //Loop through the events
            for (int i=0; i<[eventsInfo count]; i++) {
                NSMutableDictionary *mCurrentEvent = [[NSMutableDictionary alloc] initWithDictionary:[eventsInfo objectAtIndex:i]];
                
                NSInteger day = [[[[mCurrentEvent objectForKey:@"start"] objectForKey:@"dateTime"] substringWithRange:NSMakeRange(8, 2)] integerValue];
                
                //NSLog(@"The day of the event is %ld", day);
                
                NSString *description = [mCurrentEvent objectForKey:@"description"];
                
                int substringStartIndex = [self getIndexOfSubstringInString:@"Category: " :description];
                
                if (substringStartIndex == -1) {
                    //Just because typos happen, do the same, but for no space after "Category:"
                    substringStartIndex = [self getIndexOfSubstringInString:@"Category:" :description];
                    
                    //Check if "Category:" wasn't present again.
                    if (substringStartIndex == -1) {
                        [mCurrentEvent setObject:@"No Category" forKey:@"category"];
                    }
                    else {
                        //This block gets the first word after the "Category:", which is the category.
                        NSString *categoryWithExtraStuff = [description substringWithRange:NSMakeRange(substringStartIndex+9, [description length] - substringStartIndex+9)];
                        NSString *category = [[categoryWithExtraStuff componentsSeparatedByString:@"\n"] objectAtIndex:0];
                        
                        int trailingSpaces = 0;
                        
                        //Determine number of trailing spaces, so we can not include them in the category.
                        for (int j=(int)[category length]-1; j>=0; j--) {
                            if ([category characterAtIndex:j] != ' ') {
                                break;
                            }
                            else {
                                trailingSpaces += 1;
                            }
                        }
                        
                        //Add the category item to the dictionary.
                        [mCurrentEvent setObject:[category substringWithRange:NSMakeRange(0, [category length] - trailingSpaces)]
                                          forKey:@"category"];
                    }
                }
                else {
                    //This block gets the first word after the "Category:", which is the category.
                    NSString *categoryWithExtraStuff = [description substringWithRange:NSMakeRange(substringStartIndex+10, [description length] - (substringStartIndex+10))];
                    NSString *category = [[categoryWithExtraStuff componentsSeparatedByString:@"\n"] objectAtIndex:0];
                    
                    int trailingSpaces = 0;
                    
                    //Determine number of trailing spaces, so we can not include them in the category.
                    for (int j=(int)[category length]-1; j>=0; j--) {
                        if ([category characterAtIndex:j] != ' ') {
                            break;
                        }
                        else {
                            trailingSpaces += 1;
                        }
                    }
                    
                    //Add the category item to the dictionary.
                    [mCurrentEvent setObject:[category substringWithRange:NSMakeRange(0, [category length] - trailingSpaces)]
                                      forKey:@"category"];
                }
                
                //This then uses that day as an index and inserts the currentEvent into that indice's array.
                [events AppendEvent:day :(NSDictionary *)mCurrentEvent];
            }
            //NSLog(@"These are our calendar events: %@",_calendarEvents);
            
            [_collectionView reloadData];
        }
        
        [_activityIndicator stopAnimating];
    }
}

-(void)accessTokenWasRevoked{
    MonthlyEvents *events = [MonthlyEvents getSharedInstance];
    [events refreshArrayOfEvents];
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
