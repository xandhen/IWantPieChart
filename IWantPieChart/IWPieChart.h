//
//  IWPieChart.h
//  IWantPieChart
//
//  Created by Andreas Henriksson on 2013-03-16.
//  Copyright (c) 2013 Andreas Henriksson. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person
//  obtaining a copy of this software and associated documentation
//  files (the "Software"), to deal in the Software without
//  restriction, including without limitation the rights to use,
//  copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the
//  Software is furnished to do so, subject to the following
//  conditions:
//
//  The above copyright notice and this permission notice shall be
//  included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
//  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
//  OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
//  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
//  HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
//  WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
//  OTHER DEALINGS IN THE SOFTWARE.

#import <UIKit/UIKit.h>

typedef enum UnitDisplayType {
    UnitDisplayTypeNone = 0,
    UnitDisplayTypePercentage = 1,
    UnitDisplayTypeUnit = 2
    } UnitDisplayType;

@interface IWPieChart : UIView {
@private
    NSMutableArray *_sliceData;
    CGFloat _radius;
    CGPoint _center;
}

@property(nonatomic, copy) UIColor *sliceBaseColor;
@property(nonatomic, copy) UIColor *textColor;
@property(nonatomic, retain) NSString *unit;
@property(nonatomic, assign) UnitDisplayType unitToDisplay;
@property(nonatomic, assign) CGFloat innerRadius;
@property(nonatomic, assign, getter = setSelectedOffset) CGFloat selectedOffset;
@property(nonatomic, assign) BOOL allowMultiSelect;

- (id)initWithFrame:(CGRect)frame;
- (id)initWithFrame:(CGRect)frame pieCenter:(CGPoint)center pieRadius:(CGFloat)radius;

- (void)addSlices:(int)count WithValues:(CGFloat*)values;

- (void)addSliceWithValue:(CGFloat)value;
- (void)addSliceWithValue:(CGFloat)value Text:(NSString*)text;
- (void)addSliceWithValue:(CGFloat)value Color:(UIColor*)color;
- (void)addSliceWithValue:(CGFloat)value Text:(NSString*)text Color:(UIColor*)color;

- (void)selectSliceAtIndex:(NSInteger)index;

- (UIColor*)generateSliceColorWithIndex:(NSInteger)index ofTotal:(NSInteger)total;

@end
