//
//  MFLBoundaryPreview.m
//  FlickBall
//
//  Created by teejay on 7/30/13.
//  Copyright (c) 2013 teejay. All rights reserved.
//

#import "MFLBoundaryPreview.h"

@implementation MFLBoundaryPreview

- (void)drawRect:(CGRect)rect {
    // Drawing code
    NSArray *paths = [self.delegate.collisionBehavior boundaryIdentifiers];

    CGContextSetStrokeColorWithColor(UIGraphicsGetCurrentContext(), [UIColor blackColor].CGColor);
    for(id<NSCopying> pathId in paths)
    {
        UIBezierPath *path = [self.delegate.collisionBehavior boundaryWithIdentifier:pathId];
        [path stroke];
    }
}


@end
