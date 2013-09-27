//
//  FLBGeometry.m
//  FlickBall
//
//  Created by teejay on 7/29/13.
//  Copyright (c) 2013 teejay. All rights reserved.
//

#import "FLBGeometry.h"

@implementation FLBGeometry

CGPoint midPointOfTwoPoints(CGPoint endPoint1, CGPoint endPoint2)
{
    return CGPointMake((endPoint1.x + endPoint2.x) / 2,
                       (endPoint1.y + endPoint2.y) / 2);

}

UIOffset OffsetOfTwoPoints(CGPoint point1,CGPoint point2)
{
    CGFloat dx = point2.x - point1.x;
    CGFloat dy = point2.y - point1.y;
    return UIOffsetMake(dx, dy);
};

CGFloat DegreesToRadians(CGFloat degrees)
{
    return degrees * M_PI / 180;
};

CGFloat RadiansToDegrees(CGFloat radians)
{
    return radians * 180 / M_PI;
};

CGFloat lengthOfVector(CGSize vector)
{
    return sqrt(vector.width*vector.width + vector.height*vector.height);
};

CGSize normalizeVector(CGSize vector)
{
    CGSize result;
    CGFloat len = lengthOfVector(vector);
    if (len<=0)
        return CGSizeZero;
    result.width = vector.width/len;
    result.height = vector.height/len;
    return result;
}

UIBezierPath* rotatePathAroundCenter(UIBezierPath *path, CGFloat radians)
{
    CGRect rect = CGPathGetBoundingBox(path.CGPath);
    CGPoint center = CGPointMake(rect.origin.x + rect.size.width/2,
                                 rect.origin.y + rect.size.height/2);
 
    return rotatePathAroundPoint(path, radians, center);
}

UIBezierPath* rotatePathAroundPoint(UIBezierPath *path, CGFloat radians, CGPoint anchorPoint)
{
    
    CGAffineTransform move = CGAffineTransformMakeTranslation(anchorPoint.x, anchorPoint.y);
    CGAffineTransform rotateAgain = CGAffineTransformRotate(move, radians);
    CGAffineTransform back = CGAffineTransformTranslate(rotateAgain, -anchorPoint.x, -anchorPoint.y);
    [path applyTransform:back];
    return path;
}


@end
