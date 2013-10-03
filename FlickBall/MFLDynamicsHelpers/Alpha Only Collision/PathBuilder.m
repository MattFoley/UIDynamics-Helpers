//
//  PathBuilder.m
//  MagicWand
//
//  Created by Andy Finnell on 8/23/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "PathBuilder.h"

@interface PathBuilder (Private)

- (NSMutableDictionary*) buildLineSegments;
- (void) insertLineStart:(CGPoint)start end:(CGPoint)end intoDictionary:(NSMutableDictionary*)segments;
- (UIBezierPath *) convertSegmentsIntoPath:(NSMutableDictionary*)segments;
- (void) unwindOneSegmentPath:(NSMutableDictionary*)segments intoPath:(UIBezierPath *)path;
- (void) removeSegment:(NSArray*)segment fromSegmentPath:(NSMutableDictionary*)segments;

- (void) addPoint:(CGPoint)newPoint toPath:(UIBezierPath *)path cachedPoint1:(CGPoint*)point1 cachedPoint2:(CGPoint*)point2;
- (void) flushPath:(UIBezierPath *)path cachedPoint1:(CGPoint*)point1 cachedPoint2:(CGPoint*)point2;

@end

@implementation PathBuilder

- (id) initWithMask:(CGImageRef)mask
{
	self = [super init];
	
	if ( self != nil ) {
		// CGImageRef doesn't allow use to easily grab the pixels and walk them
		//	manually (which is what we want to do). So we're going to create
		//	a grayscale CGBitmapContext, use the mask to draw white pixels in
		//	the area defined by the mask. Then we'll release the bitmap context
		//	but keep the raw mask pixels around to parse through.
		
		// Grab the size of the mask, so we know how big to make our bitmap
		//	context.
		mWidth = CGImageGetWidth(mask);
		mHeight = CGImageGetHeight(mask);
		
		// Allocate space for our mask data. Calloc will zero out the data so
		//	all pixels will be black by default.
		mMaskRowBytes = (mWidth + 0x0000000F) & ~0x0000000F;
		mMaskData = calloc(mHeight, mMaskRowBytes);

		// Create a grayscale bitmap context the size of the mask
		CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceGray();
		CGContextRef bitmapContext  = CGBitmapContextCreate(mMaskData, mWidth, mHeight, 8, mMaskRowBytes, colorspace, kCGImageAlphaNone);
		CGColorSpaceRelease(colorspace);
		
		// Clip out everything not selected by the mask, then draw a white rectangle
		//	so we know the pixels defined by the mask.
		CGRect maskRect = CGRectMake(0, 0, mWidth, mHeight);
		CGContextClipToMask(bitmapContext, maskRect, mask);
		CGContextSetGrayFillColor(bitmapContext, 1.0, 1.0);
		CGContextFillRect(bitmapContext, maskRect);
		
		// Don't need the context anymore, we just wanted the pixels
		CGContextRelease(bitmapContext);
	}
	
	return self;
}

- (void) dealloc 
{
	// Free up our mask data
	free(mMaskData);
}

- (UIBezierPath *) path
{
	// This method invokes two methods that will build a bounding path around
	//	a bitmap mask. First, it parses the mask data to build up a dictionary
	//	of line segments. Second, in takes all those line segments, and converts
	//	then into a bezier path.
	NSMutableDictionary* segments = [self buildLineSegments];
	
	return [self convertSegmentsIntoPath:segments];
}

@end

@implementation PathBuilder (Private)

- (NSMutableDictionary*) buildLineSegments
{
	// The purpose of this function is to simply walk the mask and determine where
	//	the bounding line segments of the path should go. It does not attempt
	//	to make sure they are in order or connected.
	
	// It examines each pixel. If the pixel is in the mask (not black), then it
	//	looks at the pixels to the left, right, above, and below the pixel. For each of those
	//	pixels around the current pixel that is not in the mask (black) it adds a
	//	line segment on that side to the dictionary.
	
	// The dictionary that is return maps pixel locations to line segments, so they
	//	can be easily connect later on. For example, the line segment [(20, 15), (21, 15)]
	//	would appear in the dictionary twice: at the key (20, 15) and the key (21, 15).
	
	// Create a dictionary for all these line segments, keyed on the points that make
	//	up the segment.
	NSMutableDictionary* segments = [@{} mutableCopy];
	
	// This loop straight up hits every pixel in the mask in row major order
	int row = 0;
	for (row = 0; row < mHeight; ++row) {
		int col = 0;
		
		unsigned char *rowPixels = mMaskData + (row * mMaskRowBytes);
		
		for (col = 0; col < mWidth; ++col) {
			if ( rowPixels[col] != 0x00 ) {
				// This pixel is on, check all around us to see if we're bounded
				//	anywhere.
				
				// Bounded on the left
				if ( col == 0 || rowPixels[col - 1] == 0x00 ) 
					[self insertLineStart: CGPointMake(col, row) end: CGPointMake(col, row + 1) intoDictionary:segments];
				
				// Bounded on the right
				if ( col == (mWidth - 1) || rowPixels[col + 1] == 0x00 )
					[self insertLineStart: CGPointMake(col + 1, row) end: CGPointMake(col + 1, row + 1) intoDictionary:segments];

				// Bounded on the top
				if ( row == 0 || *(rowPixels + col - mMaskRowBytes) == 0x00 )
					[self insertLineStart: CGPointMake(col, row) end: CGPointMake(col + 1, row) intoDictionary:segments];

				// Bounded on the bottom
				if ( row == (mHeight - 1) || *(rowPixels + col + mMaskRowBytes) == 0x00 )
					[self insertLineStart: CGPointMake(col, row + 1) end: CGPointMake(col + 1, row + 1) intoDictionary:segments];
			}
		}
	}
	
	// Return the unsorted segments
	return segments;
}

