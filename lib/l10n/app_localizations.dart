import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_sw.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('sw'),
  ];

  /// No description provided for @goodMorning.
  ///
  /// In en, this message translates to:
  /// **'Good morning,'**
  String get goodMorning;

  /// No description provided for @goodAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Good afternoon,'**
  String get goodAfternoon;

  /// No description provided for @goodEvening.
  ///
  /// In en, this message translates to:
  /// **'Good evening,'**
  String get goodEvening;

  /// No description provided for @changeLanguage.
  ///
  /// In en, this message translates to:
  /// **'Change Language'**
  String get changeLanguage;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @swahili.
  ///
  /// In en, this message translates to:
  /// **'Kiswahili'**
  String get swahili;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @farms.
  ///
  /// In en, this message translates to:
  /// **'Farms'**
  String get farms;

  /// No description provided for @trees.
  ///
  /// In en, this message translates to:
  /// **'Trees'**
  String get trees;

  /// No description provided for @harvested.
  ///
  /// In en, this message translates to:
  /// **'Harvested'**
  String get harvested;

  /// No description provided for @totalCost.
  ///
  /// In en, this message translates to:
  /// **'Total Cost'**
  String get totalCost;

  /// No description provided for @activities.
  ///
  /// In en, this message translates to:
  /// **'Activities'**
  String get activities;

  /// No description provided for @farmHarvests.
  ///
  /// In en, this message translates to:
  /// **'Farm Harvests'**
  String get farmHarvests;

  /// No description provided for @registered.
  ///
  /// In en, this message translates to:
  /// **'registered'**
  String get registered;

  /// No description provided for @recorded.
  ///
  /// In en, this message translates to:
  /// **'recorded'**
  String get recorded;

  /// No description provided for @totalHarvested.
  ///
  /// In en, this message translates to:
  /// **'total harvested'**
  String get totalHarvested;

  /// No description provided for @activityCosts.
  ///
  /// In en, this message translates to:
  /// **'activity costs'**
  String get activityCosts;

  /// No description provided for @productionOverview.
  ///
  /// In en, this message translates to:
  /// **'Production Overview'**
  String get productionOverview;

  /// No description provided for @treeHarvest.
  ///
  /// In en, this message translates to:
  /// **'Tree Harvest'**
  String get treeHarvest;

  /// No description provided for @farmHarvest.
  ///
  /// In en, this message translates to:
  /// **'Farm Harvest'**
  String get farmHarvest;

  /// No description provided for @upcomingActivities.
  ///
  /// In en, this message translates to:
  /// **'Upcoming Activities'**
  String get upcomingActivities;

  /// No description provided for @noUpcomingActivities.
  ///
  /// In en, this message translates to:
  /// **'No upcoming activities.'**
  String get noUpcomingActivities;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @more.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get more;

  /// No description provided for @unableToLoadDashboard.
  ///
  /// In en, this message translates to:
  /// **'Unable to load dashboard.'**
  String get unableToLoadDashboard;

  /// No description provided for @activity.
  ///
  /// In en, this message translates to:
  /// **'Activity'**
  String get activity;

  /// No description provided for @weeding.
  ///
  /// In en, this message translates to:
  /// **'Weeding'**
  String get weeding;

  /// No description provided for @pruning.
  ///
  /// In en, this message translates to:
  /// **'Pruning'**
  String get pruning;

  /// No description provided for @pesticideApplication.
  ///
  /// In en, this message translates to:
  /// **'Pesticide Application'**
  String get pesticideApplication;

  /// No description provided for @fertilizerApplication.
  ///
  /// In en, this message translates to:
  /// **'Fertilizer Application'**
  String get fertilizerApplication;

  /// No description provided for @harvesting.
  ///
  /// In en, this message translates to:
  /// **'Harvesting'**
  String get harvesting;

  /// No description provided for @other.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get other;

  /// No description provided for @farmDashboard.
  ///
  /// In en, this message translates to:
  /// **'Farm Dashboard'**
  String get farmDashboard;

  /// No description provided for @acres.
  ///
  /// In en, this message translates to:
  /// **'Acres'**
  String get acres;

  /// No description provided for @addFarm.
  ///
  /// In en, this message translates to:
  /// **'Add Farm'**
  String get addFarm;

  /// No description provided for @unableToLoadFarms.
  ///
  /// In en, this message translates to:
  /// **'Unable to load farms'**
  String get unableToLoadFarms;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @noFarmsAddedYet.
  ///
  /// In en, this message translates to:
  /// **'No farms added yet'**
  String get noFarmsAddedYet;

  /// No description provided for @addFirstFarmMessage.
  ///
  /// In en, this message translates to:
  /// **'Tap Add Farm to register your first farm.'**
  String get addFirstFarmMessage;

  /// No description provided for @viewFarm.
  ///
  /// In en, this message translates to:
  /// **'View Farm'**
  String get viewFarm;

  /// No description provided for @newFarm.
  ///
  /// In en, this message translates to:
  /// **'New farm'**
  String get newFarm;

  /// No description provided for @productionFarm.
  ///
  /// In en, this message translates to:
  /// **'Production farm'**
  String get productionFarm;

  /// No description provided for @farm.
  ///
  /// In en, this message translates to:
  /// **'Farm'**
  String get farm;

  /// No description provided for @locationNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'Location not available'**
  String get locationNotAvailable;

  /// No description provided for @planted.
  ///
  /// In en, this message translates to:
  /// **'Planted'**
  String get planted;

  /// No description provided for @totalTrees.
  ///
  /// In en, this message translates to:
  /// **'Total Trees'**
  String get totalTrees;

  /// No description provided for @registeredTrees.
  ///
  /// In en, this message translates to:
  /// **'Registered Trees'**
  String get registeredTrees;

  /// No description provided for @searchTreeHint.
  ///
  /// In en, this message translates to:
  /// **'Search tree by code, farm, block or variety'**
  String get searchTreeHint;

  /// No description provided for @treeCount.
  ///
  /// In en, this message translates to:
  /// **'{count} trees'**
  String treeCount(int count);

  /// No description provided for @refresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refresh;

  /// No description provided for @block.
  ///
  /// In en, this message translates to:
  /// **'Block'**
  String get block;

  /// No description provided for @viewTree.
  ///
  /// In en, this message translates to:
  /// **'View Tree'**
  String get viewTree;

  /// No description provided for @healthy.
  ///
  /// In en, this message translates to:
  /// **'Healthy'**
  String get healthy;

  /// No description provided for @diseased.
  ///
  /// In en, this message translates to:
  /// **'Diseased'**
  String get diseased;

  /// No description provided for @dead.
  ///
  /// In en, this message translates to:
  /// **'Dead'**
  String get dead;

  /// No description provided for @unableToLoadTrees.
  ///
  /// In en, this message translates to:
  /// **'Unable to load trees'**
  String get unableToLoadTrees;

  /// No description provided for @unknownError.
  ///
  /// In en, this message translates to:
  /// **'Unknown error'**
  String get unknownError;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get tryAgain;

  /// No description provided for @noTreesFound.
  ///
  /// In en, this message translates to:
  /// **'No trees found'**
  String get noTreesFound;

  /// No description provided for @noTreesRegistered.
  ///
  /// In en, this message translates to:
  /// **'No trees registered'**
  String get noTreesRegistered;

  /// No description provided for @tryAnotherTreeSearch.
  ///
  /// In en, this message translates to:
  /// **'Try another tree code, farm, block or variety.'**
  String get tryAnotherTreeSearch;

  /// No description provided for @registeredTreesAppearHere.
  ///
  /// In en, this message translates to:
  /// **'Trees registered in your farms will appear here.'**
  String get registeredTreesAppearHere;

  /// No description provided for @unableToOpenTree.
  ///
  /// In en, this message translates to:
  /// **'Unable to open this tree because its farm, block or tree ID is missing.'**
  String get unableToOpenTree;

  /// No description provided for @treeActivities.
  ///
  /// In en, this message translates to:
  /// **'Tree Activities'**
  String get treeActivities;

  /// No description provided for @activityPageDescription.
  ///
  /// In en, this message translates to:
  /// **'View and manage farm and tree activities.'**
  String get activityPageDescription;

  /// No description provided for @addActivity.
  ///
  /// In en, this message translates to:
  /// **'Add Activity'**
  String get addActivity;

  /// No description provided for @chooseActivityType.
  ///
  /// In en, this message translates to:
  /// **'Choose the type of activity you want to record.'**
  String get chooseActivityType;

  /// No description provided for @treeActivity.
  ///
  /// In en, this message translates to:
  /// **'Tree Activity'**
  String get treeActivity;

  /// No description provided for @treeActivityDescription.
  ///
  /// In en, this message translates to:
  /// **'Weeding, pruning, pesticide, fertilizer and other tree activities.'**
  String get treeActivityDescription;

  /// No description provided for @harvestingDescription.
  ///
  /// In en, this message translates to:
  /// **'Record farm harvesting or harvesting from a specific tree.'**
  String get harvestingDescription;

  /// No description provided for @harvestingMethod.
  ///
  /// In en, this message translates to:
  /// **'Harvesting Method'**
  String get harvestingMethod;

  /// No description provided for @howHarvestRecorded.
  ///
  /// In en, this message translates to:
  /// **'How was this harvest recorded?'**
  String get howHarvestRecorded;

  /// No description provided for @farmHarvesting.
  ///
  /// In en, this message translates to:
  /// **'Farm Harvesting'**
  String get farmHarvesting;

  /// No description provided for @farmHarvestingDescription.
  ///
  /// In en, this message translates to:
  /// **'Record harvest using number of buckets and kilograms per bucket.'**
  String get farmHarvestingDescription;

  /// No description provided for @treeHarvesting.
  ///
  /// In en, this message translates to:
  /// **'Tree Harvesting'**
  String get treeHarvesting;

  /// No description provided for @treeHarvestingDescription.
  ///
  /// In en, this message translates to:
  /// **'Record kilograms harvested from a specific cashew tree.'**
  String get treeHarvestingDescription;

  /// No description provided for @searchActivitiesHint.
  ///
  /// In en, this message translates to:
  /// **'Search tree, farm, block or activity...'**
  String get searchActivitiesHint;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @pesticide.
  ///
  /// In en, this message translates to:
  /// **'Pesticide'**
  String get pesticide;

  /// No description provided for @fertilizer.
  ///
  /// In en, this message translates to:
  /// **'Fertilizer'**
  String get fertilizer;

  /// No description provided for @recentActivities.
  ///
  /// In en, this message translates to:
  /// **'Recent Activities'**
  String get recentActivities;

  /// No description provided for @activitiesFound.
  ///
  /// In en, this message translates to:
  /// **'{count} found'**
  String activitiesFound(int count);

  /// No description provided for @viewTreeActivities.
  ///
  /// In en, this message translates to:
  /// **'View Tree Activities'**
  String get viewTreeActivities;

  /// No description provided for @loadingActivities.
  ///
  /// In en, this message translates to:
  /// **'Loading activities...'**
  String get loadingActivities;

  /// No description provided for @unableToLoadActivities.
  ///
  /// In en, this message translates to:
  /// **'Unable to load activities'**
  String get unableToLoadActivities;

  /// No description provided for @noActivitiesFound.
  ///
  /// In en, this message translates to:
  /// **'No activities found'**
  String get noActivitiesFound;

  /// No description provided for @noActivitiesRecorded.
  ///
  /// In en, this message translates to:
  /// **'No activities recorded'**
  String get noActivitiesRecorded;

  /// No description provided for @changeSearchOrFilter.
  ///
  /// In en, this message translates to:
  /// **'Try changing your search or filter.'**
  String get changeSearchOrFilter;

  /// No description provided for @activitiesAppearHere.
  ///
  /// In en, this message translates to:
  /// **'Activities added to your cashew trees will appear here.'**
  String get activitiesAppearHere;

  /// No description provided for @unableToOpenTreeActivities.
  ///
  /// In en, this message translates to:
  /// **'Unable to open tree activities. Tree relationship information is missing.'**
  String get unableToOpenTreeActivities;

  /// No description provided for @planned.
  ///
  /// In en, this message translates to:
  /// **'Planned'**
  String get planned;

  /// No description provided for @inProgress.
  ///
  /// In en, this message translates to:
  /// **'In Progress'**
  String get inProgress;

  /// No description provided for @completed.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completed;

  /// No description provided for @cancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get cancelled;

  /// No description provided for @unableToLoadProfile.
  ///
  /// In en, this message translates to:
  /// **'Unable to load profile'**
  String get unableToLoadProfile;

  /// No description provided for @personalInformation.
  ///
  /// In en, this message translates to:
  /// **'PERSONAL INFORMATION'**
  String get personalInformation;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// No description provided for @updateYourDetails.
  ///
  /// In en, this message translates to:
  /// **'Update your details'**
  String get updateYourDetails;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @enabled.
  ///
  /// In en, this message translates to:
  /// **'Enabled'**
  String get enabled;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @systemSecurity.
  ///
  /// In en, this message translates to:
  /// **'SYSTEM & SECURITY'**
  String get systemSecurity;

  /// No description provided for @lightDarkMode.
  ///
  /// In en, this message translates to:
  /// **'Light/Dark Mode'**
  String get lightDarkMode;

  /// No description provided for @privacySecurity.
  ///
  /// In en, this message translates to:
  /// **'Privacy & Security'**
  String get privacySecurity;

  /// No description provided for @support.
  ///
  /// In en, this message translates to:
  /// **'SUPPORT'**
  String get support;

  /// No description provided for @helpCenter.
  ///
  /// In en, this message translates to:
  /// **'Help Center'**
  String get helpCenter;

  /// No description provided for @termsOfService.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get termsOfService;

  /// No description provided for @uploads.
  ///
  /// In en, this message translates to:
  /// **'UPLOADS'**
  String get uploads;

  /// No description provided for @uploadFiles.
  ///
  /// In en, this message translates to:
  /// **'Upload Files'**
  String get uploadFiles;

  /// No description provided for @uploadFilesDescription.
  ///
  /// In en, this message translates to:
  /// **'Upload documents, images or ZIP files'**
  String get uploadFilesDescription;

  /// No description provided for @filesUploadedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Files uploaded successfully'**
  String get filesUploadedSuccessfully;

  /// No description provided for @uploadFailed.
  ///
  /// In en, this message translates to:
  /// **'Upload failed'**
  String get uploadFailed;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @poweredByTari.
  ///
  /// In en, this message translates to:
  /// **'Powered by TARI'**
  String get poweredByTari;

  /// No description provided for @active.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get active;

  /// No description provided for @user.
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get user;

  /// No description provided for @farmName.
  ///
  /// In en, this message translates to:
  /// **'Farm Name'**
  String get farmName;

  /// No description provided for @farmNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Farm name is required'**
  String get farmNameRequired;

  /// No description provided for @plantingDate.
  ///
  /// In en, this message translates to:
  /// **'Planting Date'**
  String get plantingDate;

  /// No description provided for @plantingDateRequired.
  ///
  /// In en, this message translates to:
  /// **'Planting date is required'**
  String get plantingDateRequired;

  /// No description provided for @farmType.
  ///
  /// In en, this message translates to:
  /// **'Farm Type'**
  String get farmType;

  /// No description provided for @selectFarmType.
  ///
  /// In en, this message translates to:
  /// **'Select Farm Type'**
  String get selectFarmType;

  /// No description provided for @farmTypeRequired.
  ///
  /// In en, this message translates to:
  /// **'Farm type is required'**
  String get farmTypeRequired;

  /// No description provided for @farmSize.
  ///
  /// In en, this message translates to:
  /// **'Farm Size'**
  String get farmSize;

  /// No description provided for @farmSizeRequired.
  ///
  /// In en, this message translates to:
  /// **'Farm size is required'**
  String get farmSizeRequired;

  /// No description provided for @validFarmSizeRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid farm size'**
  String get validFarmSizeRequired;

  /// No description provided for @drawFarmBoundary.
  ///
  /// In en, this message translates to:
  /// **'Draw Farm Boundary (GPS)'**
  String get drawFarmBoundary;

  /// No description provided for @redrawFarmBoundary.
  ///
  /// In en, this message translates to:
  /// **'Redraw Farm Boundary (GPS)'**
  String get redrawFarmBoundary;

  /// No description provided for @drawValidBoundary.
  ///
  /// In en, this message translates to:
  /// **'Draw a valid polygon boundary before submitting.'**
  String get drawValidBoundary;

  /// No description provided for @drawBoundaryForSize.
  ///
  /// In en, this message translates to:
  /// **'Draw the farm boundary to calculate the farm size'**
  String get drawBoundaryForSize;

  /// No description provided for @farmBoundary.
  ///
  /// In en, this message translates to:
  /// **'Draw Farm Boundary'**
  String get farmBoundary;

  /// No description provided for @mapPoint.
  ///
  /// In en, this message translates to:
  /// **'Point {number}'**
  String mapPoint(int number);

  /// No description provided for @undoLastPoint.
  ///
  /// In en, this message translates to:
  /// **'Undo last point'**
  String get undoLastPoint;

  /// No description provided for @clearAllPoints.
  ///
  /// In en, this message translates to:
  /// **'Clear all points'**
  String get clearAllPoints;

  /// No description provided for @waitingForGps.
  ///
  /// In en, this message translates to:
  /// **'Waiting for GPS...'**
  String get waitingForGps;

  /// No description provided for @gpsUnavailableRetry.
  ///
  /// In en, this message translates to:
  /// **'GPS unavailable (tap to retry)'**
  String get gpsUnavailableRetry;

  /// No description provided for @gpsPointTooClose.
  ///
  /// In en, this message translates to:
  /// **'You are still at the last point. Walk to the next corner of the farm first.'**
  String get gpsPointTooClose;

  /// No description provided for @gpsLowAccuracy.
  ///
  /// In en, this message translates to:
  /// **'Point {count} added, but GPS accuracy is low (+/-{accuracy} m). Undo it and retry in an open area for a better result.'**
  String gpsLowAccuracy(int count, int accuracy);

  /// No description provided for @gpsFixUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Could not get a GPS fix. Move to an open area and try again.'**
  String get gpsFixUnavailable;

  /// No description provided for @gpsServicesRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enable GPS location services'**
  String get gpsServicesRequired;

  /// No description provided for @gpsPermissionPermanentlyDenied.
  ///
  /// In en, this message translates to:
  /// **'Location permission is permanently denied. Enable it in app settings'**
  String get gpsPermissionPermanentlyDenied;

  /// No description provided for @gpsPermissionRequired.
  ///
  /// In en, this message translates to:
  /// **'Location permission is required to map the farm'**
  String get gpsPermissionRequired;

  /// No description provided for @addThreeBoundaryPoints.
  ///
  /// In en, this message translates to:
  /// **'Add at least three points to form a boundary.'**
  String get addThreeBoundaryPoints;

  /// No description provided for @boundarySelfIntersecting.
  ///
  /// In en, this message translates to:
  /// **'The boundary lines cross each other. Undo the last point or clear and start again.'**
  String get boundarySelfIntersecting;

  /// No description provided for @boundaryStartInstructions.
  ///
  /// In en, this message translates to:
  /// **'Stand at one corner of your farm and tap \"Add my current location\". Then walk to each next corner and repeat.'**
  String get boundaryStartInstructions;

  /// No description provided for @boundaryPointsAdded.
  ///
  /// In en, this message translates to:
  /// **'{count} points added. Add at least {remaining} more.'**
  String boundaryPointsAdded(int count, int remaining);

  /// No description provided for @boundaryArea.
  ///
  /// In en, this message translates to:
  /// **'{count} points  •  {area} acres'**
  String boundaryArea(int count, String area);

  /// No description provided for @gettingGpsLocation.
  ///
  /// In en, this message translates to:
  /// **'Getting GPS location...'**
  String get gettingGpsLocation;

  /// No description provided for @addCurrentLocation.
  ///
  /// In en, this message translates to:
  /// **'Add my current location'**
  String get addCurrentLocation;

  /// No description provided for @saveBoundary.
  ///
  /// In en, this message translates to:
  /// **'Save boundary'**
  String get saveBoundary;

  /// No description provided for @submitFarm.
  ///
  /// In en, this message translates to:
  /// **'Submit Farm'**
  String get submitFarm;

  /// No description provided for @farmAddedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Farm added successfully'**
  String get farmAddedSuccessfully;

  /// No description provided for @profileLocationIncomplete.
  ///
  /// In en, this message translates to:
  /// **'Your profile location information is incomplete'**
  String get profileLocationIncomplete;

  /// No description provided for @farmDetails.
  ///
  /// In en, this message translates to:
  /// **'Farm Details'**
  String get farmDetails;

  /// No description provided for @farmInformation.
  ///
  /// In en, this message translates to:
  /// **'Farm Information'**
  String get farmInformation;

  /// No description provided for @farmId.
  ///
  /// In en, this message translates to:
  /// **'Farm ID'**
  String get farmId;

  /// No description provided for @viewBlocks.
  ///
  /// In en, this message translates to:
  /// **'View Blocks'**
  String get viewBlocks;

  /// No description provided for @location.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get location;

  /// No description provided for @region.
  ///
  /// In en, this message translates to:
  /// **'Region'**
  String get region;

  /// No description provided for @district.
  ///
  /// In en, this message translates to:
  /// **'District'**
  String get district;

  /// No description provided for @ward.
  ///
  /// In en, this message translates to:
  /// **'Ward'**
  String get ward;

  /// No description provided for @village.
  ///
  /// In en, this message translates to:
  /// **'Village'**
  String get village;

  /// No description provided for @productionSummary.
  ///
  /// In en, this message translates to:
  /// **'Production Summary'**
  String get productionSummary;

  /// No description provided for @totalProduction.
  ///
  /// In en, this message translates to:
  /// **'Total production'**
  String get totalProduction;

  /// No description provided for @averageProduction.
  ///
  /// In en, this message translates to:
  /// **'Average production'**
  String get averageProduction;

  /// No description provided for @productionHistory.
  ///
  /// In en, this message translates to:
  /// **'Production History'**
  String get productionHistory;

  /// No description provided for @noProductionRecords.
  ///
  /// In en, this message translates to:
  /// **'No production records available yet.'**
  String get noProductionRecords;

  /// No description provided for @unnamedFarm.
  ///
  /// In en, this message translates to:
  /// **'Unnamed Farm'**
  String get unnamedFarm;

  /// No description provided for @farmBlocks.
  ///
  /// In en, this message translates to:
  /// **'Farm Blocks'**
  String get farmBlocks;

  /// No description provided for @blocks.
  ///
  /// In en, this message translates to:
  /// **'Blocks'**
  String get blocks;

  /// No description provided for @blockCount.
  ///
  /// In en, this message translates to:
  /// **'Blocks ({count})'**
  String blockCount(int count);

  /// No description provided for @addBlock.
  ///
  /// In en, this message translates to:
  /// **'Add Block'**
  String get addBlock;

  /// No description provided for @loadingBlocks.
  ///
  /// In en, this message translates to:
  /// **'Loading blocks...'**
  String get loadingBlocks;

  /// No description provided for @unableToLoadBlocks.
  ///
  /// In en, this message translates to:
  /// **'Unable to load blocks'**
  String get unableToLoadBlocks;

  /// No description provided for @noBlocksYet.
  ///
  /// In en, this message translates to:
  /// **'No blocks yet'**
  String get noBlocksYet;

  /// No description provided for @createFirstBlock.
  ///
  /// In en, this message translates to:
  /// **'Create the first block for this farm.'**
  String get createFirstBlock;

  /// No description provided for @unnamedBlock.
  ///
  /// In en, this message translates to:
  /// **'Unnamed Block'**
  String get unnamedBlock;

  /// No description provided for @size.
  ///
  /// In en, this message translates to:
  /// **'Size'**
  String get size;

  /// No description provided for @variety.
  ///
  /// In en, this message translates to:
  /// **'Variety'**
  String get variety;

  /// No description provided for @viewBlock.
  ///
  /// In en, this message translates to:
  /// **'View Block'**
  String get viewBlock;

  /// No description provided for @blockName.
  ///
  /// In en, this message translates to:
  /// **'Block Name'**
  String get blockName;

  /// No description provided for @blockNameHint.
  ///
  /// In en, this message translates to:
  /// **'Block name'**
  String get blockNameHint;

  /// No description provided for @blockNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Block name is required'**
  String get blockNameRequired;

  /// No description provided for @blockSize.
  ///
  /// In en, this message translates to:
  /// **'Block Size'**
  String get blockSize;

  /// No description provided for @blockSizeHint.
  ///
  /// In en, this message translates to:
  /// **'Block size / acres'**
  String get blockSizeHint;

  /// No description provided for @blockSizeRequired.
  ///
  /// In en, this message translates to:
  /// **'Block size is required'**
  String get blockSizeRequired;

  /// No description provided for @validBlockSizeRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid block size'**
  String get validBlockSizeRequired;

  /// No description provided for @numberOfTrees.
  ///
  /// In en, this message translates to:
  /// **'Number of Trees'**
  String get numberOfTrees;

  /// No description provided for @numberOfTreesHint.
  ///
  /// In en, this message translates to:
  /// **'Number of trees'**
  String get numberOfTreesHint;

  /// No description provided for @numberOfTreesRequired.
  ///
  /// In en, this message translates to:
  /// **'Number of trees is required'**
  String get numberOfTreesRequired;

  /// No description provided for @validNumberOfTreesRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid number of trees'**
  String get validNumberOfTreesRequired;

  /// No description provided for @cashewVariety.
  ///
  /// In en, this message translates to:
  /// **'Cashew Variety'**
  String get cashewVariety;

  /// No description provided for @cashewVarietyHint.
  ///
  /// In en, this message translates to:
  /// **'Cashew variety'**
  String get cashewVarietyHint;

  /// No description provided for @cashewVarietyRequired.
  ///
  /// In en, this message translates to:
  /// **'Cashew variety is required'**
  String get cashewVarietyRequired;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @blockDescriptionHint.
  ///
  /// In en, this message translates to:
  /// **'Notes / block description'**
  String get blockDescriptionHint;

  /// No description provided for @submitBlock.
  ///
  /// In en, this message translates to:
  /// **'Submit Block'**
  String get submitBlock;

  /// No description provided for @blockAddedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Block added successfully'**
  String get blockAddedSuccessfully;

  /// No description provided for @blockDetails.
  ///
  /// In en, this message translates to:
  /// **'Block Details'**
  String get blockDetails;

  /// No description provided for @blockInformation.
  ///
  /// In en, this message translates to:
  /// **'Block Information'**
  String get blockInformation;

  /// No description provided for @blockId.
  ///
  /// In en, this message translates to:
  /// **'Block ID'**
  String get blockId;

  /// No description provided for @blockSummary.
  ///
  /// In en, this message translates to:
  /// **'Block Summary'**
  String get blockSummary;

  /// No description provided for @varieties.
  ///
  /// In en, this message translates to:
  /// **'Varieties'**
  String get varieties;

  /// No description provided for @addTree.
  ///
  /// In en, this message translates to:
  /// **'Add Tree'**
  String get addTree;

  /// No description provided for @noTreesInBlock.
  ///
  /// In en, this message translates to:
  /// **'No trees registered in this block'**
  String get noTreesInBlock;

  /// No description provided for @addFirstTreeMessage.
  ///
  /// In en, this message translates to:
  /// **'Tap Add Tree to register the first tree.'**
  String get addFirstTreeMessage;

  /// No description provided for @addingTreeTo.
  ///
  /// In en, this message translates to:
  /// **'Adding tree to'**
  String get addingTreeTo;

  /// No description provided for @plantingYear.
  ///
  /// In en, this message translates to:
  /// **'Planting Year'**
  String get plantingYear;

  /// No description provided for @plantingYearHint.
  ///
  /// In en, this message translates to:
  /// **'Planting year'**
  String get plantingYearHint;

  /// No description provided for @selectPlantingYear.
  ///
  /// In en, this message translates to:
  /// **'Select planting year'**
  String get selectPlantingYear;

  /// No description provided for @plantingYearRequired.
  ///
  /// In en, this message translates to:
  /// **'Planting year is required'**
  String get plantingYearRequired;

  /// No description provided for @invalidPlantingYear.
  ///
  /// In en, this message translates to:
  /// **'Invalid planting year'**
  String get invalidPlantingYear;

  /// No description provided for @validPlantingYearRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid planting year'**
  String get validPlantingYearRequired;

  /// No description provided for @treeStatus.
  ///
  /// In en, this message translates to:
  /// **'Tree Status'**
  String get treeStatus;

  /// No description provided for @treeStatusHint.
  ///
  /// In en, this message translates to:
  /// **'Tree status'**
  String get treeStatusHint;

  /// No description provided for @treeLocation.
  ///
  /// In en, this message translates to:
  /// **'Tree Location'**
  String get treeLocation;

  /// No description provided for @treeLocationDescription.
  ///
  /// In en, this message translates to:
  /// **'Optional WKT point geometry for this tree.'**
  String get treeLocationDescription;

  /// No description provided for @geometry.
  ///
  /// In en, this message translates to:
  /// **'Geometry'**
  String get geometry;

  /// No description provided for @notes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notes;

  /// No description provided for @treeNotesHint.
  ///
  /// In en, this message translates to:
  /// **'Notes / tree description'**
  String get treeNotesHint;

  /// No description provided for @treeAddedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Tree added successfully'**
  String get treeAddedSuccessfully;

  /// No description provided for @addTreeActivity.
  ///
  /// In en, this message translates to:
  /// **'Add Tree Activity'**
  String get addTreeActivity;

  /// No description provided for @treeActivitySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Select a farm, block and cashew tree, then record the activity and its cost.'**
  String get treeActivitySubtitle;

  /// No description provided for @farmHarvestSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Select a farm and record the number of buckets, kilograms per bucket and harvesting cost.'**
  String get farmHarvestSubtitle;

  /// No description provided for @treeHarvestSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Select a farm, block and cashew tree, then record the kilograms harvested from the tree.'**
  String get treeHarvestSubtitle;

  /// No description provided for @activityInformation.
  ///
  /// In en, this message translates to:
  /// **'Activity Information'**
  String get activityInformation;

  /// No description provided for @harvestInformation.
  ///
  /// In en, this message translates to:
  /// **'Harvest Information'**
  String get harvestInformation;

  /// No description provided for @selectFarm.
  ///
  /// In en, this message translates to:
  /// **'Select farm'**
  String get selectFarm;

  /// No description provided for @farmRequired.
  ///
  /// In en, this message translates to:
  /// **'Farm is required'**
  String get farmRequired;

  /// No description provided for @pleaseSelectFarm.
  ///
  /// In en, this message translates to:
  /// **'Please select a farm.'**
  String get pleaseSelectFarm;

  /// No description provided for @loadingFarms.
  ///
  /// In en, this message translates to:
  /// **'Loading farms...'**
  String get loadingFarms;

  /// No description provided for @selectFarmFirst.
  ///
  /// In en, this message translates to:
  /// **'Select farm first'**
  String get selectFarmFirst;

  /// No description provided for @selectBlock.
  ///
  /// In en, this message translates to:
  /// **'Select block'**
  String get selectBlock;

  /// No description provided for @blockRequired.
  ///
  /// In en, this message translates to:
  /// **'Block is required'**
  String get blockRequired;

  /// No description provided for @pleaseSelectBlock.
  ///
  /// In en, this message translates to:
  /// **'Please select a block.'**
  String get pleaseSelectBlock;

  /// No description provided for @noBlocksForFarm.
  ///
  /// In en, this message translates to:
  /// **'No blocks found for this farm'**
  String get noBlocksForFarm;

  /// No description provided for @cashewTree.
  ///
  /// In en, this message translates to:
  /// **'Cashew Tree'**
  String get cashewTree;

  /// No description provided for @selectBlockFirst.
  ///
  /// In en, this message translates to:
  /// **'Select block first'**
  String get selectBlockFirst;

  /// No description provided for @selectTree.
  ///
  /// In en, this message translates to:
  /// **'Select tree'**
  String get selectTree;

  /// No description provided for @treeRequired.
  ///
  /// In en, this message translates to:
  /// **'Tree is required'**
  String get treeRequired;

  /// No description provided for @pleaseSelectTree.
  ///
  /// In en, this message translates to:
  /// **'Please select a tree.'**
  String get pleaseSelectTree;

  /// No description provided for @loadingTrees.
  ///
  /// In en, this message translates to:
  /// **'Loading trees...'**
  String get loadingTrees;

  /// No description provided for @noTreesForBlock.
  ///
  /// In en, this message translates to:
  /// **'No trees found for this block'**
  String get noTreesForBlock;

  /// No description provided for @activityType.
  ///
  /// In en, this message translates to:
  /// **'Activity Type'**
  String get activityType;

  /// No description provided for @selectActivity.
  ///
  /// In en, this message translates to:
  /// **'Select activity'**
  String get selectActivity;

  /// No description provided for @activityTypeRequired.
  ///
  /// In en, this message translates to:
  /// **'Activity type is required'**
  String get activityTypeRequired;

  /// No description provided for @numberOfBuckets.
  ///
  /// In en, this message translates to:
  /// **'Number of Buckets'**
  String get numberOfBuckets;

  /// No description provided for @kgPerBucket.
  ///
  /// In en, this message translates to:
  /// **'Kg per Bucket'**
  String get kgPerBucket;

  /// No description provided for @example20.
  ///
  /// In en, this message translates to:
  /// **'Example: 20'**
  String get example20;

  /// No description provided for @example15.
  ///
  /// In en, this message translates to:
  /// **'Example: 15'**
  String get example15;

  /// No description provided for @totalHarvest.
  ///
  /// In en, this message translates to:
  /// **'Total Harvest'**
  String get totalHarvest;

  /// No description provided for @bucketsTimesKg.
  ///
  /// In en, this message translates to:
  /// **'Buckets × Kg per bucket'**
  String get bucketsTimesKg;

  /// No description provided for @harvestedWeightKg.
  ///
  /// In en, this message translates to:
  /// **'Harvested Weight (Kg)'**
  String get harvestedWeightKg;

  /// No description provided for @exampleHarvestWeight.
  ///
  /// In en, this message translates to:
  /// **'Example: 18.5'**
  String get exampleHarvestWeight;

  /// No description provided for @treeHarvestRecordDescription.
  ///
  /// In en, this message translates to:
  /// **'Harvest will be recorded in kilograms for the selected tree.'**
  String get treeHarvestRecordDescription;

  /// No description provided for @activityDate.
  ///
  /// In en, this message translates to:
  /// **'Activity Date'**
  String get activityDate;

  /// No description provided for @harvestDate.
  ///
  /// In en, this message translates to:
  /// **'Harvest Date'**
  String get harvestDate;

  /// No description provided for @costTzs.
  ///
  /// In en, this message translates to:
  /// **'Cost (TZS)'**
  String get costTzs;

  /// No description provided for @exampleCost.
  ///
  /// In en, this message translates to:
  /// **'Example: 25000'**
  String get exampleCost;

  /// No description provided for @enterDescription.
  ///
  /// In en, this message translates to:
  /// **'Enter description...'**
  String get enterDescription;

  /// No description provided for @saving.
  ///
  /// In en, this message translates to:
  /// **'Saving...'**
  String get saving;

  /// No description provided for @saveActivity.
  ///
  /// In en, this message translates to:
  /// **'Save Activity'**
  String get saveActivity;

  /// No description provided for @saveFarmHarvest.
  ///
  /// In en, this message translates to:
  /// **'Save Farm Harvest'**
  String get saveFarmHarvest;

  /// No description provided for @saveTreeHarvest.
  ///
  /// In en, this message translates to:
  /// **'Save Tree Harvest'**
  String get saveTreeHarvest;

  /// No description provided for @treeActivitySaved.
  ///
  /// In en, this message translates to:
  /// **'Tree activity saved successfully.'**
  String get treeActivitySaved;

  /// No description provided for @farmHarvestSaved.
  ///
  /// In en, this message translates to:
  /// **'Farm harvest saved successfully.'**
  String get farmHarvestSaved;

  /// No description provided for @treeHarvestSaved.
  ///
  /// In en, this message translates to:
  /// **'Tree harvest saved successfully.'**
  String get treeHarvestSaved;

  /// No description provided for @farmBlockTreeActivityRequired.
  ///
  /// In en, this message translates to:
  /// **'Farm, block, tree and activity type are required.'**
  String get farmBlockTreeActivityRequired;

  /// No description provided for @farmBlockTreeRequired.
  ///
  /// In en, this message translates to:
  /// **'Farm, block and tree are required.'**
  String get farmBlockTreeRequired;

  /// No description provided for @costCannotBeNegative.
  ///
  /// In en, this message translates to:
  /// **'Cost cannot be negative.'**
  String get costCannotBeNegative;

  /// No description provided for @harvestKgGreaterThanZero.
  ///
  /// In en, this message translates to:
  /// **'Harvested kilograms must be greater than zero.'**
  String get harvestKgGreaterThanZero;

  /// No description provided for @bucketCountGreaterThanZero.
  ///
  /// In en, this message translates to:
  /// **'Number of buckets must be greater than zero.'**
  String get bucketCountGreaterThanZero;

  /// No description provided for @kgPerBucketGreaterThanZero.
  ///
  /// In en, this message translates to:
  /// **'Kg per bucket must be greater than zero.'**
  String get kgPerBucketGreaterThanZero;

  /// No description provided for @fieldRequired.
  ///
  /// In en, this message translates to:
  /// **'{field} is required'**
  String fieldRequired(String field);

  /// No description provided for @enterValidWholeNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid whole number'**
  String get enterValidWholeNumber;

  /// No description provided for @enterValidNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid number'**
  String get enterValidNumber;

  /// No description provided for @valueCannotBeNegative.
  ///
  /// In en, this message translates to:
  /// **'Value cannot be negative'**
  String get valueCannotBeNegative;

  /// No description provided for @valueGreaterThanZero.
  ///
  /// In en, this message translates to:
  /// **'Value must be greater than zero'**
  String get valueGreaterThanZero;

  /// No description provided for @treeDetails.
  ///
  /// In en, this message translates to:
  /// **'Tree Details'**
  String get treeDetails;

  /// No description provided for @treeInformationNotFound.
  ///
  /// In en, this message translates to:
  /// **'Tree information was not found.'**
  String get treeInformationNotFound;

  /// No description provided for @unableToLoadTree.
  ///
  /// In en, this message translates to:
  /// **'Unable to load tree'**
  String get unableToLoadTree;

  /// No description provided for @treeInformation.
  ///
  /// In en, this message translates to:
  /// **'Tree Information'**
  String get treeInformation;

  /// No description provided for @treeId.
  ///
  /// In en, this message translates to:
  /// **'Tree ID'**
  String get treeId;

  /// No description provided for @plantedYear.
  ///
  /// In en, this message translates to:
  /// **'Planted {year}'**
  String plantedYear(String year);

  /// No description provided for @scanTree.
  ///
  /// In en, this message translates to:
  /// **'Scan Tree'**
  String get scanTree;

  /// No description provided for @scanTreeDescription.
  ///
  /// In en, this message translates to:
  /// **'Scan a tree barcode to identify and view its information.'**
  String get scanTreeDescription;

  /// No description provided for @scanTreeBarcode.
  ///
  /// In en, this message translates to:
  /// **'Scan Tree Barcode'**
  String get scanTreeBarcode;

  /// No description provided for @treeIdentification.
  ///
  /// In en, this message translates to:
  /// **'Tree Identification'**
  String get treeIdentification;

  /// No description provided for @scanBarcodeToIdentifyTree.
  ///
  /// In en, this message translates to:
  /// **'Scan this barcode to identify this tree.'**
  String get scanBarcodeToIdentifyTree;

  /// No description provided for @enlargeBarcode.
  ///
  /// In en, this message translates to:
  /// **'Enlarge Barcode'**
  String get enlargeBarcode;

  /// No description provided for @treeBarcode.
  ///
  /// In en, this message translates to:
  /// **'Tree Barcode'**
  String get treeBarcode;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @gpsCoordinates.
  ///
  /// In en, this message translates to:
  /// **'GPS Coordinates'**
  String get gpsCoordinates;

  /// No description provided for @noGpsCoordinatesRecorded.
  ///
  /// In en, this message translates to:
  /// **'No GPS coordinates recorded'**
  String get noGpsCoordinatesRecorded;

  /// No description provided for @noNotesRecorded.
  ///
  /// In en, this message translates to:
  /// **'No notes recorded'**
  String get noNotesRecorded;

  /// No description provided for @treeActivitiesDescription.
  ///
  /// In en, this message translates to:
  /// **'Record and manage activities performed on this tree.'**
  String get treeActivitiesDescription;

  /// No description provided for @addViewTreeActivities.
  ///
  /// In en, this message translates to:
  /// **'Add / View Tree Activities'**
  String get addViewTreeActivities;

  /// No description provided for @activitiesPerformedOnTree.
  ///
  /// In en, this message translates to:
  /// **'Activities performed on this tree'**
  String get activitiesPerformedOnTree;

  /// No description provided for @loadingTreeInformation.
  ///
  /// In en, this message translates to:
  /// **'Loading tree information...'**
  String get loadingTreeInformation;

  /// No description provided for @unableToLoadTreeInformation.
  ///
  /// In en, this message translates to:
  /// **'Unable to load tree information'**
  String get unableToLoadTreeInformation;

  /// No description provided for @cost.
  ///
  /// In en, this message translates to:
  /// **'Cost: {amount}'**
  String cost(String amount);

  /// No description provided for @harvestedAmount.
  ///
  /// In en, this message translates to:
  /// **'Harvested: {amount} kg'**
  String harvestedAmount(String amount);

  /// No description provided for @treeActivityAddedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Tree activity added successfully'**
  String get treeActivityAddedSuccessfully;

  /// No description provided for @failedToSaveActivity.
  ///
  /// In en, this message translates to:
  /// **'Failed to save activity: {error}'**
  String failedToSaveActivity(String error);

  /// No description provided for @addFirstTreeActivity.
  ///
  /// In en, this message translates to:
  /// **'Add the first activity for this tree.'**
  String get addFirstTreeActivity;

  /// No description provided for @recordActivityForTree.
  ///
  /// In en, this message translates to:
  /// **'Record activity for {treeId}'**
  String recordActivityForTree(String treeId);

  /// No description provided for @selectDate.
  ///
  /// In en, this message translates to:
  /// **'Select date'**
  String get selectDate;

  /// No description provided for @selectActivityDate.
  ///
  /// In en, this message translates to:
  /// **'Select activity date'**
  String get selectActivityDate;

  /// No description provided for @describeActivityPerformed.
  ///
  /// In en, this message translates to:
  /// **'Describe the activity performed...'**
  String get describeActivityPerformed;

  /// No description provided for @descriptionRequired.
  ///
  /// In en, this message translates to:
  /// **'Description is required'**
  String get descriptionRequired;

  /// No description provided for @status.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status;

  /// No description provided for @treeNotFound.
  ///
  /// In en, this message translates to:
  /// **'Tree Not Found'**
  String get treeNotFound;

  /// No description provided for @noTreeFoundWithBarcode.
  ///
  /// In en, this message translates to:
  /// **'No tree was found with barcode:\n\n{code}'**
  String noTreeFoundWithBarcode(String code);

  /// No description provided for @scanAgain.
  ///
  /// In en, this message translates to:
  /// **'Scan Again'**
  String get scanAgain;

  /// No description provided for @enterTreeCode.
  ///
  /// In en, this message translates to:
  /// **'Enter Tree Code'**
  String get enterTreeCode;

  /// No description provided for @treeCodeExample.
  ///
  /// In en, this message translates to:
  /// **'Example: TR-0001'**
  String get treeCodeExample;

  /// No description provided for @findTree.
  ///
  /// In en, this message translates to:
  /// **'Find Tree'**
  String get findTree;

  /// No description provided for @turnOnFlash.
  ///
  /// In en, this message translates to:
  /// **'Turn on flash'**
  String get turnOnFlash;

  /// No description provided for @turnOffFlash.
  ///
  /// In en, this message translates to:
  /// **'Turn off flash'**
  String get turnOffFlash;

  /// No description provided for @positionTreeBarcode.
  ///
  /// In en, this message translates to:
  /// **'Position the barcode attached to the tree inside the scanning frame.'**
  String get positionTreeBarcode;

  /// No description provided for @keepBarcodeSteady.
  ///
  /// In en, this message translates to:
  /// **'Keep the barcode steady inside the frame'**
  String get keepBarcodeSteady;

  /// No description provided for @barcodeDetected.
  ///
  /// In en, this message translates to:
  /// **'Barcode detected'**
  String get barcodeDetected;

  /// No description provided for @scannerReady.
  ///
  /// In en, this message translates to:
  /// **'Scanner Ready'**
  String get scannerReady;

  /// No description provided for @readingBarcode.
  ///
  /// In en, this message translates to:
  /// **'Reading {code}'**
  String readingBarcode(String code);

  /// No description provided for @waitingForTreeBarcode.
  ///
  /// In en, this message translates to:
  /// **'Waiting for a tree barcode...'**
  String get waitingForTreeBarcode;

  /// No description provided for @enterTreeCodeManually.
  ///
  /// In en, this message translates to:
  /// **'Enter Tree Code Manually'**
  String get enterTreeCodeManually;

  /// No description provided for @treeBarcodeInformation.
  ///
  /// In en, this message translates to:
  /// **'Each registered cashew tree has a unique barcode. Scan the barcode to quickly open the tree information.'**
  String get treeBarcodeInformation;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccount;

  /// No description provided for @registerFarmerOrStaff.
  ///
  /// In en, this message translates to:
  /// **'Register farmer or staff'**
  String get registerFarmerOrStaff;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullName;

  /// No description provided for @username.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get username;

  /// No description provided for @phoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phoneNumber;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// No description provided for @fullNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Full name is required'**
  String get fullNameRequired;

  /// No description provided for @usernameRequired.
  ///
  /// In en, this message translates to:
  /// **'Username is required'**
  String get usernameRequired;

  /// No description provided for @regionRequired.
  ///
  /// In en, this message translates to:
  /// **'Region is required'**
  String get regionRequired;

  /// No description provided for @districtRequired.
  ///
  /// In en, this message translates to:
  /// **'District is required'**
  String get districtRequired;

  /// No description provided for @wardRequired.
  ///
  /// In en, this message translates to:
  /// **'Ward is required'**
  String get wardRequired;

  /// No description provided for @villageRequired.
  ///
  /// In en, this message translates to:
  /// **'Village is required'**
  String get villageRequired;

  /// No description provided for @phoneNumberRequired.
  ///
  /// In en, this message translates to:
  /// **'Phone number is required'**
  String get phoneNumberRequired;

  /// No description provided for @passwordRequired.
  ///
  /// In en, this message translates to:
  /// **'Password is required'**
  String get passwordRequired;

  /// No description provided for @minimumSixCharacters.
  ///
  /// In en, this message translates to:
  /// **'Minimum 6 characters'**
  String get minimumSixCharacters;

  /// No description provided for @confirmPasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'Confirm password is required'**
  String get confirmPasswordRequired;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsDoNotMatch;

  /// No description provided for @registrationSuccessful.
  ///
  /// In en, this message translates to:
  /// **'Registration successful'**
  String get registrationSuccessful;

  /// No description provided for @cashewProductionManagementSystem.
  ///
  /// In en, this message translates to:
  /// **'Cashew Production\nManagement System'**
  String get cashewProductionManagementSystem;

  /// No description provided for @signInToContinue.
  ///
  /// In en, this message translates to:
  /// **'Sign in to continue'**
  String get signInToContinue;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @loginSuccessful.
  ///
  /// In en, this message translates to:
  /// **'Login successful'**
  String get loginSuccessful;

  /// No description provided for @pleaseEnterUsername.
  ///
  /// In en, this message translates to:
  /// **'Please enter your username'**
  String get pleaseEnterUsername;

  /// No description provided for @pleaseEnterPassword.
  ///
  /// In en, this message translates to:
  /// **'Please enter your password'**
  String get pleaseEnterPassword;

  /// No description provided for @dontHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get dontHaveAccount;

  /// No description provided for @showPassword.
  ///
  /// In en, this message translates to:
  /// **'Show password'**
  String get showPassword;

  /// No description provided for @hidePassword.
  ///
  /// In en, this message translates to:
  /// **'Hide password'**
  String get hidePassword;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'sw'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'sw':
      return AppLocalizationsSw();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
