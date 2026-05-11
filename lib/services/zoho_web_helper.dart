// ignore: avoid_web_libraries_in_flutter
import 'dart:js' as js;

/// Zoho Web Helper - Only compiled on Web
class ZohoWebHelper {
  static void toggleChat(bool visible) {
    try {
      // Use eval to safely call the zoho script methods and manipulate DOM
      js.context.callMethod('eval', [
        "if(window.\$zoho && window.\$zoho.salesiq && window.\$zoho.salesiq.floatwindow) { "
            "  window.\$zoho.salesiq.floatwindow.visible('${visible ? 'show' : 'hide'}'); "
            "  var el = document.getElementById('zsiq_float'); "
            "  if (el) el.style.setProperty('display', '${visible ? 'block' : 'none'}', 'important'); "
            "}"
      ]);
    } catch (e) {
      print('📱 [Zoho Web Helper] Error: \$e');
    }
  }
}
