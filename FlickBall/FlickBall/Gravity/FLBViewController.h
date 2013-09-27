//
//  FLBViewController.h
//  FlickBall
//
//  Created by teejay on 7/22/13.
//  Copyright (c) 2013 teejay. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FLBViewController : UIViewController <UIAccelerometerDelegate>

@property IBOutletCollection(UIImageView) NSMutableArray *flickViews;

@property NSMutableArray *pointsArray; 

@property UIDynamicAnimator *animator;
@property UIPushBehavior *devicePush;
@property UICollisionBehavior *collisionBehavior;

@property UIPushBehavior *flickPush;
@property UIGravityBehavior *gravity;

- (void)basicsSetup;
- (void)addBehaviors;
- (void)addSomeItems;
- (void)randomizeProperties;

- (IBAction)handleRotate:(UIRotationGestureRecognizer*)gesture;
- (IBAction)handlePan:(UIPanGestureRecognizer*)gesture;

@end
