//
//  MFLBoundaryPreview.h
//  FlickBall
//
//  Created by teejay on 7/30/13.
//  Copyright (c) 2013 teejay. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MFLBoundaryPreviewDelegate <NSObject>

@property UICollisionBehavior *collisionBehavior;

@end

@interface MFLBoundaryPreview : UIView

@property (weak) IBOutlet id<MFLBoundaryPreviewDelegate> delegate;

@end
