//
//  UIBezierPath+Image.h
//  FlickBall
//
//  Created by teejay on 7/23/13.
//  Copyright (c) 2013 teejay. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIBezierPath (Image)

/** Returns an image of the path drawn using a stroke */
- (UIImage*) strokeImageWithColor:(UIColor*)color;

@end
