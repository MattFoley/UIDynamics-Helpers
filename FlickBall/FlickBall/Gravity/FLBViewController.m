//
//  FLBViewController.m
//  FlickBall
//
//  Created by teejay on 7/22/13.
//  Copyright (c) 2013 teejay. All rights reserved.
//

#import "FLBViewController.h"
#import <CoreMotion/CoreMotion.h>
#import "PathBuilder.h"
#import "UIBezierPath+Image.h"
#import "MFLAlphaCollision.h"

@interface FLBViewController ()

@property (weak) IBOutlet UIImageView *starBoundaryImage;
@property CMMotionManager *motionManager;

@end

@implementation FLBViewController

- (void)viewDidLoad
{
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"apple_linen"]]];
    
    CGImageRef cgImage = [self.flickViews[0] image].CGImage;
    UIBezierPath *ballPath = [[[PathBuilder alloc] initWithMask:cgImage] path];
    UIImage *ballPathImage = [ballPath strokeImageWithColor:[UIColor blackColor]];
    [self.flickViews[0] setImage:ballPathImage];
    
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidAppear:(BOOL)animated
{
    [self physicsSetup];
    [self accelerometerAction];
    
    self.flickViews = [NSMutableArray arrayWithArray:self.flickViews];
    self.pointsArray = [[self.flickViews valueForKeyPath:@"center"] mutableCopy];
}


- (void)basicsSetup
{
    //Let's make an animator
    UIDynamicAnimator* animator = [[UIDynamicAnimator alloc] initWithReferenceView:self.view];
    self.animator = animator;
    
    //And we'll need some walls
    UICollisionBehavior* collisionBehavior = [[UICollisionBehavior alloc] initWithItems:self.flickViews];
    [collisionBehavior setCollisionMode:UICollisionBehaviorModeBoundaries];
    collisionBehavior.translatesReferenceBoundsIntoBoundary = YES;

    [MFLAlphaCollision addBoundaryToBehavior:collisionBehavior
                               withImageView:self.starBoundaryImage
                               forIdentifier:@"starBoundary"];
    
    self.collisionBehavior = collisionBehavior;
    [self.animator addBehavior:collisionBehavior];
    
    [self.view setNeedsDisplay];
    
}


- (void)physicsSetup
{
    [self basicsSetup];
    
    //Then some gravity
    UIGravityBehavior* gravityBeahvior = [[UIGravityBehavior alloc] initWithItems:self.flickViews];
    self.gravity = gravityBeahvior;
    
    
    self.flickPush = [[UIPushBehavior alloc] initWithItems:self.flickViews mode:UIPushBehaviorModeInstantaneous];
    [self.animator addBehavior:self.flickPush];
}


- (void)accelerometerAction
{

    self.motionManager = [[CMMotionManager alloc] init];
    [self.motionManager setDeviceMotionUpdateInterval:1];
    [self.motionManager startDeviceMotionUpdates];
    
    [self.motionManager startGyroUpdatesToQueue:[NSOperationQueue mainQueue]
                                    withHandler:^(CMGyroData *gyroData, NSError *error) {
                                        CMAttitude *deviceAttitude = self.motionManager.deviceMotion.attitude;
                                        [self.gravity setGravityDirection:CGVectorMake(deviceAttitude.roll*5,deviceAttitude.pitch*5)];
                                    }];
    [self.motionManager startAccelerometerUpdatesToQueue:[NSOperationQueue mainQueue]
                                             withHandler:^(CMAccelerometerData *accelerometerData, NSError *error) {

                                                 if(accelerometerData.acceleration.y > 0 &&
                                                    accelerometerData.acceleration.x > 0) {
                                                     NSLog(@"Push again: %f %f %f", accelerometerData.acceleration.x,
                                                           accelerometerData.acceleration.y,
                                                           accelerometerData.acceleration.z);
                                                     
                                                     [self.flickPush setPushDirection:CGVectorMake(accelerometerData.acceleration.x/10,
                                                                                                   -accelerometerData.acceleration.y/10)];
                                                     [self.flickPush setActive:TRUE];
                                                 }
                                             }];
}

- (IBAction)handleRotate:(UIRotationGestureRecognizer*)gesture
{
    
}

- (IBAction)handlePan:(UIPanGestureRecognizer*)gesture
{
    if (gesture.state == UIGestureRecognizerStateEnded) {
        [self.gravity setGravityDirection:CGVectorMake(self.gravity.gravityDirection.dx, 1.0)];
    } else {
        
        [self.flickPush setPushDirection:CGVectorMake(0, 0)];
        [self.gravity setGravityDirection:CGVectorMake(self.gravity.gravityDirection.dx, 0)];
    }
    
    CGPoint velocityPoint = [gesture velocityInView:self.view];
    [self.flickPush setPushDirection:CGVectorMake(velocityPoint.x/2000, velocityPoint.y/2000)];
    
    [self.flickPush setActive:TRUE];
}

- (void)randomizeProperties
{
    [self.flickViews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [obj setCenter:[self.pointsArray[idx] CGPointValue] ];
        
        UIDynamicItemBehavior *dynamicBehavior = [[UIDynamicItemBehavior alloc] initWithItems:@[obj]];
        [dynamicBehavior setDensity:arc4random()%20/10.0];
        [dynamicBehavior setElasticity:arc4random()%5/10.0 +.5];
        [dynamicBehavior setFriction:arc4random()%20/10.0];
        [dynamicBehavior setResistance:arc4random()%8/10.0];
        [dynamicBehavior addAngularVelocity:arc4random()%20/10.0 forItem:obj];
        
        [self.animator addBehavior:dynamicBehavior];
    }];
    
}

- (void)addSomeItems
{
    for (int i = 0; i < 10; i++) {
        UIImageView *ball = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"pokeball_phone"]];
        [ball setFrame:CGRectMake(250, 250,
                                  [self.flickViews[0] frame].size.width,
                                  [self.flickViews[0] frame].size.height)];
        [self.view addSubview:ball];
        [ball setContentMode:UIViewContentModeScaleAspectFill];
        [self.flickViews addObject:ball];
        [self.collisionBehavior addItem:ball];
        [self.gravity addItem:ball];
        [self.flickPush addItem:ball];
        [self.pointsArray addObject:[NSValue valueWithCGPoint:ball.center]];
    }
    
    [MFLAlphaCollision addBoundaryToBehavior:self.collisionBehavior
                               withView:self.starBoundaryImage
                               forIdentifier:@"starBoundary"];
}

- (IBAction)resetPosition:(id)sender
{
    [self.animator removeAllBehaviors];
    [self addSomeItems];
    [self randomizeProperties];
    [self addBehaviors];
    
    NSLog(@"Item count %d", self.flickViews.count);
}

- (void)addBehaviors
{
    [self.animator addBehavior:self.collisionBehavior];
    [self.animator addBehavior:self.gravity];
    [self.animator addBehavior:self.flickPush];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
