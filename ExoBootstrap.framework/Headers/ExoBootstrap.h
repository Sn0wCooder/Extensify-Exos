//
//  ExoBootstrap.h
//  ExoBootstrap
//
//  Created by Extensify Team on 2/29/16.
//  Copyright (c) 2016 Extensify. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NSObject (ExoBootstrap)

+ (BOOL)changeMethod:(SEL)origSel_ withMethod:(SEL)altSel_ error:(NSError**)error_;
+ (BOOL)changeMethodStatic:(SEL)origSel_ withMethod:(SEL)altSel_ error:(NSError**)error_;

@end


//
// Usage: ExoHook(class, orig_method, prefix)
// class: NSString of class name
// orig_method: name of original method
// prefix: prefix of your new method you're replacing orig_method with
//
// example: original method called 'someMethod', prefix is 'exoBeta', your new method would be called 'exoBeta_someMethod'

#define ExoHook(class, method, prefix) [NSClassFromString(class) changeMethod:NSSelectorFromString(method) withMethod:NSSelectorFromString([NSString stringWithFormat:@"%@_%@", prefix, method]) error:nil];

id ExoHookIvar(id object, NSString *ivarPath);
NSString *deviceIdentifier();

//! Project version number for ExoBootstrap.
FOUNDATION_EXPORT double ExoBootstrapVersionNumber;

//! Project version string for ExoBootstrap.
FOUNDATION_EXPORT const unsigned char ExoBootstrapVersionString[];
