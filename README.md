# primens-zeus-formatted-dataset
Processing of PriMENS dataset (from University of Alicante) to make it compliant to train a zeus model. 

## PriMens Dataset

The **PriMens** dataset is a synthetic dataset. The original dataset, as provided by David Rizo (University of Alicante), consists of agnostic and semantic (explicitly, \*\*mens) encodings of staff regions. From these encodings, especifically from the \*\*mens encoding, an image can be obtained through renderization.

## PriMens for Zeus

To make the dataset suitable for [Zeus](https://github.com/omniomr/zeus), we need:
1. To obtain digital images for each staff region
2. Subtokenize the Humdrum \*\*mens of each staff region into basic units---i.e., divide it into characters (group of characters) that indicate the note shape, pitch, accidental, ligature start/end of a music symbol---so that the model has less information to learn.

All other information (like the agnostic encoding) is irrelevant for this particular use case, and has been removed from the repository. 

### Point \# 1: Generating staff-region images. 

To generate the JPEG images of each staff region, we used a combination of _Verovio_ and _ImageMagick_.

In this dataset, the staff regions are encoded in Humdrum \*\*mens. We used _Verovio_, rendering library with capacity to render Humdrum, to generate SVGs of each staff region; these SVGs were then converted into JPEGs through _ImageMagick_. 

For information about Verovio's [installation](https://book.verovio.org/installing-or-building-from-sources/command-line.html), input formats (including [Humdrum](https://book.verovio.org/toolkit-reference/input-formats.html#humdrum)), and [layout options](https://book.verovio.org/advanced-topics/layout-options.html?q=line%20break), consult its [**Reference Book**](https://book.verovio.org). 

The conversion from Humdrum \*\*mens to SVG to JPEG is given by the following bash commands. The generated JPEGs---which include a bit of cropping at the top and bottom to provide a nice staff region---are stored in the same folder as the original \*\*mens encodings (`.mns` files):

```bash
for f in ./*/*/*/*.mns; do 
    output_jpg="${f%.mns}.jpg"
    
    echo "Converting: $f -> $output_jpg"
    
    verovio "$f" --breaks none -o - | magick -density 300 - -background white -alpha remove -alpha off -gravity north -chop 0x100 -gravity south -chop 0x350 "$output_jpg"
done
```

### Point 2: Subtokenization

[Section still to be written]
