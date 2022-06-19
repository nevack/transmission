// This file Copyright © 2011-2022 Transmission authors and contributors.
// It may be used under the MIT (SPDX: MIT) license.
// License text can be found in the licenses/ folder.

#import <Cocoa/Cocoa.h>

#include <libtransmission/transmission.h>

@interface StatusBarController : NSViewController

- (instancetype)initWithLib:(tr_session*)lib NS_DESIGNATED_INITIALIZER;

- (void)updateWithDownload:(CGFloat)dlRate upload:(CGFloat)ulRate;

- (void)updateSpeedFieldsToolTips;

@end
