#
# App-specific ProGuard / R8 rules.
#

# Suppress warnings for new Android window back gesture APIs that may not
# exist on older compile/target SDKs but are referenced by Flutter embedding.
-dontwarn android.window.BackEvent


