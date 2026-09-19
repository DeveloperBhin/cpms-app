import 'package:flutter/material.dart';
import '../theme/app_text_styles.dart';
import '../l10n/app_localizations.dart';
import 'blocks_page.dart';

class FarmDetailsPage extends StatelessWidget {
  final Map<String, dynamic> farm;

  const FarmDetailsPage({super.key, required this.farm});

  static const Color primaryGreen = Color(0xFF087A2F);

  static const Color backgroundColor = Color(0xFFF8FAF8);

  static const Color borderColor = Color(0xFFDCE8DF);

  static const Color textDark = Color(0xFF25402D);

  static const Color textGrey = Color(0xFF718078);

  static const Color lightGreen = Color(0xFFE7F3EB);

  // ============================================================
  // FARM VALUES
  // ============================================================

  String get farmId {
    final id = farm['id'];

    if (id == null) {
      return '-';
    }

    return id.toString();
  }

  String get farmCode {
    final id = farm['id'];

    if (id == null) {
      return '-';
    }

    final parsedId = int.tryParse(id.toString());

    if (parsedId == null) {
      return id.toString();
    }

    return 'FM-${parsedId.toString().padLeft(4, '0')}';
  }

  String _farmName(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final value = farm['name']?.toString().trim();

    if (value != null && value.isNotEmpty) {
      return value;
    }

    return l10n.unnamedFarm;
  }

  String get acreage {
    final value = farm['acreage'];

    if (value == null) {
      return '0';
    }

    if (value is num) {
      final number = value.toDouble();

      if (number == number.roundToDouble()) {
        return number.toInt().toString();
      }

      return number.toStringAsFixed(2);
    }

    return value.toString();
  }

  // Keep the backend value separate from
  // the translated display value.
  String get rawFarmType {
    return farm['farmType']?.toString().trim().toUpperCase() ?? '';
  }

  String _farmType(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    switch (rawFarmType) {
      case 'NEW':
        return l10n.newFarm;

      case 'PRODUCTION':
        return l10n.productionFarm;

      default:
        if (rawFarmType.isNotEmpty) {
          return rawFarmType;
        }

        return l10n.farm;
    }
  }

  String _location(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final village = farm['village']?.toString().trim();

    final ward = farm['ward']?.toString().trim();

    final district = farm['district']?.toString().trim();

    final region = farm['region']?.toString().trim();

    final geometry = farm['geometry']?.toString().trim();

    if (village != null && village.isNotEmpty) {
      return village;
    }

    if (geometry != null && geometry.isNotEmpty) {
      return geometry;
    }

    if (ward != null && ward.isNotEmpty) {
      return ward;
    }

    if (district != null && district.isNotEmpty) {
      return district;
    }

    if (region != null && region.isNotEmpty) {
      return region;
    }

    return l10n.locationNotAvailable;
  }

  String get plantingDate {
    final value = farm['plantingDate']?.toString().trim();

    if (value == null || value.isEmpty) {
      return '-';
    }

    return value;
  }

  String get region {
    final value = farm['region']?.toString().trim();

    return value?.isNotEmpty == true ? value! : '-';
  }

  String get district {
    final value = farm['district']?.toString().trim();

    return value?.isNotEmpty == true ? value! : '-';
  }

  String get ward {
    final value = farm['ward']?.toString().trim();

    return value?.isNotEmpty == true ? value! : '-';
  }

