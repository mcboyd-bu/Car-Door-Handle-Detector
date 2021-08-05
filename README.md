# Car Door and Door Handle Detector

Uses images and annotations from the ADE20K Dataset from MIT (see references) to detect car doors and door handles by fine-tuning a pre-trained Mobilenet SSD v2 detector. Once the fine-tuned model is trained, it is then converted to OpenVINO &trade; format and finally to a blob format for running directly on the OAK-D camera hardware.

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
- `Model\v1\frozen_inference_graph_openvino_2021.3_5shave.blob`
  - Final model in blob format for deployment on the OAK-D hardware
- `Model\v1\saved_model.pb`
  - Trained inference graph (before conversion to OpenVINO &trade; and blob formats)

## Example Matlab Code Output

Includes segmentation with bounding boxes and associated annotation in XML format.

**NOTE:** Because the ADE20K dataset is not publicly available, only 1 example is being shown

<details>
  <summary>Click to show XML annotation</summary>

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no" ?>
<annotation>

  <folder>train</folder>

  <filename>ADE_train_00015114.jpg</filename>

  <path>\images\train\ADE_train_00015114.jpg</path>

  <source>
    <database>ADE20K Dataset</database>
    <annotation>ADE20K</annotation>
  </source>

  <size>
    <width>1600</width>
    <height>1200</height>
    <depth>3</depth>
  </size>

  <segmented>0</segmented>

  <object>
    <name>door</name>
    <bndbox>
      <xmin>457</xmin>
      <ymin>228</ymin>
      <xmax>829</xmax>
      <ymax>612</ymax>
    </bndbox>
  </object>

  <object>
    <name>handle</name>
    <bndbox>
      <xmin>652</xmin>
      <ymin>390</ymin>
      <xmax>722</xmax>
      <ymax>427</ymax>
    </bndbox>
  </object>

  <object>
    <name>door</name>
    <bndbox>
      <xmin>734</xmin>
      <ymin>223</ymin>
      <xmax>1084</xmax>
      <ymax>648</ymax>
    </bndbox>
  </object>

  <object>
    <name>handle</name>
    <bndbox>
      <xmin>965</xmin>
      <ymin>425</ymin>
      <xmax>1038</xmax>
      <ymax>457</ymax>
    </bndbox>
  </object>

</annotation>

```

</details>

![Example image with segments and bounding boxes](/images/ADE_train_00015114.jpg "Example image with segments and bounding boxes")

## Model v1 Output

The first version of the model works pretty well. It defineitly needs some work.  

Note there are only 2 classes: `door` and `handle`.  

In future work, we would like to differentiate front vs back door and ensure more handles are detected.  

![Sample image with detections #1](/images/sample1.png "Sample Detections #1")

![Sample image with detections #2](/images/sample2.png "Sample Detections #2")

![Sample image with detections #3](/images/sample3.png "Sample Detections #3")

![Sample image with detections #4](/images/sample4.png "Sample Detections #4")

![Sample image with detections #5](/images/sample5.png "Sample Detections #5")

![Sample image with detections #6](/images/sample6.png "Sample Detections #6")

## References

**Scene Parsing through ADE20K Dataset.** Bolei Zhou, Hang Zhao, Xavier Puig, Sanja Fidler, Adela Barriuso and Antonio Torralba. Computer Vision and Pattern Recognition (CVPR), 2017. [PDF](http://people.csail.mit.edu/bzhou/publication/scene-parse-camera-ready.pdf) [website](https://groups.csail.mit.edu/vision/datasets/ADE20K/)  

**wider2pascal.** Samuel Albanie. [Github](https://github.com/albanie/wider2pascal)
