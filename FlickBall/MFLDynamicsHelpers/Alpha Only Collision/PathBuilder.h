//
//  PathBuilder.h
//  MagicWand
//
//  Created by Andy Finnell on 8/23/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//


@interface PathBuilder : NSObject {
	// The raw mask data that we were passed as input in our init method
	unsigned char	*mMaskData;
	size_t			mMaskRowBytes;
	size_t			mWidth;
	size_t			mHeight;	
}

- (id) initWithMask:(CGImageRef)mask;

- (UIBezierPath *) path;

@end