- (void) insertLineStart:(CGPoint)start end:(CGPoint)end intoDictionary:(NSMutableDictionary*)segments
{
	// This function takes the raw points of a segment and ensures that the segment
	//	is correct inserted into the segments dictionary. This includes building
	//	the keys for the start and end point, and inserting the segment twice; Once
	//	for the start point, and again for the end point.
	// Since all the lines will eventually connect, more than one segment will
	//	map to a given point, or entry in the dictionary. For that reason, the
	//	value in the dictionary is actually an array of line segments.
	
	// Convert from top, left origin to bottom, left origin (bitmap to CG coords)
	CGPoint startPoint = CGPointMake(start.x, mHeight - start.y - 1);
	CGPoint endPoint = CGPointMake(end.x, mHeight - end.y - 1);

	// Pull out the values that will go in the dictionary
	NSString *startKey = NSStringFromCGPoint(startPoint);
	NSString *endKey = NSStringFromCGPoint(endPoint);
	NSArray *segment = @[startKey, endKey];
	
	// Add the segment to the dictionary for the start point. If a segment
	//	array isn't already at the specified point, add it.
	NSMutableArray *segmentsAtStart = [segments objectForKey:startKey];
	if ( segmentsAtStart == nil ) {
		segmentsAtStart = [@[] mutableCopy];
		[segments setObject:segmentsAtStart forKey:startKey];
	}
	[segmentsAtStart addObject:segment];
	
	// Add the segment to the dictionary for the end point. If a segment
	//	array isn't already at the specified point, add it.
	NSMutableArray *segmentsAtEnd = [segments objectForKey:endKey];
	if ( segmentsAtEnd == nil ) {
		segmentsAtEnd = [@[] mutableCopy];
		[segments setObject:segmentsAtEnd forKey:endKey];
	}
	[segmentsAtEnd addObject:segment];
}

- (UIBezierPath *) convertSegmentsIntoPath:(NSMutableDictionary*)segments
{
	// This method walks through the line segments dictionary constructing
	//	bezier paths. As a line segment is transversed, it is removed from
	//	the dictionary so that it isn't used again. Since there can be
	//	more than one closed path, continue even after one path is complete,
	//	until all line segments have been consumed.
	
	UIBezierPath *path = [UIBezierPath bezierPath];
	[path setLineJoinStyle:kCGLineJoinRound];
	// While we still have line segments to consume, unwind one bezier path
	while ( [segments count] > 0 )
		[self unwindOneSegmentPath:segments intoPath:path];
	
	return path;
}

