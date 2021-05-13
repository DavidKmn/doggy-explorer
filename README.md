
# doggy-explorer

## Architecture

The way I approached this app is to use a reactive (Combine driven) MVVM + Coordinator architecture. The architecture is unidirectional and is focused on managing state from 1 area (the view model). The view model is the source of truth for a particular feature and is the one to change the state and react to events in the system. This approach is used in both the BreedsListFeature and the BreedPhotosDisplayFeature. Coordinator acts as the DI manager + controls routing for the main app. 
All of the dependencies in the project are very easily passed in and controlled. I went with a struct based approach for dependency management as it is much more flexible than a protocol oriented approach for dependency management. 


## 3rd Party Libraries

The only library I used was Kingfisher. However is is very cleanly managed and hidden behind the ImageRetrievalClient which comes with a great advantage of not having to build Kingfisher if launching only BreedPhotosDisplayFeature. Kingfisher (ie live) dependency will only be build in the main app target when running the whole app. This is achieved through the separation of the live implementation (ImageRetrievalClientLive)  and the interface (ImageRetrievalClient) into separate libraries. 

## Modularisation

I have went ahead and modularised the app using SPM. We have 3 types of modules. 

1) Feature Modules (BreedListFeature, BreedPhotosDisplayFeature)
2) Dependency Modules (ApiClient, ApiClientLive, ImageRetrievalClient, ImageRetrievalClientLive)
3) UI Components (iOSUIComponents)

In this case I do agree this is very over the top since the project is very small. However this is how I write my projects and I wanted to demonstrate the beauty of such an approach. One great advantage is build time improvements (and as a byproduct faster development/testing cycles for the team), we get a great advantage of being able to run feature modules very quickly and during the build of the whole app we also get an advantage in terms of a build parallelisation.
