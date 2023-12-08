// https://krausefx.com/blog/mac-privacy-sandboxed-mac-apps-can-take-screenshots
CGImageRef screenshot = CGWindowListCreateImage(
  CGRectInfinite, 
  kCGWindowListOptionOnScreenOnly, 
  kCGNullWindowID, 
  kCGWindowImageDefault);

NSBitmapImageRep *bitmapRep = [[NSBitmapImageRep alloc] initWithCGImage:screenshot];
