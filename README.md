#  VirtualTourist
VirtualTourist is an app that gives the user the ability to long press a location on a map and view photos related to that location.


## Requiremnt
*  Xcode 10.2
* Swift 5


## APIs
VirtualTourit uses Flickr as a network source for its data.


## Build and Run VirtualTourist
### **Build**
To build VirtualTourist goto Product -> Build. Or simply press ⌘B.

### **Run**
To run VirtualTourist goto Product -> Run. Or simply press ⌘R.


## User's VirtualTourist Journey
* After the app launches you will see a map. If its the first launch or you didn't add any pins before, the map will have no pins. Otherwise all previos pins will be shown.
To add a pin simply long press the location in the map you want to add the pin to, and the pin will automatically appers.

![Map](/Screenshot/Map.png)

* Tapping the pin will take you to a collection of photos related to the location you choosed before. If there is no photos for the choosen location,  a sentece saying **Pin has no photos** will be desplayed as the title of the collections. Or if you saw all the photos from that location, the sentece will be saying **No more photos**. Otherwise there will be no title for the page and photos will be presented.

![Photo Collection](/Screenshot/PhotoCollection.png)

* Tapping `< Back` button on the left top corner of the page will take you back to the map. 
* Tapping `New Collection` button on the center buttom of the page will display a new collection of photos. 
* Tapping `Edit` on the top right corner will let you enter the _delete mode_. You will know that because you will see **Delete Mode** as the title of the page, the page color will change to dark gray color and instead of `Edit` you will see `Done`. In that mode when you select an image it will be emmidietly deleted. After you finish deleting unwanted photos, click `Done` to return to the normal mode.

![Delete Mode](/Screenshot/DeleteMode.png)

* In the normal mode selecting a photo will take you to a page showing only the selected photo in a bigger size, a `< Back`  button on the left top corner that returns you to the photo collection page and an action button `⏍` on the top right corner of the page.

![Photo](/Screenshot/Photo.png)

* Tapping that action button will open an activity controller where you can choose some action to do with the selected photo.

![Photo Actions](/Screenshot/Action.png)

Now you can take a tour around the world and enjoy the sightseeing. all virtually offcourse.  **VirtualTourist**

