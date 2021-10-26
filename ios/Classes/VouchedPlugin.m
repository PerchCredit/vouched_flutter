#import "VouchedPlugin.h"
#if __has_include(<vouched_plugin/vouched_plugin-Swift.h>)
#import <vouched_plugin/vouched_plugin-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "vouched_plugin-Swift.h"
#endif

@implementation VouchedPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftVouchedPlugin registerWithRegistrar:registrar];
}
@end
