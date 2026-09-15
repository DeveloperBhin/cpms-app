import 'package:flutter/material.dart';

class TreeActivityPage extends StatefulWidget {
  final String treeId;
  final String farmId;
  final String blockId;

  const TreeActivityPage({
    super.key,
    required this.treeId,
    required this.farmId,
    required this.blockId,
  });

  @override
  State<TreeActivityPage> createState() =>
      _TreeActivityPageState();
}

class _TreeActivityPageState extends State<TreeActivityPage> {
  static const Color primaryGreen = Color(0xFF087A2F);
  static const Color backgroundColor = Color(0xFFF8FAF8);
  static const Color borderColor = Color(0xFFDCE8DF);
  static const Color lightGreen = Color(0xFFE7F3EB);
  static const Color textDark = Color(0xFF25402D);
  static const Color textGrey = Color(0xFF718078);

  // Temporary data.
  // Later replace this with API data.
  final List<Map<String, String>> activities = [
    {
      'title': 'Weeding',
      'date': '15 Jan 2026',
      'description': 'Weeding around the cashew tree.',
      'status': 'Completed',
    },
    {
      'title': 'Pesticide Application',
      'date': '05 Mar 2026',
      'description': 'Pesticide applied to control pests.',
      'status': 'Completed',
    },
    {
      'title': 'Pruning',
      'date': '30 Oct 2025',
      'description': 'Removed unwanted and dry branches.',
      'status': 'Completed',
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
            // =====================================================
            // HEADER
            // =====================================================
            Container(
              width: double.infinity,
              height: 55,
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
                    borderRadius: BorderRadius.circular(20),
                    child: const Padding(
                      padding: EdgeInsets.all(4),
                      child: Icon(
                        Icons.arrow_back_ios_new,
                        color: Colors.white,
                        size: 15,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Tree Activities',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  14,
                  20,
                  14,
                  30,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // =============================================
                    // TREE INFORMATION
                    // =============================================
                    _treeCard(),

                    const SizedBox(height: 18),

                    // =============================================
                    // TITLE + ADD ACTIVITY
                    // =============================================
                    Row(
                      children: [
                        const Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Activities',
                                style: TextStyle(
                                  color: textDark,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              SizedBox(height: 3),
                              Text(
                                'Activities performed on this tree',
                                style: TextStyle(
                                  color: textGrey,
                                  fontSize: 8,
                                ),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(
                          height: 38,
                          child: ElevatedButton.icon(
                            onPressed: _showAddActivity,
                            icon: const Icon(
                              Icons.add,
                              size: 15,
                            ),
                            label: const Text(
                              'Add Activity',
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
                                horizontal: 13,
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

                    const SizedBox(height: 15),

                    // =============================================
                    // ACTIVITIES
                    // =============================================
                    if (activities.isEmpty)
                      _emptyActivities()
                    else
                      ...activities.map(
                        (activity) => Padding(
                          padding:
                              const EdgeInsets.only(bottom: 12),
                          child: _activityCard(activity),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==============================================================
  // TREE CARD
  // ==============================================================
  Widget _treeCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: _cardDecoration(),
      child: Row(
        children: [
          Container(
            width: 45,
            height: 45,
            decoration: const BoxDecoration(
              color: lightGreen,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.park_outlined,
              color: primaryGreen,
              size: 23,
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.treeId,
                  style: const TextStyle(
                    color: textDark,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  '${widget.farmId} • ${widget.blockId}',
                  style: const TextStyle(
                    color: textGrey,
                    fontSize: 9,
                  ),
                ),
              ],
            ),
          ),

          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 9,
              vertical: 5,
            ),
            decoration: BoxDecoration(
              color: lightGreen,
              borderRadius: BorderRadius.circular(7),
            ),
            child: const Text(
              'Tree',
              style: TextStyle(
                color: primaryGreen,
                fontSize: 8,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==============================================================
  // ACTIVITY CARD
  // ==============================================================
  Widget _activityCard(Map<String, String> activity) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: _cardDecoration(),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: const BoxDecoration(
              color: lightGreen,
              shape: BoxShape.circle,
            ),
            child: Icon(
              _activityIcon(activity['title'] ?? ''),
              color: primaryGreen,
              size: 19,
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        activity['title'] ?? '',
                        style: const TextStyle(
                          color: textDark,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),

                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: lightGreen,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        activity['status'] ?? '',
                        style: const TextStyle(
                          color: primaryGreen,
                          fontSize: 7,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 6),

                Text(
                  activity['description'] ?? '',
                  style: const TextStyle(
                    color: textGrey,
                    fontSize: 8,
                    height: 1.4,
                  ),
                ),

                const SizedBox(height: 8),

                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today_outlined,
                      color: textGrey,
                      size: 12,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      activity['date'] ?? '',
                      style: const TextStyle(
                        color: textGrey,
                        fontSize: 8,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _activityIcon(String title) {
    final value = title.toLowerCase();

    if (value.contains('weed')) {
      return Icons.grass_outlined;
    }

    if (value.contains('pesticide') ||
        value.contains('spray')) {
      return Icons.water_drop_outlined;
    }

    if (value.contains('prun')) {
      return Icons.content_cut;
    }

    if (value.contains('harvest')) {
      return Icons.agriculture_outlined;
    }

    if (value.contains('fertil')) {
      return Icons.eco_outlined;
    }

    return Icons.task_alt;
  }

  // ==============================================================
  // ADD ACTIVITY
  // ==============================================================
  Future<void> _showAddActivity() async {
    final result = await showModalBottomSheet<Map<String, String>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return _AddActivitySheet(
          treeId: widget.treeId,
        );
      },
    );

    if (result == null || !mounted) {
      return;
    }

    setState(() {
      activities.insert(0, result);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Tree activity added successfully'),
        backgroundColor: primaryGreen,
      ),
    );
  }

  Widget _emptyActivities() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        vertical: 40,
        horizontal: 20,
      ),
      decoration: _cardDecoration(),
      child: const Column(
        children: [
          Icon(
            Icons.assignment_outlined,
            color: textGrey,
            size: 35,
          ),
          SizedBox(height: 10),
          Text(
            'No activities recorded',
            style: TextStyle(
              color: textDark,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 5),
          Text(
            'Add the first activity for this tree.',
            style: TextStyle(
              color: textGrey,
              fontSize: 8,
            ),
          ),
        ],
      ),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(13),
      border: Border.all(
        color: borderColor,
      ),
    );
  }
}

// =================================================================
// ADD ACTIVITY BOTTOM SHEET
// =================================================================
class _AddActivitySheet extends StatefulWidget {
  final String treeId;

  const _AddActivitySheet({
    required this.treeId,
  });

  @override
  State<_AddActivitySheet> createState() =>
      _AddActivitySheetState();
}

class _AddActivitySheetState
    extends State<_AddActivitySheet> {
  static const Color primaryGreen = Color(0xFF087A2F);
  static const Color backgroundColor = Color(0xFFF8FAF8);
  static const Color borderColor = Color(0xFFDCE8DF);
  static const Color textDark = Color(0xFF25402D);
  static const Color textGrey = Color(0xFF718078);

  final _formKey = GlobalKey<FormState>();

  String? _selectedActivity;

  final TextEditingController _dateController =
      TextEditingController();

  final TextEditingController _descriptionController =
      TextEditingController();

  final List<String> _activityTypes = [
    'Weeding',
    'Pruning',
    'Pesticide Application',
    'Fertilizer Application',
    'Harvesting',
    'Disease Treatment',
    'Inspection',
    'Other',
  ];

  @override
  void dispose() {
    _dateController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (date == null) {
      return;
    }

    setState(() {
      _dateController.text =
          '${date.day.toString().padLeft(2, '0')}/'
          '${date.month.toString().padLeft(2, '0')}/'
          '${date.year}';
    });
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    Navigator.pop(
      context,
      {
        'title': _selectedActivity!,
        'date': _dateController.text,
        'description': _descriptionController.text.trim(),
        'status': 'Completed',
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        18,
        12,
        18,
        MediaQuery.of(context).viewInsets.bottom + 25,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(22),
          topRight: Radius.circular(22),
        ),
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: borderColor,
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
              ),

              const SizedBox(height: 18),

              const Text(
                'Add Tree Activity',
                style: TextStyle(
                  color: textDark,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),

              const SizedBox(height: 5),

              Text(
                'Record activity for ${widget.treeId}',
                style: const TextStyle(
                  color: textGrey,
                  fontSize: 9,
                ),
              ),

              const SizedBox(height: 20),

              const Text(
                'Activity Type',
                style: TextStyle(
                  color: textDark,
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(height: 7),

              DropdownButtonFormField<String>(
                initialValue: _selectedActivity,
                hint: const Text(
                  'Select activity',
                  style: TextStyle(
                    fontSize: 9,
                    color: textGrey,
                  ),
                ),
                items: _activityTypes
                    .map(
                      (activity) => DropdownMenuItem(
                        value: activity,
                        child: Text(
                          activity,
                          style: const TextStyle(
                            fontSize: 10,
                          ),
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedActivity = value;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Select activity';
                  }
                  return null;
                },
                decoration: _inputDecoration(),
              ),

              const SizedBox(height: 15),

              const Text(
                'Activity Date',
                style: TextStyle(
                  color: textDark,
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(height: 7),

              TextFormField(
                controller: _dateController,
                readOnly: true,
                onTap: _selectDate,
                style: const TextStyle(
                  fontSize: 10,
                ),
                decoration: _inputDecoration(
                  hint: 'Select date',
                  suffixIcon: const Icon(
                    Icons.calendar_today_outlined,
                    size: 17,
                    color: primaryGreen,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Select activity date';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 15),

              const Text(
                'Description',
                style: TextStyle(
                  color: textDark,
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(height: 7),

              TextFormField(
                controller: _descriptionController,
                maxLines: 4,
                style: const TextStyle(
                  fontSize: 10,
                ),
                decoration: _inputDecoration(
                  hint: 'Describe the activity performed...',
                ),
                validator: (value) {
                  if (value == null ||
                      value.trim().isEmpty) {
                    return 'Description is required';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 22),

              SizedBox(
                width: double.infinity,
                height: 44,
                child: ElevatedButton.icon(
                  onPressed: _submit,
                  icon: const Icon(
                    Icons.add_task,
                    size: 17,
                  ),
                  label: const Text(
                    'Save Activity',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryGreen,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(9),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({
    String? hint,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(
        color: textGrey,
        fontSize: 9,
      ),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: backgroundColor,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 12,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(9),
        borderSide: const BorderSide(
          color: borderColor,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(9),
        borderSide: const BorderSide(
          color: primaryGreen,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(9),
        borderSide: const BorderSide(
          color: Colors.red,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(9),
        borderSide: const BorderSide(
          color: Colors.red,
        ),
      ),
    );
  }
}