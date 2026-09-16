import 'package:flutter/material.dart';

import 'blocks_page.dart';

class FarmDetailsPage extends StatelessWidget {
  final Map<String, dynamic> farm;

  const FarmDetailsPage({
    super.key,
    required this.farm,
  });

  static const Color primaryGreen = Color(0xFF087A2F);
  static const Color backgroundColor = Color(0xFFF8FAF8);
  static const Color borderColor = Color(0xFFDCE8DF);
  static const Color textDark = Color(0xFF25402D);
  static const Color textGrey = Color(0xFF718078);
  static const Color lightGreen = Color(0xFFE7F3EB);

  // =========================================================
  // FARM VALUES
  // =========================================================

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

  String get farmName {
    return farm['name']?.toString().trim().isNotEmpty == true
        ? farm['name'].toString()
        : 'Unnamed Farm';
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

  String get farmType {
    final value = farm['farmType']
        ?.toString()
        .trim()
        .toUpperCase();

    switch (value) {
      case 'NEW':
        return 'New farm';

      case 'PRODUCTION':
        return 'Production farm';

      default:
        return value?.isNotEmpty == true
            ? value!
            : 'Farm';
    }
  }

  String get location {
    final village = farm['village']?.toString().trim();

    final ward = farm['ward']?.toString().trim();

    final district = farm['district']?.toString().trim();

    final region = farm['region']?.toString().trim();

    final farmLocation =
        farm['farmLocation']?.toString().trim();

    if (village != null && village.isNotEmpty) {
      return village;
    }

    if (farmLocation != null && farmLocation.isNotEmpty) {
      return farmLocation;
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

    return 'Location not available';
  }

  String get plantingDate {
    final value =
        farm['plantingDate']?.toString().trim();

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

  // =========================================================
  // BUILD
  // =========================================================

  @override
  Widget build(BuildContext context) {
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

              padding: const EdgeInsets.symmetric(
                horizontal: 14,
              ),

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

                    borderRadius:
                        BorderRadius.circular(20),

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

                  const Text(
                    'Farm Details',

                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
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
                padding: const EdgeInsets.fromLTRB(
                  13,
                  24,
                  13,
                  25,
                ),

                child: Column(
                  children: [
                    // =========================================
                    // FARM INFORMATION
                    // =========================================

                    _informationCard(),

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
                                builder: (context) =>
                                    BlocksPage(
                                  farmId: farmId,
                                  farmName: farmName,
                                ),
                              ),
                            );
                          },

                          style:
                              ElevatedButton.styleFrom(
                            backgroundColor:
                                primaryGreen,

                            foregroundColor:
                                Colors.white,

                            elevation: 0,

                            padding:
                                const EdgeInsets.symmetric(
                              horizontal: 18,
                            ),

                            shape:
                                RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(
                                8,
                              ),
                            ),
                          ),

                          child: const Text(
                            'View Blocks',

                            style: TextStyle(
                              fontSize: 9,
                              fontWeight:
                                  FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 14),

                    // =========================================
                    // PRODUCTION SUMMARY
                    // =========================================

                    _productionSummary(),

                    const SizedBox(height: 22),

                    // =========================================
                    // PRODUCTION HISTORY
                    // =========================================

                    _productionHistory(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =========================================================
  // FARM INFORMATION
  // =========================================================

  Widget _informationCard() {
    return Container(
      width: double.infinity,

      padding: const EdgeInsets.fromLTRB(
        14,
        15,
        14,
        18,
      ),

      decoration: _cardDecoration(),

      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [
          const Text(
            'Farm Information',

            style: TextStyle(
              color: primaryGreen,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 14),

          Text(
            'Farm ID: $farmCode',

            style: const TextStyle(
              color: textDark,
              fontSize: 9,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 9),

          Text(
            '$farmName • $acreage Acres',

            style: const TextStyle(
              color: textDark,
              fontSize: 9,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 12),

          // Farm type

          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 9,
              vertical: 5,
            ),

            decoration: BoxDecoration(
              color: lightGreen,

              borderRadius:
                  BorderRadius.circular(7),
            ),

            child: Text(
              farmType,

              style: const TextStyle(
                color: primaryGreen,
                fontSize: 8,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          const SizedBox(height: 14),

          _informationRow(
            Icons.location_on_outlined,
            'Location',
            location,
          ),

          const SizedBox(height: 10),

          _informationRow(
            Icons.calendar_today_outlined,
            'Planting Date',
            plantingDate,
          ),

          const SizedBox(height: 10),

          _informationRow(
            Icons.map_outlined,
            'Region',
            region,
          ),

          const SizedBox(height: 10),

          _informationRow(
            Icons.location_city_outlined,
            'District',
            district,
          ),

          const SizedBox(height: 10),

          _informationRow(
            Icons.place_outlined,
            'Ward',
            ward,
          ),

          const SizedBox(height: 10),

          _informationRow(
            Icons.home_work_outlined,
            'Village',
            village,
          ),
        ],
      ),
    );
  }

  // =========================================================
  // INFORMATION ROW
  // =========================================================

  Widget _informationRow(
    IconData icon,
    String label,
    String value,
  ) {
    return Row(
      crossAxisAlignment:
          CrossAxisAlignment.start,

      children: [
        Icon(
          icon,
          size: 14,
          color: primaryGreen,
        ),

        const SizedBox(width: 8),

        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,

            children: [
              Text(
                label,

                style: const TextStyle(
                  color: textGrey,
                  fontSize: 7,
                  fontWeight: FontWeight.w500,
                ),
              ),

              const SizedBox(height: 2),

              Text(
                value,

                style: const TextStyle(
                  color: textDark,
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // =========================================================
  // PRODUCTION SUMMARY
  // =========================================================

  Widget _productionSummary() {
    return Container(
      width: double.infinity,

      padding: const EdgeInsets.fromLTRB(
        14,
        15,
        14,
        16,
      ),

      decoration: _cardDecoration(),

      child: const Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [
          Text(
            'Production Summary',

            style: TextStyle(
              color: primaryGreen,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),

          SizedBox(height: 17),

          Text(
            'Total production',

            style: TextStyle(
              color: textGrey,
              fontSize: 8,
              fontWeight: FontWeight.w500,
            ),
          ),

          SizedBox(height: 4),

          // TODO:
          // Replace this when production API
          // is connected.

          Text(
            '- KG',

            style: TextStyle(
              color: textDark,
              fontSize: 22,
              fontWeight: FontWeight.w800,
              height: 1,
            ),
          ),

          SizedBox(height: 11),

          Text(
            'Average production: - KG',

            style: TextStyle(
              color: textGrey,
              fontSize: 8,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // PRODUCTION HISTORY
  // =========================================================

  Widget _productionHistory() {
    return Container(
      width: double.infinity,

      padding: const EdgeInsets.fromLTRB(
        14,
        15,
        14,
        18,
      ),

      decoration: _cardDecoration(),

      child: const Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [
          Text(
            'Production History',

            style: TextStyle(
              color: primaryGreen,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),

          SizedBox(height: 17),

          Text(
            'No production records available yet.',

            style: TextStyle(
              color: textGrey,
              fontSize: 9,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // CARD DECORATION
  // =========================================================

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,

      borderRadius:
          BorderRadius.circular(13),

      border: Border.all(
        color: borderColor,
        width: 1,
      ),
    );
  }
}