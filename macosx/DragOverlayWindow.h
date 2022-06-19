// This file Copyright © 2007-2022 Transmission authors and contributors.
// It may be used under the MIT (SPDX: MIT) license.
// License text can be found in the licenses/ folder.

#import <Cocoa/Cocoa.h>

#include <libtransmission/transmission.h>

@interface DragOverlayWindow : NSWindow

- (instancetype)initWithLib:(tr_session*)lib forWindow:(NSWindow*)window NS_DESIGNATED_INITIALIZER;

- (void)setTorrents:(NSArray*)files;
- (void)setFile:(NSString*)file;
- (void)setURL:(NSString*)url;

- (void)fadeIn;
- (void)fadeOut;

@end
