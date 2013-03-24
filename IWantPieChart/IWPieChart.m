//
//  IWPieChart.m
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

#import "IWPieChart.h"

@interface IWPieSliceData : NSObject

@property(nonatomic, assign) CGFloat value;
@property(nonatomic, retain) UIColor *color;
@property(nonatomic, retain) NSString *text;
@property(nonatomic, assign) BOOL selected;

- (id)initWithValue:(CGFloat)value;
- (id)initWithValue:(CGFloat)value Text:(NSString*)text;
- (id)initWithValue:(CGFloat)value Color:(UIColor*)color;
- (id)initWithValue:(CGFloat)value Text:(NSString*)text Color:(UIColor*)color;

@end

@implementation IWPieSliceData

- (id)initWithValue:(CGFloat)value {
    [self initializeWithValue:value Text:nil Color:nil];
    return self;
}

- (id)initWithValue:(CGFloat)value Text:(NSString*)text {
    [self initializeWithValue:value Text:text Color:nil];
    return self;
}

- (id)initWithValue:(CGFloat)value Color:(UIColor*)color {
    [self initializeWithValue:value Text:nil Color:color];
    return self;
}

- (id)initWithValue:(CGFloat)value Text:(NSString*)text Color:(UIColor*)color {
    [self initializeWithValue:value Text:text Color:color];
    return self;
}

-(void) initializeWithValue:(CGFloat)value Text:(NSString*)text Color:(UIColor*)color {
    self.value = value;
    self.text = text;
    self.color = color;
    self.selected = NO;
}

@end

@implementation IWPieChart

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self)
    {
        _sliceData = [[NSMutableArray alloc] initWithCapacity:3];
        self.sliceBaseColor = [UIColor cyanColor];
        self.textColor = [UIColor whiteColor];
        _center = CGPointMake(frame.size.width/2, frame.size.height/2);
        _radius = MIN(frame.size.width/2, frame.size.height/2);
        self.innerRadius = self.selectedOffset = 0.0f;
        self.allowMultiSelect = NO;
    }
    
    return self;
}

- (id)initWithFrame:(CGRect)frame pieCenter:(CGPoint)center pieRadius:(CGFloat)radius {
    self = [self initWithFrame:frame];
    if (self) {
        _center = center;
        _radius = radius;
        
        // Guard for if a too large radius is provided
        CGFloat width = (frame.size.width/2) - ABS((frame.size.width/2) - center.x);
        CGFloat height = (frame.size.height/2) - ABS((frame.size.height/2) - center.y);
        if (radius > MIN(width, height)/2)
            radius = MIN(width, height)/2;
        
        self.unitToDisplay = UnitDisplayTypeNone;
    }
    return self;
}

@synthesize selectedOffset = _selectedOffset;

- (void)setSelectedOffset:(CGFloat)selectedOffset {
    _selectedOffset = selectedOffset;
    _radius = MIN(self.frame.size.width/2 - selectedOffset, self.frame.size.height/2 - selectedOffset);
}

- (void)drawPieSliceInContext:(CGContextRef)context At:(CGPoint)point From:(CGFloat)startAngle To:(CGFloat)endAngle WithColor:(CGColorRef)color {
    bool clockwise = (startAngle > endAngle);
    if (self.innerRadius > 0.0f && self.innerRadius < _radius) {
        CGContextSetStrokeColorWithColor(context, color);
        CGContextSetLineWidth(context, _radius - self.innerRadius);
        CGContextAddArc(context, point.x, point.y, (_radius - self.innerRadius)/2 + self.innerRadius, startAngle, endAngle, clockwise);
        //CGContextStrokePath(context);
        CGContextDrawPath(context, kCGPathStroke);
    } else {
        CGContextSetFillColorWithColor(context, color);
        CGContextBeginPath(context);
        CGContextMoveToPoint(context, point.x, point.y);
        CGContextAddArc(context, point.x, point.y, _radius, startAngle, endAngle, clockwise);
        CGContextClosePath(context);
        CGContextFillPath(context);
    }
}

