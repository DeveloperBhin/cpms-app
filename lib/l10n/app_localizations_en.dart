// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get goodMorning => 'Good morning,';

  @override
  String get goodAfternoon => 'Good afternoon,';

  @override
  String get goodEvening => 'Good evening,';

  @override
  String get changeLanguage => 'Change Language';

  @override
  String get english => 'English';

  @override
  String get swahili => 'Kiswahili';

  @override
  String get home => 'Home';

  @override
  String get farms => 'Farms';

  @override
  String get trees => 'Trees';

  @override
  String get harvested => 'Harvested';

  @override
  String get totalCost => 'Total Cost';

  @override
  String get activities => 'Activities';

  @override
  String get farmHarvests => 'Farm Harvests';

  @override
  String get registered => 'registered';

  @override
  String get recorded => 'recorded';

  @override
  String get totalHarvested => 'total harvested';

  @override
  String get activityCosts => 'activity costs';

  @override
  String get productionOverview => 'Production Overview';

  @override
  String get treeHarvest => 'Tree Harvest';

  @override
  String get farmHarvest => 'Farm Harvest';

  @override
  String get upcomingActivities => 'Upcoming Activities';

  @override
  String get noUpcomingActivities => 'No upcoming activities.';

  @override
  String get profile => 'Profile';

  @override
  String get more => 'More';

  @override
  String get unableToLoadDashboard => 'Unable to load dashboard.';

  @override
  String get activity => 'Activity';

  @override
  String get weeding => 'Weeding';

  @override
  String get pruning => 'Pruning';

  @override
  String get pesticideApplication => 'Pesticide Application';

  @override
  String get fertilizerApplication => 'Fertilizer Application';

  @override
  String get harvesting => 'Harvesting';

  @override
  String get other => 'Other';

  @override
  String get farmDashboard => 'Farm Dashboard';

  @override
  String get acres => 'Acres';

  @override
  String get addFarm => 'Add Farm';

  @override
  String get unableToLoadFarms => 'Unable to load farms';

  @override
  String get retry => 'Retry';

  @override
  String get noFarmsAddedYet => 'No farms added yet';

  @override
  String get addFirstFarmMessage => 'Tap Add Farm to register your first farm.';

  @override
  String get viewFarm => 'View Farm';

  @override
  String get newFarm => 'New farm';

  @override
  String get productionFarm => 'Production farm';

  @override
  String get farm => 'Farm';

  @override
  String get locationNotAvailable => 'Location not available';

  @override
  String get planted => 'Planted';

  @override
  String get totalTrees => 'Total Trees';

  @override
  String get registeredTrees => 'Registered Trees';

  @override
  String get searchTreeHint => 'Search tree by code, farm, block or variety';

  @override
  String treeCount(int count) {
    return '$count trees';
  }

  @override
  String get refresh => 'Refresh';

  @override
  String get block => 'Block';

  @override
  String get viewTree => 'View Tree';

  @override
  String get healthy => 'Healthy';

  @override
  String get diseased => 'Diseased';

  @override
  String get dead => 'Dead';

  @override
  String get unableToLoadTrees => 'Unable to load trees';

  @override
  String get unknownError => 'Unknown error';

  @override
  String get tryAgain => 'Try Again';

  @override
  String get noTreesFound => 'No trees found';

  @override
  String get noTreesRegistered => 'No trees registered';

  @override
  String get tryAnotherTreeSearch =>
      'Try another tree code, farm, block or variety.';

  @override
  String get registeredTreesAppearHere =>
      'Trees registered in your farms will appear here.';

  @override
  String get unableToOpenTree =>
      'Unable to open this tree because its farm, block or tree ID is missing.';

  @override
  String get treeActivities => 'Tree Activities';

  @override
  String get activityPageDescription =>
      'View and manage farm and tree activities.';

  @override
  String get addActivity => 'Add Activity';

  @override
  String get chooseActivityType =>
      'Choose the type of activity you want to record.';

  @override
  String get treeActivity => 'Tree Activity';

  @override
  String get treeActivityDescription =>
      'Weeding, pruning, pesticide, fertilizer and other tree activities.';

  @override
  String get harvestingDescription =>
      'Record farm harvesting or harvesting from a specific tree.';

  @override
  String get harvestingMethod => 'Harvesting Method';

  @override
  String get howHarvestRecorded => 'How was this harvest recorded?';

  @override
  String get farmHarvesting => 'Farm Harvesting';

  @override
  String get farmHarvestingDescription =>
      'Record harvest using number of buckets and kilograms per bucket.';

  @override
  String get treeHarvesting => 'Tree Harvesting';

  @override
  String get treeHarvestingDescription =>
      'Record kilograms harvested from a specific cashew tree.';

  @override
  String get searchActivitiesHint => 'Search tree, farm, block or activity...';

  @override
  String get all => 'All';

  @override
  String get pesticide => 'Pesticide';

  @override
  String get fertilizer => 'Fertilizer';

  @override
  String get recentActivities => 'Recent Activities';

  @override
  String activitiesFound(int count) {
    return '$count found';
  }

  @override
  String get viewTreeActivities => 'View Tree Activities';

  @override
  String get loadingActivities => 'Loading activities...';

  @override
  String get unableToLoadActivities => 'Unable to load activities';

  @override
  String get noActivitiesFound => 'No activities found';

  @override
  String get noActivitiesRecorded => 'No activities recorded';

  @override
  String get changeSearchOrFilter => 'Try changing your search or filter.';

  @override
  String get activitiesAppearHere =>
      'Activities added to your cashew trees will appear here.';

  @override
  String get unableToOpenTreeActivities =>
      'Unable to open tree activities. Tree relationship information is missing.';

  @override
  String get planned => 'Planned';

  @override
  String get inProgress => 'In Progress';

  @override
  String get completed => 'Completed';

  @override
  String get cancelled => 'Cancelled';

  @override
  String get unableToLoadProfile => 'Unable to load profile';

  @override
  String get personalInformation => 'PERSONAL INFORMATION';

  @override
  String get editProfile => 'Edit Profile';

  @override
  String get updateYourDetails => 'Update your details';

  @override
  String get notifications => 'Notifications';

  @override
  String get enabled => 'Enabled';

  @override
  String get language => 'Language';

  @override
  String get systemSecurity => 'SYSTEM & SECURITY';

  @override
  String get lightDarkMode => 'Light/Dark Mode';

  @override
  String get privacySecurity => 'Privacy & Security';

  @override
  String get support => 'SUPPORT';

  @override
  String get helpCenter => 'Help Center';

  @override
  String get termsOfService => 'Terms of Service';

  @override
  String get uploads => 'UPLOADS';

  @override
  String get uploadFiles => 'Upload Files';

  @override
  String get uploadFilesDescription => 'Upload documents, images or ZIP files';

  @override
  String get filesUploadedSuccessfully => 'Files uploaded successfully';

  @override
  String get uploadFailed => 'Upload failed';

  @override
  String get logout => 'Logout';

  @override
  String get poweredByTari => 'Powered by TARI';

  @override
  String get active => 'Active';

  @override
  String get user => 'User';

  @override
  String get farmName => 'Farm Name';

  @override
  String get farmNameRequired => 'Farm name is required';

  @override
  String get plantingDate => 'Planting Date';

  @override
  String get plantingDateRequired => 'Planting date is required';

  @override
  String get farmType => 'Farm Type';

  @override
  String get selectFarmType => 'Select Farm Type';

  @override
  String get farmTypeRequired => 'Farm type is required';

  @override
  String get farmSize => 'Farm Size';

  @override
  String get farmSizeRequired => 'Farm size is required';

  @override
  String get validFarmSizeRequired => 'Enter a valid farm size';

  @override
  String get submitFarm => 'Submit Farm';

  @override
  String get farmAddedSuccessfully => 'Farm added successfully';

  @override
  String get profileLocationIncomplete =>
      'Your profile location information is incomplete';

  @override
  String get farmDetails => 'Farm Details';

  @override
  String get farmInformation => 'Farm Information';

  @override
  String get farmId => 'Farm ID';

  @override
  String get viewBlocks => 'View Blocks';

  @override
  String get location => 'Location';

  @override
  String get region => 'Region';

  @override
  String get district => 'District';

  @override
  String get ward => 'Ward';

  @override
  String get village => 'Village';

  @override
  String get productionSummary => 'Production Summary';

  @override
  String get totalProduction => 'Total production';

  @override
  String get averageProduction => 'Average production';

  @override
  String get productionHistory => 'Production History';

  @override
  String get noProductionRecords => 'No production records available yet.';

  @override
  String get unnamedFarm => 'Unnamed Farm';

  @override
  String get farmBlocks => 'Farm Blocks';

  @override
  String get blocks => 'Blocks';

  @override
  String blockCount(int count) {
    return 'Blocks ($count)';
  }

  @override
  String get addBlock => 'Add Block';

  @override
  String get loadingBlocks => 'Loading blocks...';

  @override
  String get unableToLoadBlocks => 'Unable to load blocks';

  @override
  String get noBlocksYet => 'No blocks yet';

  @override
  String get createFirstBlock => 'Create the first block for this farm.';

  @override
  String get unnamedBlock => 'Unnamed Block';

  @override
  String get size => 'Size';

  @override
  String get variety => 'Variety';

  @override
  String get viewBlock => 'View Block';

  @override
  String get blockName => 'Block Name';

  @override
  String get blockNameHint => 'Block name';

  @override
  String get blockNameRequired => 'Block name is required';

  @override
  String get blockSize => 'Block Size';

  @override
  String get blockSizeHint => 'Block size / acres';

  @override
  String get blockSizeRequired => 'Block size is required';

  @override
  String get validBlockSizeRequired => 'Enter a valid block size';

  @override
  String get numberOfTrees => 'Number of Trees';

  @override
  String get numberOfTreesHint => 'Number of trees';

  @override
  String get numberOfTreesRequired => 'Number of trees is required';

  @override
  String get validNumberOfTreesRequired => 'Enter a valid number of trees';

  @override
  String get cashewVariety => 'Cashew Variety';

  @override
  String get cashewVarietyHint => 'Cashew variety';

  @override
  String get cashewVarietyRequired => 'Cashew variety is required';

  @override
  String get description => 'Description';

  @override
  String get blockDescriptionHint => 'Notes / block description';

  @override
  String get submitBlock => 'Submit Block';

  @override
  String get blockAddedSuccessfully => 'Block added successfully';

  @override
  String get blockDetails => 'Block Details';

  @override
  String get blockInformation => 'Block Information';

  @override
  String get blockId => 'Block ID';

  @override
  String get blockSummary => 'Block Summary';

  @override
  String get varieties => 'Varieties';

  @override
  String get addTree => 'Add Tree';

  @override
  String get noTreesInBlock => 'No trees registered in this block';

  @override
  String get addFirstTreeMessage => 'Tap Add Tree to register the first tree.';

  @override
  String get addingTreeTo => 'Adding tree to';

  @override
  String get plantingYear => 'Planting Year';

  @override
  String get plantingYearHint => 'Planting year';

  @override
  String get selectPlantingYear => 'Select planting year';

  @override
  String get plantingYearRequired => 'Planting year is required';

  @override
  String get invalidPlantingYear => 'Invalid planting year';

  @override
  String get validPlantingYearRequired => 'Enter a valid planting year';

  @override
  String get treeStatus => 'Tree Status';

  @override
  String get treeStatusHint => 'Tree status';

  @override
  String get treeLocation => 'Tree Location';

  @override
  String get treeLocationDescription =>
      'Optional GPS coordinates for this tree.';

  @override
  String get latitude => 'Latitude';

  @override
  String get longitude => 'Longitude';

  @override
  String get invalidLatitude => 'Invalid latitude';

  @override
  String get invalidLongitude => 'Invalid longitude';

  @override
  String get validLatitudeRequired =>
      'Enter a valid latitude between -90 and 90.';

  @override
  String get validLongitudeRequired =>
      'Enter a valid longitude between -180 and 180.';

  @override
  String get bothCoordinatesRequired => 'Enter both latitude and longitude.';

  @override
  String get notes => 'Notes';

  @override
  String get treeNotesHint => 'Notes / tree description';

  @override
  String get treeAddedSuccessfully => 'Tree added successfully';

  @override
  String get addTreeActivity => 'Add Tree Activity';

  @override
  String get treeActivitySubtitle =>
      'Select a farm, block and cashew tree, then record the activity and its cost.';

  @override
  String get farmHarvestSubtitle =>
      'Select a farm and record the number of buckets, kilograms per bucket and harvesting cost.';

  @override
  String get treeHarvestSubtitle =>
      'Select a farm, block and cashew tree, then record the kilograms harvested from the tree.';

  @override
  String get activityInformation => 'Activity Information';

  @override
  String get harvestInformation => 'Harvest Information';

  @override
  String get selectFarm => 'Select farm';

  @override
  String get farmRequired => 'Farm is required';

  @override
  String get pleaseSelectFarm => 'Please select a farm.';

  @override
  String get loadingFarms => 'Loading farms...';

  @override
  String get selectFarmFirst => 'Select farm first';

  @override
  String get selectBlock => 'Select block';

  @override
  String get blockRequired => 'Block is required';

  @override
  String get pleaseSelectBlock => 'Please select a block.';

  @override
  String get noBlocksForFarm => 'No blocks found for this farm';

  @override
  String get cashewTree => 'Cashew Tree';

  @override
  String get selectBlockFirst => 'Select block first';

  @override
  String get selectTree => 'Select tree';

  @override
  String get treeRequired => 'Tree is required';

  @override
  String get pleaseSelectTree => 'Please select a tree.';

  @override
  String get loadingTrees => 'Loading trees...';

  @override
  String get noTreesForBlock => 'No trees found for this block';

  @override
  String get activityType => 'Activity Type';

  @override
  String get selectActivity => 'Select activity';

  @override
  String get activityTypeRequired => 'Activity type is required';

  @override
  String get numberOfBuckets => 'Number of Buckets';

  @override
  String get kgPerBucket => 'Kg per Bucket';

  @override
  String get example20 => 'Example: 20';

  @override
  String get example15 => 'Example: 15';

  @override
  String get totalHarvest => 'Total Harvest';

  @override
  String get bucketsTimesKg => 'Buckets × Kg per bucket';

  @override
  String get harvestedWeightKg => 'Harvested Weight (Kg)';

  @override
  String get exampleHarvestWeight => 'Example: 18.5';

  @override
  String get treeHarvestRecordDescription =>
      'Harvest will be recorded in kilograms for the selected tree.';

  @override
  String get activityDate => 'Activity Date';

  @override
  String get harvestDate => 'Harvest Date';

  @override
  String get costTzs => 'Cost (TZS)';

  @override
  String get exampleCost => 'Example: 25000';

  @override
  String get enterDescription => 'Enter description...';

  @override
  String get saving => 'Saving...';

  @override
  String get saveActivity => 'Save Activity';

  @override
  String get saveFarmHarvest => 'Save Farm Harvest';

  @override
  String get saveTreeHarvest => 'Save Tree Harvest';

  @override
  String get treeActivitySaved => 'Tree activity saved successfully.';

  @override
  String get farmHarvestSaved => 'Farm harvest saved successfully.';

  @override
  String get treeHarvestSaved => 'Tree harvest saved successfully.';

  @override
  String get farmBlockTreeActivityRequired =>
      'Farm, block, tree and activity type are required.';

  @override
  String get farmBlockTreeRequired => 'Farm, block and tree are required.';

  @override
  String get costCannotBeNegative => 'Cost cannot be negative.';

  @override
  String get harvestKgGreaterThanZero =>
      'Harvested kilograms must be greater than zero.';

  @override
  String get bucketCountGreaterThanZero =>
      'Number of buckets must be greater than zero.';

  @override
  String get kgPerBucketGreaterThanZero =>
      'Kg per bucket must be greater than zero.';

  @override
  String fieldRequired(String field) {
    return '$field is required';
  }

  @override
  String get enterValidWholeNumber => 'Enter a valid whole number';

  @override
  String get enterValidNumber => 'Enter a valid number';

  @override
  String get valueCannotBeNegative => 'Value cannot be negative';

  @override
  String get valueGreaterThanZero => 'Value must be greater than zero';

  @override
  String get treeDetails => 'Tree Details';

  @override
  String get treeInformationNotFound => 'Tree information was not found.';

  @override
  String get unableToLoadTree => 'Unable to load tree';

  @override
  String get treeInformation => 'Tree Information';

  @override
  String get treeId => 'Tree ID';

  @override
  String plantedYear(String year) {
    return 'Planted $year';
  }

  @override
  String get scanTree => 'Scan Tree';

  @override
  String get scanTreeDescription =>
      'Scan a tree barcode to identify and view its information.';

  @override
  String get scanTreeBarcode => 'Scan Tree Barcode';

  @override
  String get treeIdentification => 'Tree Identification';

  @override
  String get scanBarcodeToIdentifyTree =>
      'Scan this barcode to identify this tree.';

  @override
  String get enlargeBarcode => 'Enlarge Barcode';

  @override
  String get treeBarcode => 'Tree Barcode';

  @override
  String get close => 'Close';

  @override
  String get gpsCoordinates => 'GPS Coordinates';

  @override
  String get noGpsCoordinatesRecorded => 'No GPS coordinates recorded';

  @override
  String get noNotesRecorded => 'No notes recorded';

  @override
  String get treeActivitiesDescription =>
      'Record and manage activities performed on this tree.';

  @override
  String get addViewTreeActivities => 'Add / View Tree Activities';

  @override
  String get activitiesPerformedOnTree => 'Activities performed on this tree';

  @override
  String get loadingTreeInformation => 'Loading tree information...';

  @override
  String get unableToLoadTreeInformation => 'Unable to load tree information';

  @override
  String cost(String amount) {
    return 'Cost: $amount';
  }

  @override
  String harvestedAmount(String amount) {
    return 'Harvested: $amount kg';
  }

  @override
  String get treeActivityAddedSuccessfully =>
      'Tree activity added successfully';

  @override
  String failedToSaveActivity(String error) {
    return 'Failed to save activity: $error';
  }

  @override
  String get addFirstTreeActivity => 'Add the first activity for this tree.';

  @override
  String recordActivityForTree(String treeId) {
    return 'Record activity for $treeId';
  }

  @override
  String get selectDate => 'Select date';

  @override
  String get selectActivityDate => 'Select activity date';

  @override
  String get describeActivityPerformed => 'Describe the activity performed...';

  @override
  String get descriptionRequired => 'Description is required';

  @override
  String get status => 'Status';

  @override
  String get treeNotFound => 'Tree Not Found';

  @override
  String noTreeFoundWithBarcode(String code) {
    return 'No tree was found with barcode:\n\n$code';
  }

  @override
  String get scanAgain => 'Scan Again';

  @override
  String get enterTreeCode => 'Enter Tree Code';

  @override
  String get treeCodeExample => 'Example: TR-0001';

  @override
  String get findTree => 'Find Tree';

  @override
  String get turnOnFlash => 'Turn on flash';

  @override
  String get turnOffFlash => 'Turn off flash';

  @override
  String get positionTreeBarcode =>
      'Position the barcode attached to the tree inside the scanning frame.';

  @override
  String get keepBarcodeSteady => 'Keep the barcode steady inside the frame';

  @override
  String get barcodeDetected => 'Barcode detected';

  @override
  String get scannerReady => 'Scanner Ready';

  @override
  String readingBarcode(String code) {
    return 'Reading $code';
  }

  @override
  String get waitingForTreeBarcode => 'Waiting for a tree barcode...';

  @override
  String get enterTreeCodeManually => 'Enter Tree Code Manually';

  @override
  String get treeBarcodeInformation =>
      'Each registered cashew tree has a unique barcode. Scan the barcode to quickly open the tree information.';

  @override
  String get cancel => 'Cancel';

  @override
  String get createAccount => 'Create Account';

  @override
  String get registerFarmerOrStaff => 'Register farmer or staff';

  @override
  String get fullName => 'Full Name';

  @override
  String get username => 'Username';

  @override
  String get phoneNumber => 'Phone Number';

  @override
  String get password => 'Password';

  @override
  String get confirmPassword => 'Confirm Password';

  @override
  String get register => 'Register';

  @override
  String get fullNameRequired => 'Full name is required';

  @override
  String get usernameRequired => 'Username is required';

  @override
  String get regionRequired => 'Region is required';

  @override
  String get districtRequired => 'District is required';

  @override
  String get wardRequired => 'Ward is required';

  @override
  String get villageRequired => 'Village is required';

  @override
  String get phoneNumberRequired => 'Phone number is required';

  @override
  String get passwordRequired => 'Password is required';

  @override
  String get minimumSixCharacters => 'Minimum 6 characters';

  @override
  String get confirmPasswordRequired => 'Confirm password is required';

  @override
  String get passwordsDoNotMatch => 'Passwords do not match';

  @override
  String get registrationSuccessful => 'Registration successful';

  @override
  String get cashewProductionManagementSystem =>
      'Cashew Production\nManagement System';

  @override
  String get signInToContinue => 'Sign in to continue';

  @override
  String get login => 'Login';

  @override
  String get loginSuccessful => 'Login successful';

  @override
  String get pleaseEnterUsername => 'Please enter your username';

  @override
  String get pleaseEnterPassword => 'Please enter your password';

  @override
  String get dontHaveAccount => 'Don\'t have an account?';

  @override
  String get showPassword => 'Show password';

  @override
  String get hidePassword => 'Hide password';
}
