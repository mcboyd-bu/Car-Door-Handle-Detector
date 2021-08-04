# Car Door and Door Handle Detector

Uses images and annotations from the ADE20K Dataset from MIT (see references) to detect car doors and door handles by fine-tuning a pre-trained Mobilenet SSD v2 detector. Once the fine-tuned model is trained, it is then converted to OpenVINO .&trade; format and finally to a blob format for running directly on the OAK-D camera hardware (see references).

## Requirements

- **Matlab R2021a or newer**
  - This version is required for generating the XML annotations using the MATLAB API for XML Processing (MAXP). If you do not want the XML or don't mind using the old (and soon to be removed) Java API for XML Processing (JAXP), an older version of Matlab will also work.
- **ADE20K Dataset**
  - Must request access from the datset/paper authors through their website (see references)

## Files

- `Colab\Roboflow_Deply_Custom_Mobilenet_to_OAK-D.ipynb`
  - Customized version of [this notebook](https://colab.research.google.com/drive/1fPn9WJQp_4dX1JfQNiBImcDwtEk_qa1b)
  - Used to train and test the model, and export to final blob format
- `\Matlab\extractObjects.m`
  - Loads ADE20K data index included with dataset
    - *Assumes ADE20K dataset is extracted into a folder at the same level as this .m file (e.g., `\Matlab\ADE20K_2021_17_01\`)*
  - Extracts list of images containing an object of interest (e.g., car)
  - In each image containing the object of interest, looks for parts (or sub-parts) of interest
  - Outputs JPG images with the parts (and sub-parts) segmented and wrapped in bounding boxes
  - Calls `generatePascalXML` function to generate PascalVOC formatted XML annotations
  - Saves original images and associated annotations in a subfolder (for training)
- `\Matlab\generatePascalXML.m`
  - Called for each image of interest (see list of parameters in the file's comments)
  - Outputs formatted XML file with bounding boxes and classes listed

## Other Resources

- Google Colab notebook to perform initial training