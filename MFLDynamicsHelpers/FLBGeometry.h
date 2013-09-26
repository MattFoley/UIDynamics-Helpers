//
//  FLBGeometry.h
//  FlickBall
//
//  Created by teejay on 7/29/13.
//  Copyright (c) 2013 teejay. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FLBGeometry : NSObject

UIOffset OffsetOfTwoPoints(CGPoint point1,CGPoint point2);

CGFloat RadiansToDegrees(CGFloat radians);
CGFloat DegreesToRadians(CGFloat degrees);

CGSize normalizeVector(CGSize vector);
CGFloat lengthOfVector(CGSize vector);

UIBezierPath* rotatePathAroundCenter(UIBezierPath *path, CGFloat radians);
UIBezierPath* rotatePathAroundPoint(UIBezierPath *path, CGFloat radians, CGPoint anchorPoint);
CGPoint midPointOfTwoPoints(CGPoint endPoint1, CGPoint endPoint2);

@end