- (void)drawPieSliceText:(NSString*)text InContext:(CGContextRef)context At:(CGPoint)point {
    CGContextSetFillColorWithColor(context, self.textColor.CGColor);
    CGContextSetStrokeColorWithColor(context, self.textColor.CGColor);
    CGContextShowTextAtPoint(context, point.x, point.y, [text cStringUsingEncoding:NSASCIIStringEncoding], [text length]);
}

- (void)drawRect:(CGRect)rect
{
    UIFont *font = [UIFont systemFontOfSize:MAX(10.0f, _radius/10)];
    // Drawing code
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, self.backgroundColor.CGColor);
    CGContextSetLineWidth(context, 2.0f);
    CGContextSelectFont(context, [[font  fontName] cStringUsingEncoding:NSASCIIStringEncoding], MAX(10.0f, _radius/10), kCGEncodingMacRoman);
    CGContextSetTextDrawingMode(context, kCGTextFillStroke);
    CGContextSetTextMatrix(context, CGAffineTransformMake(1, 0, 0, -1, 0, 0));
    
    UIColor *color = nil;
    
    CGContextFillRect(context, rect);
    
    CGFloat totalWeight = [self totalPieWeight];
    if (totalWeight <= 0) {
        color = [self generateSliceColorWithIndex:0 ofTotal:1];
        [self drawPieSliceInContext:context At:_center From:0.0f To:2*M_PI WithColor:color.CGColor];
    } else {
        CGFloat currentAngle = 0.0f;
        int sliceCount = [_sliceData count];
        int currentSlice = 0;
        CGPoint point;
        CGPoint textPoint;
        CGFloat textRadius;
        CGFloat textAngle;
        CGSize textSize;
        NSString *text = nil;
        for (IWPieSliceData *pieData in _sliceData) {
            color = pieData.color != nil ? pieData.color : [self generateSliceColorWithIndex:currentSlice ofTotal:sliceCount];
            currentSlice++;
            CGFloat endAngle = sliceCount == currentSlice ? 2*M_PI : currentAngle + (2*M_PI)*(pieData.value/totalWeight);
            if (endAngle > currentAngle) {
                point = !pieData.selected ? _center : CGPointMake(_center.x + self.selectedOffset*cos((currentAngle+endAngle)/2), _center.y + self.selectedOffset*sin((currentAngle+endAngle)/2));
                [self drawPieSliceInContext:context At:point From:currentAngle To:endAngle WithColor:color.CGColor];
                                
                currentAngle = endAngle;
            }
        }
        CGContextSetLineWidth(context, 0.1f);
        if (self.unitToDisplay != UnitDisplayTypeNone) {
            for (IWPieSliceData *pieData in _sliceData) {
                currentSlice++;
                CGFloat endAngle = sliceCount == currentSlice ? 2*M_PI : currentAngle + (2*M_PI)*(pieData.value/totalWeight);
                if (endAngle > currentAngle) {
                    // Draw the text if we are supposed to
                    if (self.unitToDisplay == UnitDisplayTypePercentage) {
                        text = [NSString stringWithFormat:@"%0.0f", (pieData.value/totalWeight)*100.0f];
                    } else if (self.unitToDisplay == UnitDisplayTypeUnit) {
                        text = [NSString stringWithFormat:@"%0.0f", pieData.value];
                    }
                    
                    textRadius = _innerRadius > 0 ? (_radius - _innerRadius)*0.5f + _innerRadius : _radius*0.7f;
                    if (pieData.selected)
                        textRadius += self.selectedOffset;
                        
                    textAngle = (currentAngle+endAngle)/2;
                    // TODO: Calculate text size to offset our point!
                    textSize = [text sizeWithFont:font];
                    textPoint = CGPointMake(_center.x + textRadius*cos(textAngle) - textSize.width/2, _center.y + textRadius*sin(textAngle) + textSize.width/2);
                    
                    [self drawPieSliceText:text InContext:context At:textPoint];
                    
                    currentAngle = endAngle;
                }
            }
        }
    }
}

- (void)addSlices:(int)count WithValues:(CGFloat*)values {
    for (int i = 0; i < count; i++)
        [self addSliceWithValue:values[i]];
}