  String get village {
    final value = farm['village']?.toString().trim();

    return value?.isNotEmpty == true ? value! : '-';
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final displayFarmName = _farmName(context);

    return Scaffold(
      backgroundColor: backgroundColor,

      body: SafeArea(
        bottom: false,

        child: Column(
          children: [
            // =================================================
            // HEADER
            // =================================================

            Container(
              width: double.infinity,

              height: 52,

              padding: const EdgeInsets.symmetric(horizontal: 14),

              decoration: const BoxDecoration(
                color: primaryGreen,

                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(18),
                  bottomRight: Radius.circular(18),
                ),
              ),

              child: Row(
                children: [
                  InkWell(
                    onTap: () {
                      Navigator.pop(context);
                    },

                    borderRadius: BorderRadius.circular(20),

                    child: const Padding(
                      padding: EdgeInsets.all(3),

                      child: Icon(
                        Icons.arrow_back_ios_new,
                        color: Colors.white,
                        size: 14,
                      ),
                    ),
                  ),

                  const SizedBox(width: 7),

                  Text(
                    l10n.farmDetails,

                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: AppTextStyles.bodyLarge,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),

            // =================================================
            // CONTENT
            // =================================================
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(13, 24, 13, 25),

                child: Column(
                  children: [
                    // =========================================
                    // FARM INFORMATION
                    // =========================================

                    _informationCard(context),

                    const SizedBox(height: 14),

                    // =========================================
                    // VIEW BLOCKS
                    // =========================================
                    Align(
                      alignment: Alignment.centerRight,

                      child: SizedBox(
                        height: 38,

                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => BlocksPage(
                                  farmId: farmId,
                                  farmName: displayFarmName,
                                ),
                              ),
                            );
                          },

                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryGreen,

                            foregroundColor: Colors.white,

                            elevation: 0,

                            padding: const EdgeInsets.symmetric(horizontal: 18),

                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),

                          child: Text(
                            l10n.viewBlocks,

                            style: const TextStyle(
                              fontSize: AppTextStyles.bodySmall,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 14),

                    // =========================================
                    // PRODUCTION SUMMARY
                    // =========================================
                    _productionSummary(context),

                    const SizedBox(height: 22),

                    // =========================================
                    // PRODUCTION HISTORY
                    // =========================================
                    _productionHistory(context),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // FARM INFORMATION
  // ============================================================

  Widget _informationCard(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      width: double.infinity,

      padding: const EdgeInsets.fromLTRB(14, 15, 14, 18),

      decoration: _cardDecoration(),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Text(
            l10n.farmInformation,

            style: const TextStyle(
              color: primaryGreen,
              fontSize: AppTextStyles.body,
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 14),

          Text(
            '${l10n.farmId}: $farmCode',

            style: const TextStyle(
              color: textDark,
              fontSize: AppTextStyles.bodySmall,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 9),

          Text(
            '${_farmName(context)} • '
            '$acreage ${l10n.acres}',

            style: const TextStyle(
              color: textDark,
              fontSize: AppTextStyles.bodySmall,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 12),

          // Farm type
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),

            decoration: BoxDecoration(
              color: lightGreen,

              borderRadius: BorderRadius.circular(7),
            ),

            child: Text(
              _farmType(context),

              style: const TextStyle(
                color: primaryGreen,
                fontSize: AppTextStyles.bodySmall,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          const SizedBox(height: 14),

          _informationRow(
            Icons.location_on_outlined,
            l10n.location,
            _location(context),
          ),

          const SizedBox(height: 10),

          _informationRow(
            Icons.calendar_today_outlined,
            l10n.plantingDate,
            plantingDate,
          ),

          const SizedBox(height: 10),

          _informationRow(Icons.map_outlined, l10n.region, region),

          const SizedBox(height: 10),

          _informationRow(
            Icons.location_city_outlined,
            l10n.district,
            district,
          ),

          const SizedBox(height: 10),

          _informationRow(Icons.place_outlined, l10n.ward, ward),

          const SizedBox(height: 10),

          _informationRow(Icons.home_work_outlined, l10n.village, village),
        ],
      ),
    );
  }

  // ============================================================
  // INFORMATION ROW
  // ============================================================

  Widget _informationRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [
        Icon(icon, size: 14, color: primaryGreen),

        const SizedBox(width: 8),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              Text(
                label,

                style: const TextStyle(
                  color: textGrey,
                  fontSize: AppTextStyles.bodySmall,
                  fontWeight: FontWeight.w500,
                ),
              ),

              const SizedBox(height: 2),

              Text(
                value,

                style: const TextStyle(
                  color: textDark,
                  fontSize: AppTextStyles.bodySmall,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ============================================================
  // PRODUCTION SUMMARY
  // ============================================================

  Widget _productionSummary(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      width: double.infinity,

      padding: const EdgeInsets.fromLTRB(14, 15, 14, 16),

      decoration: _cardDecoration(),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Text(
            l10n.productionSummary,

            style: const TextStyle(
              color: primaryGreen,
              fontSize: AppTextStyles.body,
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 17),

          Text(
            l10n.totalProduction,

            style: const TextStyle(
              color: textGrey,
              fontSize: AppTextStyles.bodySmall,
              fontWeight: FontWeight.w500,
            ),
          ),

          const SizedBox(height: 4),

          // TODO:
          // Replace when production API is connected.
          const Text(
            '- KG',

            style: TextStyle(
              color: textDark,
              fontSize: AppTextStyles.largeHeading,
              fontWeight: FontWeight.w800,
              height: 1,
            ),
          ),

          const SizedBox(height: 11),

          Text(
            '${l10n.averageProduction}: - KG',

            style: const TextStyle(
              color: textGrey,
              fontSize: AppTextStyles.bodySmall,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // PRODUCTION HISTORY
  // ============================================================

  Widget _productionHistory(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      width: double.infinity,

      padding: const EdgeInsets.fromLTRB(14, 15, 14, 18),

      decoration: _cardDecoration(),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Text(
            l10n.productionHistory,

            style: const TextStyle(
              color: primaryGreen,
              fontSize: AppTextStyles.body,
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 17),

          Text(
            l10n.noProductionRecords,

            style: const TextStyle(
              color: textGrey,
              fontSize: AppTextStyles.bodySmall,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // CARD DECORATION
  // ============================================================

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,

      borderRadius: BorderRadius.circular(13),

      border: Border.all(color: borderColor, width: 1),
    );
  }
}
