//
//  AsyncDisplayMacros.h
//  sources
//
//  Created by Phu on 1/26/17.
//
//

#ifndef AsyncDisplayMacros_h
#define AsyncDisplayMacros_h

#ifdef __OBJC__
#import <Foundation/Foundation.h>
#endif

// CocoaPods has a preproceessor macro for PIN_REMOTE_IMAGE, if already defined, okay
#ifndef PIN_REMOTE_IMAGE

// For Carthage or manual builds, this will define PIN_REMOTE_IMAGE if the header is available in the
// search path e.g. they've dragged in the framework (technically this will not be able to detect if
// a user does not include the framework in the link binary with build step).
//#define PIN_REMOTE_IMAGE __has_include(<PINRemoteImage/PINRemoteImage.h>)
#define PIN_REMOTE_IMAGE 0
#define PIN_ANIMATED_AVAILABLE 0

#endif


#endif /* AsyncDisplayMacros_h */
