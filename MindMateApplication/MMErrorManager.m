//
//  MMErrorManager.m
//  MindMateApplication
//
//  Created by Roger Luan on 24/01/17.
//  Copyright © 2017 Roger Oba. All rights reserved.
//

#import "MMErrorManager.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>

@implementation MMErrorManager
+ (NSError *)errorForErrorIdentifier:(MMErrorIdentifier)errorIdentifier {
    return [NSError errorWithDomain:[[NSBundle mainBundle] bundleIdentifier]
                               code:errorIdentifier
                           userInfo:[self userInfoForErrorIdentifier:errorIdentifier]];
}

+ (UIAlertController *)alertFromError:(NSError *)error {
    NSLog(@"An error occured. Error description: %@ Possible failure reason: %@ Possible recovery suggestion: %@\n\nFull error: %@", error.localizedDescription, error.localizedFailureReason, error.localizedRecoverySuggestion, error);
    
    NSString *alertTitle;
    NSString *alertMessage;
    UIAlertController *alert;
    UIAlertAction *cancelAction;
    
#ifdef DEBUG
    if ([self errorHasFriendlyMessage:error]) { //if it's a general error, display generic message
        NSDictionary *friendlyMessage = [self friendlyMessageFromError:error];
        alertTitle = friendlyMessage[NSLocalizedDescriptionKey];
        alertMessage = friendlyMessage[NSLocalizedFailureReasonErrorKey];
    } else {
        alertTitle = error.localizedDescription;
        alertMessage = error.localizedFailureReason;
    }
#else
    if ([error.domain isEqualToString:[[NSBundle mainBundle] bundleIdentifier]]) { //if it's an error generated by GP
        alertTitle = error.localizedDescription;
        alertMessage = error.localizedFailureReason;
    } else if ([self errorHasFriendlyMessage:error]) { //if it's a general error, display generic message
        NSDictionary *friendlyMessage = [self friendlyMessageFromError:error];
        alertTitle = friendlyMessage[NSLocalizedDescriptionKey];
        alertMessage = friendlyMessage[NSLocalizedFailureReasonErrorKey];
    } else {
        alertTitle = NSLocalizedString(@"An Error Occured", @"MMErrorManager User Alert Title");
        alertMessage = NSLocalizedString(@"Unfortunately an error occurred. Sorry for the inconvenience. Please try again later.", @"MMErrorManager User Alert Message");
    }
#endif
    
    alert = [UIAlertController alertControllerWithTitle:alertTitle message:alertMessage preferredStyle:UIAlertControllerStyleAlert];
    cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", @"OK") style:UIAlertActionStyleDefault handler:nil];
    [alert addAction:cancelAction];
    
    return alert;
}

+ (UIAlertController *)alertFromErrorIdentifier:(NSInteger)errorIdentifier {
    return [self alertFromError:[self errorForErrorIdentifier:errorIdentifier]];
}

#pragma mark - Helpers

+ (NSDictionary *)userInfoForErrorIdentifier:(MMErrorIdentifier)error {
    switch (error) {
        case MMErrorSocialLoginEventCancelled: //this error shouldn't be displayed to users
            return @{NSLocalizedDescriptionKey: NSLocalizedString(@"Social Login Cancelled", nil),
                     NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"The login was cancelled upon user request.", nil)
                     };
        case MMErrorPermissionsDenied:
            return @{NSLocalizedDescriptionKey: NSLocalizedString(@"Permissions Denied", nil),
                     NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"Unfortunately, you denied one or more of the permissions needed in order to operate in this app. We cannot proceed unless you approve them.", nil)
                     };
    }
}

+ (BOOL)errorHasFriendlyMessage:(NSError *)error {
    return [self friendlyMessageFromError:error] ? YES : NO;
}

+ (NSDictionary *)friendlyMessageFromError:(NSError *)error {
    if ([error.domain isEqual:FBSDKErrorDomain]) {
        if (error.userInfo[FBSDKErrorLocalizedTitleKey] && error.userInfo[FBSDKErrorLocalizedDescriptionKey]) {
            return @{NSLocalizedDescriptionKey: error.userInfo[FBSDKErrorLocalizedTitleKey],
                     NSLocalizedFailureReasonErrorKey: error.userInfo[FBSDKErrorLocalizedDescriptionKey]
                     };
        } else {
            return nil;
        }
    }
    return nil;
}

@end