import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../services/subscription_service.dart';
import '../../styles/styles.dart';

class SubscriptionWebView extends StatefulWidget {
  final String paymentUrl;
  final String transactionId;

  const SubscriptionWebView({
    Key? key,
    required this.paymentUrl,
    required this.transactionId,
  }) : super(key: key);

  @override
  State<SubscriptionWebView> createState() => _SubscriptionWebViewState();
}

class _SubscriptionWebViewState extends State<SubscriptionWebView> {
  late final WebViewController _controller;
  bool _isLoading = true;
  bool _paymentDone = false;

  // URL de retour CinetPay — doit correspondre à ce qu'on a mis dans le controller Laravel
  static const String _returnUrlBase = 'https://rungobf.com/taxi/public/api/v1/payment/cinetpay/return';

  @override
  void initState() {
    super.initState();
    _initWebView();
  }

  void _initWebView() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {
            setState(() => _isLoading = true);

            // Détecter la redirection vers notre return URL
            if (url.startsWith(_returnUrlBase)) {
              _onPaymentReturn(url);
            }
          },
          onPageFinished: (url) {
            setState(() => _isLoading = false);
          },
          onWebResourceError: (error) {
            setState(() => _isLoading = false);
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.paymentUrl));
  }

  Future<void> _onPaymentReturn(String url) async {
    if (_paymentDone) return;
    _paymentDone = true;

    setState(() => _isLoading = true);

    // Attendre quelques secondes que le webhook CinetPay soit traité
    await Future.delayed(const Duration(seconds: 3));

    // Vérifier le statut de l'abonnement
    final status = await SubscriptionService.getStatus();

    if (!mounted) return;

    setState(() => _isLoading = false);

    if (status.isActive) {
      // Paiement confirmé — afficher succès et retourner
      _showSuccessDialog();
    } else {
      // Paiement en attente ou échoué
      _showPendingDialog();
    }
  }

  void _showSuccessDialog() {
    var media = MediaQuery.of(context).size;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: page,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 60),
            SizedBox(height: media.height * 0.02),
            Text(
              'Abonnement activé !',
              style: GoogleFonts.inter(
                color: textColor,
                fontSize: media.width * eighteen,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: media.height * 0.01),
            Text(
              'Votre abonnement est maintenant actif. Vous pouvez recevoir des courses.',
              style: GoogleFonts.inter(
                color: textColor.withValues(alpha: 0.7),
                fontSize: media.width * twelve,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: media.height * 0.02),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: buttonColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: EdgeInsets.symmetric(vertical: media.height * 0.015),
                ),
                onPressed: () {
                  Navigator.pop(context); // fermer dialog
                  Navigator.pop(context); // retourner à subscription_screen
                },
                child: Text(
                  'Continuer',
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: media.width * fourteen,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPendingDialog() {
    var media = MediaQuery.of(context).size;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: page,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.hourglass_empty, color: Colors.orange, size: 60),
            SizedBox(height: media.height * 0.02),
            Text(
              'Paiement en cours de vérification',
              style: GoogleFonts.inter(
                color: textColor,
                fontSize: media.width * sixteen,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: media.height * 0.01),
            Text(
              'Votre paiement est en cours de traitement. Votre abonnement sera activé automatiquement.',
              style: GoogleFonts.inter(
                color: textColor.withValues(alpha: 0.7),
                fontSize: media.width * twelve,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: media.height * 0.02),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: buttonColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: EdgeInsets.symmetric(vertical: media.height * 0.015),
                ),
                onPressed: () {
                  Navigator.pop(context); // fermer dialog
                  Navigator.pop(context); // retourner à subscription_screen
                },
                child: Text(
                  'OK',
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: media.width * fourteen,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: page,
      appBar: AppBar(
        backgroundColor: page,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Paiement CinetPay',
          style: GoogleFonts.inter(
            color: textColor,
            fontSize: media.width * sixteen,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}
