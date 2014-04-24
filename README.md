A category on ALAsset that returns an image with the correct orientation and any edits (filters, crop etc.) applied.
Useful when you are importing images from a users photo library and they come in the wrong way up or without edits the user thought had been applied. Use it as follows;
    
    ALAsset *asset = 'some ALAsset';
    UIImage *someImage;
    someImage = [asset assetWithOrientationAndEdits:asset];
