import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../common/responsive.dart';
import '../../services/subscription_service.dart';
import '../../styles/styles.dart';
import '../../widgets/widgets.dart';
import 'subscription_webview.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({Key? key}) : super(key: key);

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  bool _isLoading = false;
  String _selectedPlan = 'monthly';
  SubscriptionStatusResult? _status;

  final List<Map<String, dynamic>> _plans = [
    {
      'key': 'weekly',
      'label': 'Hebdomadaire',
      'price': '1 000 XOF',
      'duration': '7 jours',
      'icon': Icons.calendar_view_week,
    },
    {
      'key': 'monthly',
      'label': 'Mensuel',
      'price': '3 500 XOF',
      'duration': '30 jours',
      'icon': Icons.calendar_month,
    },
    {
      'key': 'yearly',
      'label': 'Annuel',
      'price': '35 000 XOF',
      'duration': '365 jours',
      'icon': Icons.star,
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadStatus();
  }

  Future<void> _loadStatus() async {
    setState(() => _isLoading = true);
    final result = await SubscriptionService.getStatus();
    setState(() {
      _status = result;
      _isLoading = false;
    });
  }

  Future<void> _subscribe() async {
    setState(() => _isLoading = true);

    final result = await SubscriptionService.initSubscription(_selectedPlan);

    setState(() => _isLoading = false);

    if (!result.success || result.paymentUrl == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.error ?? 'Erreur lors de l\'initialisation.'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    // Ouvrir le WebView CinetPay
    if (mounted) {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SubscriptionWebView(
            paymentUrl: result.paymentUrl!,
            transactionId: result.transactionId!,
          ),
        ),
      );
      // Rafraîchir le statut au retour du WebView
      await _loadStatus();
    }
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
          icon: Icon(Icons.arrow_back_ios, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Abonnement',
          style: GoogleFonts.inter(
            color: textColor,
            fontSize: media.width * eighteen,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: media.width * 0.05),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: Responsive.height(2, context)),

                  // Statut actuel
                  if (_status != null && _status!.isActive)
                    _buildActiveStatus(media)
                  else
                    _buildInactiveStatus(media),

                  SizedBox(height: Responsive.height(3, context)),

                  // Titre section plans
                  Text(
                    'Choisissez votre plan',
                    style: GoogleFonts.inter(
                      color: textColor,
                      fontSize: media.width * sixteen,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  SizedBox(height: Responsive.height(2, context)),

                  // Liste des plans
                  ..._plans.map((plan) => _buildPlanCard(media, plan)),

                  SizedBox(height: Responsive.height(4, context)),

                  // Bouton S'abonner
                  Button(
                    width: double.infinity,
                    borderRadius: 15.0,
                    onTap: _isLoading ? () {} : _subscribe,
                    text: 'S\'abonner maintenant',
                  ),

                  SizedBox(height: Responsive.height(2, context)),

                  // Note
                  Center(
                    child: Text(
                      'Paiement sécurisé via CinetPay',
                      style: GoogleFonts.inter(
                        color: textColor.withOpacity(0.5),
                        fontSize: media.width * ten,
                      ),
                    ),
                  ),

                  SizedBox(height: Responsive.height(3, context)),
                ],
              ),
            ),
    );
  }

  /*
  |--------------------------------------------------------------------------
  | Widget — Statut actif
  |--------------------------------------------------------------------------
  */
  Widget _buildActiveStatus(Size media) {
    final data = _status!.data!;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(media.width * 0.05),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.15),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.green.withOpacity(0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 20),
              SizedBox(width: media.width * 0.02),
              Text(
                'Abonnement actif',
                style: GoogleFonts.inter(
                  color: Colors.green,
                  fontSize: media.width * fourteen,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: media.width * 0.02),
          Text(
            'Plan : ${data.planLabel}',
            style: GoogleFonts.inter(
              color: textColor,
              fontSize: media.width * twelve,
            ),
          ),
          Text(
            'Expire le : ${data.expiresAt?.split('T').first ?? ''}',
            style: GoogleFonts.inter(
              color: textColor,
              fontSize: media.width * twelve,
            ),
          ),
          Text(
            'Jours restants : ${data.daysRemaining}',
            style: GoogleFonts.inter(
              color: textColor,
              fontSize: media.width * twelve,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  /*
  |--------------------------------------------------------------------------
  | Widget — Statut inactif
  |--------------------------------------------------------------------------
  */
  Widget _buildInactiveStatus(Size media) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(media.width * 0.05),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.15),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.orange.withOpacity(0.4)),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 20),
          SizedBox(width: media.width * 0.02),
          Expanded(
            child: Text(
              'Vous n\'avez pas d\'abonnement actif. Abonnez-vous pour continuer à recevoir des courses.',
              style: GoogleFonts.inter(
                color: textColor,
                fontSize: media.width * twelve,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /*
  |--------------------------------------------------------------------------
  | Widget — Carte plan
  |--------------------------------------------------------------------------
  */
  Widget _buildPlanCard(Size media, Map<String, dynamic> plan) {
    final isSelected = _selectedPlan == plan['key'];

    return GestureDetector(
      onTap: () => setState(() => _selectedPlan = plan['key']),
      child: Container(
        width: double.infinity,
        margin: EdgeInsets.only(bottom: media.width * 0.03),
        padding: EdgeInsets.all(media.width * 0.04),
        decoration: BoxDecoration(
          color: isSelected
              ? buttonColor.withOpacity(0.15)
              : darkModeSecContainer,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: isSelected ? buttonColor : darkModeBorderColor,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            // Icône
            Container(
              padding: EdgeInsets.all(media.width * 0.025),
              decoration: BoxDecoration(
                color: isSelected
                    ? buttonColor.withOpacity(0.2)
                    : Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                plan['icon'] as IconData,
                color: isSelected ? buttonColor : textColor.withOpacity(0.5),
                size: media.width * 0.06,
              ),
            ),

            SizedBox(width: media.width * 0.04),

            // Label + durée
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    plan['label'],
                    style: GoogleFonts.inter(
                      color: textColor,
                      fontSize: media.width * fourteen,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    plan['duration'],
                    style: GoogleFonts.inter(
                      color: textColor.withOpacity(0.5),
                      fontSize: media.width * ten,
                    ),
                  ),
                ],
              ),
            ),

            // Prix
            Text(
              plan['price'],
              style: GoogleFonts.inter(
                color: isSelected ? buttonColor : textColor,
                fontSize: media.width * fourteen,
                fontWeight: FontWeight.w700,
              ),
            ),

            SizedBox(width: media.width * 0.02),

            // Radio
            Container(
              width: media.width * 0.05,
              height: media.width * 0.05,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? buttonColor : darkModeBorderColor,
                  width: 2,
                ),
                color: isSelected ? buttonColor : Colors.transparent,
              ),
              child: isSelected
                  ? const Icon(Icons.check, color: Colors.white, size: 12)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