- (void) unwindOneSegmentPath:(NSMutableDictionary*)segments intoPath:(UIBezierPath *)path
{
	// This method will grab the first line segment it can find, then unwind it
	//	into a bezier path. Since all the line segments are key on the points
	//	the start and stop at, it is fairly trivial to connect them.
	
	// The algorithm is:
	//	1. Given a point, look up the array of segments that have end points there
	//	2. Grab the first segment in the array
	//	3. Draw a line to point in the line segment, that we weren't given
	//	4. Remove the line segment from the dictionary, so we don't process it again
	//	5. Go back to 1, with the point we just drew a line to as the given point
	
	// There is also an optimization so that we don't add 1 pixel line segments
	//	unless we have to. It accumulates the start and end points until the
	//	path changes direction. At the time, it flushes out the line segment
	//	to the path, and adds the new point to the cache.
	
	// Just pick the first key to start with. It might be slightly better if
	//	we could pick a corner to start at, so we create the path with fewer
	//	segments. But the cost of finding a corner might negate any gain.
	NSEnumerator *keyEnumerator = [segments keyEnumerator];
	NSString *key = [keyEnumerator nextObject];
	NSMutableArray *segmentsAtPoint = nil;
	
	// Start the path off. The rest of the path additions will be simple lineTo's
	CGPoint pathStartPoint = CGPointFromString(key);
	[path moveToPoint: pathStartPoint];
	
	// The cached points are used to accumulate lines so we don't insert
	//	tons of 1 pixel lines, but one large line.
	CGPoint cachedPoint1 = pathStartPoint;
	CGPoint cachedPoint2 = pathStartPoint;
	
	// While we haven't reach the end of the path. At the end of the path
	//	we would normally connect back up with the start. But since we
	//	remove line segments as we process them, it won't be in the map. That's
	//	our indication to stop.
    segmentsAtPoint = [segments objectForKey:key];
    
	while ( segmentsAtPoint ) {
		// Convert the key to a CGPoint so we know the point the line segments
		//	connect at.
		CGPoint connectPoint = CGPointFromString(key);
				
		// It really doesn't matter which segment in this array we pick, but
		//	it's guaranteed to have at least one, and the first is always the
		//	easiest to pick. Convert its end points to real points so we can
		//	compare.
		NSArray *firstSegment = [segmentsAtPoint objectAtIndex:0];
		CGPoint segmentStartPoint = CGPointFromString([firstSegment objectAtIndex:0]);
		CGPoint segmentEndPoint = CGPointFromString([firstSegment objectAtIndex:1]);
		
		// See which point in this segment we've already visited. Draw a line
		//	to the end point we haven't visited, and make it the next key
		//	we visit in the dictionary.
		if ( CGPointEqualToPoint(connectPoint, segmentStartPoint) ) {
			// We've alreay hit the start point, so add the end point to the path
			[self addPoint:segmentEndPoint toPath:path cachedPoint1:&cachedPoint1 cachedPoint2:&cachedPoint2];
			key = NSStringFromCGPoint(segmentEndPoint);
		} else {
			// We've alreay hit the end point, so add the start point to the path
			[self addPoint:segmentStartPoint toPath:path cachedPoint1:&cachedPoint1 cachedPoint2:&cachedPoint2];
			key = NSStringFromCGPoint(segmentStartPoint);
		}
		
		// It's very important that we remove the line segment from the dictionary
		//	completely so we don't loop back on ourselves or not ever finish.
		[self removeSegment:firstSegment fromSegmentPath:segments];
        
        segmentsAtPoint = [segments objectForKey:key];
	}
	
	// Since we were caching line segments to write out the biggest line segments
	//	possible, we need to flush the last one out to the bezier path.
	[self flushPath:path cachedPoint1:&cachedPoint1 cachedPoint2:&cachedPoint2];

	// Close up the sub path, so that the end point connects with the start point.
	[path closePath];
}

- (void) removeSegment:(NSArray*)segment fromSegmentPath:(NSMutableDictionary*)segments
{
	// This method removes the specified line segment from the dictionary. Every
	//	line segment is in the dictionary twice (at the start point and the end point)
	//	so remove it at both locations.
	
	// Look up both start and end points, and remove them from their respective arrays
	NSString* startKey = [segment objectAtIndex:0];
	NSString* endKey = [segment objectAtIndex:1];
	
	NSMutableArray *segmentsAtStart = [segments objectForKey:startKey];
	NSMutableArray *segmentsAtEnd = [segments objectForKey:endKey];

	if ( [segmentsAtStart count] == 1 )
		[segments removeObjectForKey:startKey]; // last one, so kill entire array
	else
		[segmentsAtStart removeObject:segment]; // just remove use from this array
	
	if ( [segmentsAtEnd count] == 1 )
		[segments removeObjectForKey:endKey]; // last one, so kill entire array
	else
		[segmentsAtEnd removeObject:segment]; // just remove use from this array
}

- (void) addPoint:(CGPoint)newPoint toPath:(UIBezierPath *)path cachedPoint1:(CGPoint*)point1 cachedPoint2:(CGPoint*)point2
{
	// This method examines the current line segment to determine if it's part
	//	of the currently building large line segment. If it is, we just make it
	//	the new end point. If it represents a change in direction, then we
	//	flush the current large line segment out to the path, and create a new
	//	line segment with the old end point and the new point.
	
	// Check for the special case of the path start point. In that case, just
	//	make the new point the new end point of the current line segment.
	if ( CGPointEqualToPoint(*point1, *point2) ) {
		*point2 = newPoint;
		return;
	}
		
	// If we're not changing direction, then just extend the line
	if ( (point1->x == point2->x && point2->x == newPoint.x) || (point1->y == point2->y && point2->y == newPoint.y) ) {
		*point2 = newPoint;
	} else {
		// We changed direction, so flush the current segment, and reset the cache
		[path addQuadCurveToPoint:*point2 controlPoint:*point1];
		
		*point1 = *point2;
		*point2 = newPoint;		
	}	
}

- (void) flushPath:(UIBezierPath *)path cachedPoint1:(CGPoint*)point1 cachedPoint2:(CGPoint*)point2
{
	// Just add the last line to the path.
	[path addLineToPoint:*point2];
}

@end
