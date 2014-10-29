//
//  KIFTypist.m
//  KIF
//
//  Created by Pete Hodgson on 8/12/12.
//  Licensed to Square, Inc. under one or more contributor license agreements.
//  See the LICENSE file distributed with this work for the terms under
//  which Square, Inc. licenses this file to you.

#import "KIFTypist.h"
#import "UIApplication-KIFAdditions.h"
#import "UIView-KIFAdditions.h"
#import "CGGeometry-KIFAdditions.h"
#import "UIAccessibilityElement-KIFAdditions.h"

@interface UIKeyboardImpl : NSObject
+ (UIKeyboardImpl *)sharedInstance;
- (void)addInputString:(NSString *)string;
- (void)deleteBackward;
@end

static NSTimeInterval keystrokeDelay = 0.0f;

@interface KIFTypist()
@property (nonatomic, assign) BOOL keyboardHidden;
@end

@implementation KIFTypist

+ (KIFTypist *)sharedTypist
{
    static dispatch_once_t once;
    static KIFTypist *sharedObserver = nil;
    dispatch_once(&once, ^{
        sharedObserver = [[self alloc] init];
    });
    return sharedObserver;
}

+ (void)registerForNotifications {
    [[self sharedTypist] registerForNotifications];
}

- (instancetype)init
{
    if ((self = [super init])) {
        self.keyboardHidden = YES;
    }
    return self;
}

- (void)registerForNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShowNotification:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHideNotification:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)keyboardDidShowNotification:(NSNotification *)notification
{
    self.keyboardHidden = NO;
}

- (void)keyboardWillHideNotification:(NSNotification *)notification
{
    self.keyboardHidden = YES;
}

+ (BOOL)keyboardHidden
{
    return [self sharedTypist].keyboardHidden;
}

+ (NSString *)_representedKeyboardStringForCharacter:(NSString *)characterString;
{
    // Interpret control characters appropriately
    if ([characterString isEqual:@"\b"]) {
        characterString = @"Delete";
    }
    
    return characterString;
}

+ (BOOL)enterCharacter:(NSString *)characterString;
{
    if ([characterString isEqualToString:@"\b"]) {
        [[UIKeyboardImpl sharedInstance] deleteBackward];
    } else {
        [[UIKeyboardImpl sharedInstance] addInputString:characterString];
    }
    
    CFRunLoopRunInMode(kCFRunLoopDefaultMode, keystrokeDelay, false);
    return YES;
}

+ (void)setKeystrokeDelay:(NSTimeInterval)delay
{
    keystrokeDelay = delay;
}

@end
