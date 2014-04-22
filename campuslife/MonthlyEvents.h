//
//  MonthlyEvents.h
//  LCSC Campus Life
//
//  Created by Super Student on 11/7/13.
//  Copyright (c) 2013 LCSC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MonthlyEvents : NSObject


+(MonthlyEvents *)getSharedInstance;


-(void)refreshArrayOfEvents:(int)arrayId;
-(void)AppendEvent:(NSInteger)day :(NSDictionary *)eventDict :(int)arrayId;
-(NSArray *)getEventsForDay:(NSInteger)day;
-(int)getFirstWeekDay:(int)arrayId ;
-(NSString *)getMonthBarDate;
-(int)getDaysOfMonth;
-(int)getDaysOfMonth:(int)month :(int)year;
-(int)getDaysOfPreviousMonth;
-(void)offsetMonth:(int)offset;

-(void)setSelectedDay:(int)day;
-(int)getSelectedDay;

-(int)getSelectedMonth;
-(int)getSelectedYear;

-(BOOL)doesMonthNeedLoaded:(int)arrayId;

@end
