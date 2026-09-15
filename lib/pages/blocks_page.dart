import 'package:flutter/material.dart';
import 'addblocks_page.dart';
import 'blocksdetails_page.dart';

class BlocksPage extends StatefulWidget {
  final String farmId;
  final String farmName;

  const BlocksPage({
    super.key,
    required this.farmId,
    required this.farmName,
  });

  @override
  State<BlocksPage> createState() => _BlocksPageState();
}

class _BlocksPageState extends State<BlocksPage> {
  static const Color primaryGreen = Color(0xFF087A2F);
  static const Color backgroundColor = Color(0xFFF8FAF8);
  static const Color borderColor = Color(0xFFDCE8DF);
  static const Color lightGreen = Color(0xFFE7F3EB);
  static const Color textDark = Color(0xFF25402D);
  static const Color textGrey = Color(0xFF718078);

  final List<Map<String, String>> blocks = [
    {
      'id': 'BL-0001',
      'name': 'Block A',
      'size': '4 Acres',
      'trees': '200',
      'variety': 'Common',
    },
    {
      'id': 'BL-0002',
      'name': 'Block B',
      'size': '3 Acres',
      'trees': '150',
      'variety': 'Improved',
    },
    {
      'id': 'BL-0003',
      'name': 'Block C',
      'size': '3 Acres',
      'trees': '150',
      'variety': 'Common',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // HEADER
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
                    onTap: () => Navigator.pop(context),
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
                  const Text(
                    'Farm Blocks',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),

            // CONTENT
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  13,
                  20,
                  13,
                  25,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // FARM INFORMATION
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(13),
                        border: Border.all(
                          color: borderColor,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.farmName,
                            style: const TextStyle(
                              color: textDark,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            'Farm ID: ${widget.farmId}',
                            style: const TextStyle(
                              color: textGrey,
                              fontSize: 8,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 18),

                    // BLOCKS + ADD BLOCK
                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Blocks',
                          style: TextStyle(
                            color: textDark,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(
                          height: 38,
                          child: ElevatedButton.icon(
                           onPressed: () async {
  final added = await Navigator.push<bool>(
    context,
    MaterialPageRoute(
      builder: (context) => AddBlockPage(
        farmId: widget.farmId,
        farmName: widget.farmName,
      ),
    ),
  );

  if (added == true) {
    // Later we'll reload blocks from API here.
    setState(() {});
  }
},
                            icon: const Icon(
                              Icons.add,
                              size: 15,
                            ),
                            label: const Text(
                              'Add Block',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryGreen,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              padding:
                                  const EdgeInsets.symmetric(
                                horizontal: 14,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    // BLOCK LIST
                    ...blocks.map(
                      (block) => Padding(
                        padding:
                            const EdgeInsets.only(bottom: 12),
                        child: _blockCard(block),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      bottomNavigationBar: _bottomNavigation(),
    );
  }

  // ==============================================================
  // BLOCK CARD
  // ==============================================================
  Widget _blockCard(Map<String, String> block) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(
          color: borderColor,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  block['name']!,
                  style: const TextStyle(
                    color: textDark,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: lightGreen,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  block['id']!,
                  style: const TextStyle(
                    color: primaryGreen,
                    fontSize: 7,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: _blockInfo(
                  'Size',
                  block['size']!,
                ),
              ),
              Expanded(
                child: _blockInfo(
                  'Trees',
                  block['trees']!,
                ),
              ),
              Expanded(
                child: _blockInfo(
                  'Variety',
                  block['variety']!,
                ),
              ),
            ],
          ),

          const SizedBox(height: 13),

          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
            onPressed: () {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => BlockDetailsPage(
        farmId: widget.farmId,
        blockId: block['id']!,
        blockName: block['name']!,
      ),
    ),
  );
},
              child: const Text(
                'View Block ›',
                style: TextStyle(
                  color: primaryGreen,
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _blockInfo(
    String label,
    String value,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: textGrey,
            fontSize: 7,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: textDark,
            fontSize: 9,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  // ==============================================================
  // BOTTOM NAVIGATION
  // ==============================================================
  Widget _bottomNavigation() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: Colors.grey.shade200,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 62,
          child: Row(
            children: [
              _navItem(
                Icons.home_outlined,
                'Home',
                false,
              ),
              _navItem(
                Icons.crop_square_outlined,
                'Farms',
                true,
              ),
              _navItem(
                Icons.park_outlined,
                'Trees',
                false,
              ),
              _navItem(
                Icons.check_outlined,
                'Tasks',
                false,
              ),
              _navItem(
                Icons.menu,
                'More',
                false,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navItem(
    IconData icon,
    String label,
    bool selected,
  ) {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 17,
            color: selected
                ? primaryGreen
                : const Color(0xFF9AA39D),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 8,
              fontWeight: selected
                  ? FontWeight.w700
                  : FontWeight.w500,
              color: selected
                  ? primaryGreen
                  : const Color(0xFF9AA39D),
            ),
          ),
        ],
      ),
    );
  }
}