//
//  MFLAlphaCollision.m
//  FlickBall
//
//  Created by teejay on 7/23/13.
//  Copyright (c) 2013 teejay. All rights reserved.
//

#import "MFLAlphaCollision.h"
#import "PathBuilder.h"
#import "UIImage+Rotate.h"

@implementation MFLAlphaCollision

+ (void)addBoundaryToBehavior:(UICollisionBehavior*)behavior
                     withView:(UIView*)view
                forIdentifier:(NSString *)identifier
{
    UIGraphicsBeginImageContextWithOptions(view.frame.size, NO, 0.0f);
    [view drawViewHierarchyInRect:CGRectMake(0, 0, view.bounds.size.width, view.bounds.size.height) afterScreenUpdates:YES];
    UIImage *layerImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    UIImage *flippedImage = [layerImage imageRotatedByDegrees:180];
    
    UIBezierPath *viewPath = [[[PathBuilder alloc] initWithMask:flippedImage.CGImage] path];
    [viewPath applyTransform:CGAffineTransformMakeTranslation(view.frame.origin.x, view.frame.origin.y)];
    [behavior addBoundaryWithIdentifier:identifier forPath:viewPath];
}

+ (void)addBoundaryToBehavior:(UICollisionBehavior*)behavior
                withImageView:(UIImageView*)imageView
                forIdentifier:(NSString *)identifier
{
    
    UIImage *flippedImage = [imageView.image imageRotatedByDegrees:180];
    
    UIBezierPath *viewPath = [[[PathBuilder alloc] initWithMask:flippedImage.CGImage] path];
    [viewPath applyTransform:CGAffineTransformMakeTranslation(imageView.frame.origin.x, imageView.frame.origin.y)];
    [behavior addBoundaryWithIdentifier:identifier forPath:viewPath];
}

@end