- (void)addSliceWithValue:(CGFloat)value {
    [self addSliceWithValue:value Text:nil Color:nil];
}

- (void)addSliceWithValue:(CGFloat)value Text:(NSString*)text {
    [self addSliceWithValue:value Text:text Color:nil];
}

- (void)addSliceWithValue:(CGFloat)value Color:(UIColor*)color {
    [self addSliceWithValue:value Text:nil Color:color];
}

- (void)addSliceWithValue:(CGFloat)value Text:(NSString*)text Color:(UIColor*)color {
    IWPieSliceData *data = [[IWPieSliceData alloc] initWithValue:value Text:text Color:color];
    [_sliceData addObject:data];
    [data release];
    
    [self setNeedsDisplay];
}

- (void)selectSliceAtIndex:(NSInteger)index {
    if (index < [_sliceData count]) {
        if (self.allowMultiSelect) {
            IWPieSliceData *data = (IWPieSliceData*)[_sliceData objectAtIndex:index];
            [data setSelected:YES];
        } else {
            NSInteger count = 0;
            for (IWPieSliceData *data in _sliceData) {
                if (count == index)
                    [data setSelected:YES];
                else
                    [data setSelected:NO];
                
                count++;
            }
        }
        
        [self setNeedsDisplay];
    }
}

+ (void)red:(CGFloat)red Green:(CGFloat)green Blue:(CGFloat)blue ToHue:(CGFloat*)hue Saturation:(CGFloat*)saturation Value:(CGFloat*)value {
    CGFloat min, max, delta;
    min = MIN(red, MIN(green, blue));
    *value = max = MAX(red, MAX(red, green));
    delta = max - min;
    
    if (max > 0.0f && delta != 0.0f) {
        *saturation = delta/max;
        
        if (red == max)
            *hue = (green - blue)/delta;
        else if (green == max)
            *hue = 2 + (blue - red)/delta;
        else
            *hue = 4 + (red - green)/delta;
        
        *hue *= 60.0f;
        if (*hue < 0.0f)
            *hue += 360.0f;
    } else {
        // Saturation is 0 so hue is undefined
        *hue = *saturation = 0.0f;
    }
}

- (UIColor*)generateSliceColorWithIndex:(NSInteger)index ofTotal:(NSInteger)total {
    // We generate a new slice color based on the HUE color circle starting from the sliceBaseColor
    // TODO: Update this algorithm to use complementary colors (every second color 180 degree apart)?
    
    // Dont bother generating colors if we only have a single slice
    if (total == 1)
        return self.sliceBaseColor;
    
    if (index == 0)
        return self.sliceBaseColor;
    
    CGColorRef color = self.sliceBaseColor.CGColor;
    CGColorSpaceModel colorSpaceModel = CGColorSpaceGetModel(CGColorGetColorSpace(color));
    if (colorSpaceModel == kCGColorSpaceModelRGB || colorSpaceModel == kCGColorSpaceModelMonochrome) {

        const CGFloat *components = CGColorGetComponents(color);
        CGFloat red, green, blue, alpha;
        
        if (colorSpaceModel == kCGColorSpaceModelMonochrome) {
            red = green = blue = components[0];
        } else {
            red = components[0];
            green = components[1];
            blue = components[2];
        }
        
        alpha = components[CGColorGetNumberOfComponents(color) - 1];
        
        CGFloat hue, saturation, value;
        [IWPieChart red:red Green:green Blue:blue ToHue:&hue Saturation:&saturation Value:&value];
        CGFloat delta = ((float)index/(float)total) * 360.0f;
        hue += delta;
        
        if (hue > 360.f)
            hue -= 360.0f;
        
        return [UIColor colorWithHue:hue/360.0f saturation:saturation brightness:value alpha:alpha];
    } else {
        return self.sliceBaseColor;
    }
}

- (CGFloat)totalPieWeight {
    CGFloat totalWeight = 0.0f;
    for (IWPieSliceData *slice in _sliceData) {
        totalWeight += slice.value;
    }
    
    return totalWeight;
}

- (void)dealloc
{
    [_sliceData release];
    [super dealloc];
}

@end
