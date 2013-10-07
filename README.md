UIDynamics-Helpers
==================

This repository is filled with helping code for UIDynamics stuff. All of the UIDynamics Helpers are housed in the top level "MFLDynamicsHelpers" folder, and their are use examples throughout.


###MFLAlphaCollision - Image To Boundary - Alpha Only Collisions

This class will help you create a boundary behavior for any arbitrary image. It will trace any non zero alpha pixels in an image, and then construct a UIBezierPath from the result to use as a boundary.

         [MFLAlphaCollision addBoundaryToBehavior:self.collisionBehavior
                                    withImageView:self.boundaryImageView
                                    forIdentifier:@"someIdentifier"];
                               
OR

         [MFLAlphaCollision addBoundaryToBehavior:self.collisionBehavior
                                         withView:self.complicatedView
                                    forIdentifier:@"someIdentifier"];

###MFLBoundaryPreview - Trace Boundaries

This class will allow you to trace all on screen boundaries simply and easily to make it much easier to test your path drawing. 

To begin tracing all of your boundaries, change the class of your UIView to MFLBoundaryPreview and set your view's MFLBoundaryPreviewDelegate to your UIViewController, ensuring it has a property named *collisionBehavior*. 


Thanks to Andy Finnell for his Magic Wand implementation for inspiration: http://losingfight.com/blog/2007/08/28/how-to-implement-a-magic-wand-tool/


###Shameless Self Promotion
Consider this repository under the Beerware License, of which I will collect on if you're ever in Chicago. If you feel like showing your appreciation, drop me a couple bucks at the Binpress page for this control: http://www.binpress.com/app/uidynamics-helpers/1643
