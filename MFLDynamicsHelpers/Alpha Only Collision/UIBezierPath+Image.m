//
//  UIBezierPath+Image.m
//  FlickBall
//
//  Created by teejay on 7/23/13.
//  Copyright (c) 2013 teejay. All rights reserved.
//

#import "UIBezierPath+Image.h"

@implementation UIBezierPath (Image)

- (UIImage*) strokeImageWithColor:(UIColor*)color {
    // adjust bounds to account for extra space needed for lineWidth
    CGFloat width = self.bounds.size.width + self.lineWidth * 2;
    CGFloat height = self.bounds.size.height + self.lineWidth * 2;
    CGRect bounds = CGRectMake(self.bounds.origin.x, self.bounds.origin.y, width, height);
    
    // create a view to draw the path in
    UIView *view = [[UIView alloc] initWithFrame:bounds];
    
    // begin graphics context for drawing
    UIGraphicsBeginImageContextWithOptions(view.frame.size, NO, [[UIScreen mainScreen] scale]);
    
    // configure the view to render in the graphics context
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    
    // get reference to the graphics context
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // reverse the y-axis to match the opengl coordinate space
    CGContextScaleCTM(context, 1, -1);
    CGContextTranslateCTM(context, 0, -view.bounds.size.height);
    
    // translate matrix so that path will be centered in bounds
    CGContextTranslateCTM(context, -(bounds.origin.x - self.lineWidth), -(bounds.origin.y - self.lineWidth));
    
    // set color
    [color set];
    
    // draw the stroke
    [self stroke];
    
    // get an image of the graphics context
    UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
    
    // end the context
    UIGraphicsEndImageContext();
    
    return viewImage;
}

@end
