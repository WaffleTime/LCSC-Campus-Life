//
//  MonthlyEvents.m
//  LCSC Campus Life
//
//  Created by Super Student on 11/7/13.
//  Copyright (c) 2013 LCSC. All rights reserved.
//

#import "MonthlyEvents.h"


static MonthlyEvents *sharedInstance;


@interface MonthlyEvents ()

//A 2d array that holds the events for the calendar of the current month.
//  Each element corresponds with the day.
@property (nonatomic, strong, setter=setCalendarEvents:) NSMutableArray *calendarEvents;

@property (nonatomic, setter=setFirstWeekDay:) int firstWeekDay;

@property (nonatomic, setter=setYear:) int selectedYear;
@property (nonatomic, setter=setMonth:) int selectedMonth;

@property (nonatomic, setter=setDaysInMonth:) NSMutableArray *daysInMonth;

@property (nonatomic, setter=setKnownOffsetForJan2013:) int knownOffsetForJan2013;

//This is strictly for the CalendarViewController to talk to the DayEventViewController (it's a work around.)
@property (nonatomic, setter=setDay:) int selectedDay;

@end

@implementation MonthlyEvents


+(MonthlyEvents *) getSharedInstance {
    if (!sharedInstance) {
        sharedInstance = [[MonthlyEvents alloc] init];
        
        NSDate *date = [NSDate date];
        NSDateComponents *dateComponents = [[NSCalendar currentCalendar] components:NSYearCalendarUnit | NSMonthCalendarUnit fromDate:date];
        NSInteger year = [dateComponents year];
        NSInteger month = [dateComponents month];
        
        [sharedInstance setYear:(int)year];
        [sharedInstance setMonth:(int)month];
        
        //NSLog(@"This month is: %d", month);
        
        //account for leap year.
        if (year % 4 == 0) {
            [sharedInstance setDaysInMonth:[[NSMutableArray alloc] initWithArray:@[@31, @29, @31, @30, @31, @30, @31, @31, @30, @31, @30, @31]]];
        }
        else {
            [sharedInstance setDaysInMonth:[[NSMutableArray alloc] initWithArray:@[@31, @28, @31, @30, @31, @30, @31, @31, @30, @31, @30, @31]]];
        }
        
        [sharedInstance setKnownOffsetForJan2013:2];
        
        //NSLog(@"The current year and month is:%ld %ld",year, month);
    }
    return sharedInstance;
}

- (void) refreshArrayOfEvents {
    if (_calendarEvents != nil) {
        [_calendarEvents removeAllObjects];
    }
    else {
        [self setCalendarEvents:[[NSMutableArray alloc]init]];
    }
    
    int firstWeekday = 0;
    
    if (_selectedYear >= 2013) {
        firstWeekday = _knownOffsetForJan2013;
        
        for (int i = 2013; i <= _selectedYear; i++) {
            
            //account for leap year
            if (i%4 == 0
                && [[_daysInMonth objectAtIndex:1] integerValue] != 29) {
                [_daysInMonth replaceObjectAtIndex:1 withObject:@29];
            }
            else if ([[_daysInMonth objectAtIndex:1] integerValue] != 28){
                [_daysInMonth replaceObjectAtIndex:1 withObject:@28];
            }
            
            if (i == _selectedYear) {
                for (int j = 0; j < _selectedMonth-1; j++) {
                    firstWeekday += [[_daysInMonth objectAtIndex:j] integerValue] % 7;
                }
            }
            else {
                for (int j = 0; j < 12; j++) {
                    firstWeekday += [[_daysInMonth objectAtIndex:j] integerValue] % 7;
                }
            }
            
            //The first weekday should be on the first week of the month.
            firstWeekday = firstWeekday % 7;
        }
    }
    else {
        firstWeekday = _knownOffsetForJan2013;
        
        for (int i = 2013-1; i >= _selectedYear; i--) {
            
            //account for leap year
            if (i%4 == 0
                && (int)[_daysInMonth objectAtIndex:1] != 29) {
                [_daysInMonth replaceObjectAtIndex:1 withObject:@29];
            }
            else if ((int)[_daysInMonth objectAtIndex:1] != 28){
                [_daysInMonth replaceObjectAtIndex:1 withObject:@28];
            }
            
            if (i == _selectedYear) {
                for (int j = 11; j >= _selectedMonth-1; j--) {
                    firstWeekday -= [[_daysInMonth objectAtIndex:j] integerValue] % 7;
                }
            }
            else {
                for (int j = 11; j >= 0; j--) {
                    firstWeekday -= [[_daysInMonth objectAtIndex:j] integerValue] % 7;
                }
            }
            
            //The first weekday should be on the first week of the month.
            firstWeekday = (firstWeekday % 7)+7;
        }
    }
    
    [self setFirstWeekDay:firstWeekday];
    
    //Set the leap year stuff back up since we could have changed it beforehand.
    if (_selectedYear%4 == 0
        && (int)[_daysInMonth objectAtIndex:1] != 29) {
        [_daysInMonth replaceObjectAtIndex:1 withObject:@29];
    }
    else if ((int)[_daysInMonth objectAtIndex:1] != 28){
        [_daysInMonth replaceObjectAtIndex:1 withObject:@28];
    }
    
    //NSLog(@"The array of daysInMonth is %@", _daysInMonth);
    
    //NSLog(@"The first weekday index is %d", _firstWeekDay);
    
    //NSLog(@"The selectedMonth is %d", _selectedMonth);
    
    //NSLog(@"The number of days for the given month is:%ld", [[_daysInMonth objectAtIndex:_selectedMonth-1] integerValue]);
    
    //This should loop through the amounts of days in the given month.
    //  So change this to work with the month/year that the user has selected.
    for (int i=0; i < [[_daysInMonth objectAtIndex:_selectedMonth-1] integerValue]; i++) {
        [_calendarEvents addObject:[[NSMutableArray alloc] init]];
    }
}

