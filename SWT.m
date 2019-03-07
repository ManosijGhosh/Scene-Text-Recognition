function SW = SWT(matrix)

  distanceImage = bwdist(~matrix);
skeletonImage = bwmorph(matrix, 'thin', inf);

strokeWidthValues = distanceImage(skeletonImage);
SW = var(strokeWidthValues)/(mean(strokeWidthValues)^2);





end