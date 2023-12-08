#import <Foundation/Foundation.h>
#import <LocalAuthentication/LocalAuthentication.h>
#import <objc/runtime.h>

int main(int argc, char **argv)
{
    LAContext *context = [[LAContext alloc] init];

    // 认证失败，禁止输入密码
    context.localizedFallbackTitle = @"";

    if ([context canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:nil]) {
        [context evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics localizedReason:@"Authenticate using Touch ID" reply:^(BOOL success, NSError *error) {
            if (success) {
                NSString *uniqueID = [context.evaluatedPolicyDomainState base64EncodedStringWithOptions:(NSDataBase64EncodingOptions)0];
                NSLog(@"指纹结果: %@", uniqueID);                   
            } else {
                NSLog(@"指纹识别失败: %@", error.localizedDescription);
            }
        }];       
    } else {
        NSLog(@"设备不支持指纹识别");
    }

    return 0;
}