//Takes in events from the json retrieved from the Google Calendar API.
//@param day Day the event is on, 1-31.
-(void)AppendEvent:(NSInteger)day :(NSDictionary *)eventDict {
    [[_calendarEvents objectAtIndex:day-1] addObject:eventDict];
}

//@param day Day the events are on, 1-31.
-(NSArray *)getEventsForDay:(NSInteger)day {
    return [_calendarEvents objectAtIndex:day-1];
}

//@return An integer in [0,6] that represents a day of the week.
-(int)getFirstWeekDay {
    return _firstWeekDay;
}

//Gets a string that represents the current month.
-(NSString *)getMonthBarDate {
    NSString *month;
    switch (_selectedMonth) {
        case 1:
            month = @"January";
            break;
        case 2:
            month = @"February";
            break;
        case 3:
            month = @"March";
            break;
        case 4:
            month = @"April";
            break;
        case 5:
            month = @"May";
            break;
        case 6:
            month = @"June";
            break;
        case 7:
            month = @"July";
            break;
        case 8:
            month = @"August";
            break;
        case 9:
            month = @"September";
            break;
        case 10:
            month = @"October";
            break;
        case 11:
            month = @"November";
            break;
        case 12:
            month = @"December";
            break;
    }
    
    return [month stringByAppendingString:[NSString stringWithFormat:@", %d", _selectedYear]];
}

//@return Should be an integer in [28,31].
-(int)getDaysOfMonth {
    //_selectedMonth contains [1,12], daysInMonth takes in [0,11]
    return (int)[[_daysInMonth objectAtIndex:_selectedMonth-1] integerValue];
}

//@param month An integer in [1,12]
//@return Should be an integer in [28,31].
-(int)getDaysOfMonth:(int)month {
    return (int)[[_daysInMonth objectAtIndex:month-1] integerValue];
}

//@return Should be an integer in [28,31].
-(int)getDaysOfPreviousMonth {
    int previousMonth = 0;
    if (_selectedMonth-2 < 0) {
        previousMonth=12+_selectedMonth-2;
    }
    else {
        previousMonth = _selectedMonth-2;
    }
    //previousMonth contains [0,11] daysInMonth takes in [0,11]
    return (int)[[_daysInMonth objectAtIndex:previousMonth] integerValue];
}

-(void)offsetMonth:(int)offset {
    if (_selectedMonth + offset <= 0) {
        [self setMonth:_selectedMonth+offset+12];
        [self setYear:_selectedYear-1];
        
        //account for leap year
        if (_selectedYear%4 == 0
            && (int)[_daysInMonth objectAtIndex:1] != 29) {
            [_daysInMonth replaceObjectAtIndex:1 withObject:@29];
        }
        else if ((int)[_daysInMonth objectAtIndex:1] != 28){
            [_daysInMonth replaceObjectAtIndex:1 withObject:@28];
        }
    }
    else if (_selectedMonth + offset > 12) {
        [self setMonth:_selectedMonth+offset-12];
        [self setYear:_selectedYear+1];
        
        //account for leap year
        if (_selectedYear%4 == 0
            && (int)[_daysInMonth objectAtIndex:1] != 29) {
            [_daysInMonth replaceObjectAtIndex:1 withObject:@29];
        }
        else if ((int)[_daysInMonth objectAtIndex:1] != 28){
            [_daysInMonth replaceObjectAtIndex:1 withObject:@28];
        }
    }
    else {
        [self setMonth:_selectedMonth+offset];
    }
    
    //NSLog(@"The new year is %d and the new month is %d", _selectedYear, _selectedMonth);
    
    [self refreshArrayOfEvents];
}


//@param day Accepts integers in [1,31]
-(void)setSelectedDay:(int)day {
    [self setDay:day];
}

//@return Returns an integer in [1,31]
-(int)getSelectedDay {
    return _selectedDay;
}



//@return Returns an integer in [1,12]
-(int)getSelectedMonth {
    return _selectedMonth;
}

//@return The exact year, no off by one here.
-(int)getSelectedYear {
    return _selectedYear;
}

@end
