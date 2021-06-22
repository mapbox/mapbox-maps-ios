# Add an access token to your project

## Overview

The first step to working with Mapbox Maps is to create an access token and integrate it with your app. For more information about creating a Mapbox access token, please see the [access token guide on our website](https://docs.mapbox.com/help/getting-started/access-tokens/). This article will discuss how to configure your Mapbox access token via a bash script, your `AppDelegate.swift` file, or storyboard.

## Adding your access token

### AppDelegate

```swift
func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    let accessToken = "{ YOUR ACCESS TOKEN }"
    ResourceOptionsManager.default.resourceOptions.accessToken = accessToken
    return true
}
```
### Bash script

If you are working with an open-source project, you will want to keep your access token secure. 

```bash
echo "Inserting Mapbox access token..."
token_file=~/.mapbox
token_file2=~/mapbox
token="$(cat $token_file 2>/dev/null || cat $token_file2 2>/dev/null)"
if [ "$token" ]; then
  plutil -replace MBXAccessToken -string $token "$TARGET_BUILD_DIR/$INFOPLIST_PATH"
  echo "Token insertion successful"
else
  echo \'error: Missing Mapbox access token\'
  echo "error: Get an access token from <https://www.mapbox.com/studio/account/tokens/>, then create a new file at $token_file that contains the access token."
  exit 1
fi

```
