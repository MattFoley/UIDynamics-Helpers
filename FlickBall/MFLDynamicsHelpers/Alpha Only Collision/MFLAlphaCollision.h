//
//  MFLAlphaCollision.h
//  FlickBall
//
//  Created by teejay on 7/23/13.
//  Copyright (c) 2013 teejay. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MFLAlphaCollision : UICollisionBehavior

+ (void)addBoundaryToBehavior:(UICollisionBehavior*)behavior
                withImageView:(UIImageView*)imageView
                forIdentifier:(NSString *)identifier;

+ (void)addBoundaryToBehavior:(UICollisionBehavior*)behavior
                     withView:(UIView*)view
                forIdentifier:(NSString *)identifier;


@end
