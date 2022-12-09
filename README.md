<p align="center"><img src="https://github.com/4d-for-ios/4d-for-ios-form-list-MapList/blob/master/template.gif" alt="Map List" height="auto" width="300"></p>

## Map List

* **Type:** Collection
* **Section:** not available
* **Actions:** cell long pressure
* **Image required:** yes

## How to integrate

* To use a custom list form template, the first thing you'll need to do is create a YourDatabase.4dbase/Resources/Mobile/form/list folder.
* Then drop the list form folder into it.

## Configure (Android only)

⚠️ You must edit GOOGLE_MAPS_API_KEY in [android/local.properties](https://github.com/4d-go-mobile/form-list-MapList/blob/2ee62a5fd3ec4b1740f3474205eff621c8acae52/android/local.properties) value with your `API key`.

To get your `API key`, you will need to enable Maps SDK for Android in Google Console.
You can read more about configuring a Google API project, follow this [Set up in Google Console guide](https://developers.google.com/maps/documentation/android-sdk/start#get-key)

## Requirements (Android only)

4D 19R8 minimum
