//
//  IWViewController.m
//  IWantPieChart
//
//  Created by Andreas Henriksson on 2013-03-16.
//  Copyright (c) 2013 Andreas Henriksson. All rights reserved.
//

#import "IWViewController.h"
#import "IWPieChart.h"

@interface IWViewController ()

@end

@implementation IWViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [self.view setBackgroundColor:[UIColor whiteColor]];
    CGSize size = CGSizeMake(self.view.frame.size.width - 20, self.view.frame.size.height - 20);
    CGRect pieFrame = CGRectMake(10, 10, size.width, size.height - size.width/2);
    CGRect pieFrame2 = CGRectMake(10, pieFrame.size.height + 10, size.width/2, size.width/2);
    CGRect pieFrame3 = CGRectMake(size.width/2 + 10, pieFrame.size.height + 10, pieFrame2.size.width, pieFrame2.size.height);
    
    CGRect *pieFrames[3] = {&pieFrame, &pieFrame2, &pieFrame3};
    
    for (int i = 0; i < 3; i++) {
        IWPieChart *chart = [[IWPieChart alloc] initWithFrame:*pieFrames[i]];
        //[chart setSliceBaseColor:[UIColor colorWithHue:0.708f saturation:0.64f brightness:0.90f alpha:1.0f]];
        [chart setSliceBaseColor:[UIColor colorWithRed:0.059f green:0.631f blue:0.835f alpha:1.0f]];
        if (i == 1)
            [chart setInnerRadius:MIN((*pieFrames[i]).size.width, (*pieFrames[i]).size.height)*0.16f];
        
        [chart addSliceWithValue:40];
        [chart addSliceWithValue:60];
        [chart addSliceWithValue:30];
        [chart addSliceWithValue:80];
        [chart addSliceWithValue:10];
        [chart addSliceWithValue:20];
        [chart addSliceWithValue:40];
        [chart addSliceWithValue:40];
        [chart addSliceWithValue:40];
        [chart addSliceWithValue:40];
        
        if (i == 1 || i == 2)
            [chart setSelectedOffset:5.0f];
        if (i == 2)
            [chart setAllowMultiSelect:YES];
        if (i == 1 || i == 2)
            [chart selectSliceAtIndex:3];
        if (i == 2)
            [chart selectSliceAtIndex:8];
        
        if (i == 0)
            [chart setUnitToDisplay:UnitDisplayTypePercentage];
        if (i == 1 || i == 2)
            [chart setUnitToDisplay:UnitDisplayTypeUnit];
        
        [chart setBackgroundColor:[UIColor colorWithRed:0.88f green:0.88f blue:0.88f alpha:1.0f]];
        
        [self.view addSubview:chart];
        [chart release];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end