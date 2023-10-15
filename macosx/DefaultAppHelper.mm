// This file Copyright © 2007-2023 Transmission authors and contributors.
// It may be used under the MIT (SPDX: MIT) license.
// License text can be found in the licenses/ folder.

#import "DefaultAppHelper.h"

#import <AppKit/AppKit.h>
#import <UniformTypeIdentifiers/UniformTypeIdentifiers.h>

static NSString* const kMagnetURLScheme = @"magnet";
static NSString* const kTorrentFileType = @"org.bittorrent.torrent";

UTType* GetTorrentFileType(void) API_AVAILABLE(macos(11.0))
{
    static UTType* result = nil;

    static dispatch_once_t once;
    dispatch_once(&once, ^{
        result = [UTType exportedTypeWithIdentifier:kTorrentFileType conformingToType:UTTypeData];
    });

    return result;
}

@interface DefaultAppHelper ()

@property(nonatomic, readonly) NSString* bundleIdentifier;

@end

@implementation DefaultAppHelper

- (instancetype)init
{
    if (self = [super init])
    {
        _bundleIdentifier = NSBundle.mainBundle.bundleIdentifier;
    }
    return self;
}

- (BOOL)isDefaultForTorrentFiles
{
    if (@available(macOS 12, *))
    {
        UTType* file_type = GetTorrentFileType();
        NSURL* app_url = [NSWorkspace.sharedWorkspace URLForApplicationToOpenContentType:file_type];
        if (!app_url)
        {
            return NO;
        }

        NSString* bundle_id = [NSBundle bundleWithURL:app_url].bundleIdentifier;

        if ([self.bundleIdentifier isEqualToString:bundle_id])
        {
            return YES;
        }
    }
    else
    {
        NSString* bundle_id = (__bridge NSString*)LSCopyDefaultRoleHandlerForContentType((__bridge CFStringRef)kTorrentFileType, kLSRolesViewer);
        if (!bundle_id)
        {
            return NO;
        }

        if ([self.bundleIdentifier isEqualToString:bundle_id])
        {
            return YES;
        }
    }

    return NO;
}

- (void)setDefaultForTorrentFiles:(void (^_Nullable)())completionHandler
{
    if (@available(macOS 12, *))
    {
        UTType* file_type = GetTorrentFileType();
        NSURL* app_url = [NSWorkspace.sharedWorkspace URLForApplicationWithBundleIdentifier:self.bundleIdentifier];
        [NSWorkspace.sharedWorkspace setDefaultApplicationAtURL:app_url toOpenContentType:file_type completionHandler:^(NSError* error) {
            if (error)
            {
                NSLog(@"Failed setting default torrent file handler: %@", error.localizedDescription);
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                completionHandler();
            });
        }];
    }
    else
    {
        OSStatus const result = LSSetDefaultRoleHandlerForContentType(
            (__bridge CFStringRef)kTorrentFileType,
            kLSRolesViewer,
            (__bridge CFStringRef)self.bundleIdentifier);
        if (result != noErr)
        {
            NSLog(@"Failed setting default torrent file handler");
        }
        completionHandler();
    }
}

- (BOOL)isDefaultForMagnetURLs
{
    if (@available(macOS 12, *))
    {
        NSURL* scheme_url = [NSURL URLWithString:[kMagnetURLScheme stringByAppendingString:@":"]];
        NSURL* app_url = [NSWorkspace.sharedWorkspace URLForApplicationToOpenURL:scheme_url];
        if (!app_url)
        {
            return NO;
        }

        NSString* bundle_id = [NSBundle bundleWithURL:app_url].bundleIdentifier;

        if ([self.bundleIdentifier isEqualToString:bundle_id])
        {
            return YES;
        }
    }
    else
    {
        NSString* bundle_id = (__bridge NSString*)LSCopyDefaultHandlerForURLScheme((__bridge CFStringRef)kMagnetURLScheme);
        if (!bundle_id)
        {
            return NO;
        }

        if ([self.bundleIdentifier isEqualToString:bundle_id])
        {
            return YES;
        }
    }

    return NO;
}

- (void)setDefaultForMagnetURLs:(void (^_Nullable)())completionHandler
{
    if (@available(macOS 12, *))
    {
        NSURL* app_url = [NSWorkspace.sharedWorkspace URLForApplicationWithBundleIdentifier:self.bundleIdentifier];
        [NSWorkspace.sharedWorkspace setDefaultApplicationAtURL:app_url toOpenURLsWithScheme:kMagnetURLScheme
                                              completionHandler:^(NSError* error) {
                                                  if (error)
                                                  {
                                                      NSLog(@"Failed setting default magnet link handler: %@", error.localizedDescription);
                                                  }
                                                  dispatch_async(dispatch_get_main_queue(), ^{
                                                      completionHandler();
                                                  });
                                              }];
    }
    else
    {
        OSStatus const result = LSSetDefaultHandlerForURLScheme(
            (__bridge CFStringRef)kMagnetURLScheme,
            (__bridge CFStringRef)self.bundleIdentifier);
        if (result != noErr)
        {
            NSLog(@"Failed setting default magnet link handler");
        }
        completionHandler();
    }
}

@end
