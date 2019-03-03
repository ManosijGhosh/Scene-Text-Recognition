function [CCs,CCstats,Features] = GetTextGroupFeatures(StableBinImages)

 %FEATURE VECTOR = [ SOLIDITY EULER ECCENTRICITY EXTENT SVT eHOG]
  cc_no = 1;
  [row,col,~] = size(StableBinImages);
  palate = zeros(row,col); %Palate is a binarized image that only contains one component for checking
  for i = 1:size(StableBinImages,3)
      CC_img = bwconncomp(StableBinImages(:,:,i));
      CCs(i) = CC_img;
      stats = regionprops(CC_img, 'BoundingBox', 'Eccentricity','Solidity', 'Extent', 'Euler');
      for comp = 1:CC_img.NumObjects
          CCstats(cc_no) = stats(comp);

                palate(CC_img.PixelIdxList{comp}) = 1;
                
                 Features(cc_no,:) = [ stats(comp).Solidity stats(comp).EulerNumber stats(comp).Eccentricity stats(comp).Extent SWT(palate) eHOG(palate) ];
                palate(:,:) = 0;
          cc_no = cc_no + 1;
      end
  end

end