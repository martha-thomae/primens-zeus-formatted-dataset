# primens-zeus-formatted-dataset
Processing of PriMENS dataset (from University of Alicante) to make it compliant to train a zeus model. 

## PriMens Dataset

The **PriMens** dataset is a synthetic dataset. The original dataset, as provided by David Rizo (University of Alicante), consists of agnostic and semantic (explicitly, \*\*mens) encodings of staff regions. From these encodings, especifically from the \*\*mens encoding, an image can be obtained through renderization.

# PriMens for Zeus

To make the dataset suitable for [Zeus](https://github.com/omniomr/zeus), we need:
1. To obtain digital images for each staff region
2. Subtokenize the Humdrum \*\*mens of each staff region into basic units---i.e., divide it into characters (group of characters) that indicate the note shape, pitch, accidental, ligature start/end of a music symbol---so that the model has less information to learn.

All other information (like the agnostic encoding) is irrelevant for this particular use case, and has been removed from the repository. 

### Point \# 1: Generating staff-region images. 

To generate the JPEG images of each staff region, we used a combination of _Verovio_ and _ImageMagick_.

In this dataset, the staff regions are encoded in Humdrum \*\*mens. We used Verovio, rendering library with capacity to render Humdrum, to generate SVGs of each staff region; these SVGs were then converted into JPEGs through ImageMagick. 

For information about Verovio's [installation](https://book.verovio.org/installing-or-building-from-sources/command-line.html), input formats (including [Humdrum](https://book.verovio.org/toolkit-reference/input-formats.html#humdrum)), and [layout options](https://book.verovio.org/advanced-topics/layout-options.html?q=line%20break), consult its [**Reference Book**](https://book.verovio.org). The Humdrum \*\*mens files in the dataset were converted into SVGs using the bash commands:

```bash
for f in ./*/*/*/*.mns; do
    out="SVG/${f#./}"
    out="${out%.mns}.svg"

    mkdir -p "$(dirname "$out")"

    verovio "$f" --breaks none -o "$out"
done
```

The SVG files were converted to JPEG using _ImageMagick_ through the following bash commands, which include a bit of cropping at top and bottom of the image:

```bash
for f in ./SVG/*/*/*/*.svg; do
    out="./${f#./SVG/}"
    out="${out%.svg}.jpg"

    mkdir -p "$(dirname "$out")"

    magick -background white -density 300 "$f" \
        -alpha remove -alpha off \
        -gravity north -chop 0x100 \
        -gravity south -chop 0x350 \
        "$out"
done
```

### Point 2: Subtokenization

[Section still to be written]
