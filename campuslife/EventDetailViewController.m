//
//  EventDetailViewController.m
//  LCSC Campus Life
//
//  Created by Super Student on 11/12/13.
//  Copyright (c) 2013 LCSC. All rights reserved.
//

#import "EventDetailViewController.h"
#import "Authentication.h"

@interface EventDetailViewController ()

@end

@implementation EventDetailViewController

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
    _summaryLabel.text = [_eventsDict objectForKey:@"summary"];
    _locLabel.text = [_eventsDict objectForKey:@"location"];
    _categoryLabel.text = [_eventsDict objectForKey:@"category"];
    _descriptLabel.text = [_eventsDict objectForKey:@"description"];
    
    if (![[Authentication getSharedInstance] getUserCanManageEvents]) {
        _addEventButton.enabled = NO;
        _addEventButton.titleLabel.text = @"";
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
