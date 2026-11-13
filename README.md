# primens-zeus-formatted-dataset
Processing of PriMENS dataset (from University of Alicante) to make it compliant to train a zeus model. 

## PriMens Dataset

The **PriMens** dataset is a synthetic dataset. The original dataset, as provided by David Rizo (University of Alicante), consists of agnostic and semantic (explicitly, \*\*mens) encodings of staff regions. From these encodings, especifically from the \*\*mens encoding, an image can be obtained through renderization.

## PriMens for Zeus

To make the dataset suitable for [Zeus](https://github.com/omniomr/zeus), we need:
1. To obtain digital images for each staff region
2. Subtokenize the Humdrum \*\*mens of each staff region into basic units—i.e., divide it into characters (group of characters) that indicate the note shape, pitch, accidental, ligature start/end of a music symbol—so that the model has less information to learn.

All other information (like the agnostic encoding) is irrelevant for this particular use case, and has been removed from the repository. 

### Point 1: Generating staff-region images. 

To generate the JPEG images of each staff region, we used a combination of _Verovio_ and _ImageMagick_.

In this dataset, the staff regions are encoded in Humdrum \*\*mens. We used _Verovio_, rendering library with capacity to render Humdrum, to generate SVGs of each staff region; these SVGs were then converted into JPEGs through _ImageMagick_. 

For information about Verovio's [installation](https://book.verovio.org/installing-or-building-from-sources/command-line.html), input formats (including [Humdrum](https://book.verovio.org/toolkit-reference/input-formats.html#humdrum)), and [layout options](https://book.verovio.org/advanced-topics/layout-options.html?q=line%20break), consult its [**Reference Book**](https://book.verovio.org). 

The conversion from Humdrum \*\*mens to SVG to JPEG is given by the following bash commands. The generated JPEGs—which include a bit of cropping at the top and bottom to provide a nice staff region—are stored in the same folder as the original \*\*mens encodings (`.mns` files):

```bash
for f in ./*/*/*/*.mns; do 
    output_jpg="${f%.mns}.jpg"
    
    echo "Converting: $f -> $output_jpg"
    
    verovio "$f" --breaks none -o - | magick -density 300 - -background white -alpha remove -alpha off -gravity north -chop 0x100 -gravity south -chop 0x350 "$output_jpg"
done
```

### Point 2: Sub-tokenization of the Humdrum **mens files

As explained in the introduction, the sequence of music symbols of each staff region is given by a Humdrum \*\*mens file. These files were cleaned up to remove irrelevant information from them (e.g., information that came from the original modern transcription \*\*kern files) and then subtokenized so that the OMR model has less information to learn (i.e., a reduced vocabulary). The following two sections describe the clean-up and sub-tokenization processes.

#### A) Cleaning up the **mens files

There is irrelevant information in the \*\*mens files that needs clean up. This includes any character or token that:
- is not related to mensural notation (e.g., it comes from the original \*\*kern files like time signatures, tempo markings, key identification, or it represents a syntactic element in Humdrum like comments, end of the spine markings, or null tokens), or
- is related to the interpretation of rhythmic mensural values (i.e., the `i` and `p` characters for 'imperfect' and 'perfect' values of notes)
- or is empty (e.g., an empty key signature `*k[]`).

We ran the following bash script to remove the irrelevant pieces of information from the **mens files.

```bash
#!/bin/bash

find ./dataset -type f -name "*.mns" -exec sed -i '' \
    -e '/^\*.:/d' \
    -e '/^\*-/d' \
    -e '/\*M/d' \
    -e '/^\.$/d' \
    -e '/^!/d' \
    -e '/^\*k\[\]/d' \
    -e 's/[ip]//g' \
    -e 's/^\*custos:\(.*\)$/\*custos\1/' \
    {} +
```

The following table shows line-by-line the edits done by this bash script:

| Command | What it does |
| ------- | ------------ |
| `'/^\*.:/d'` | Deletes lines beginning with `*`, followed by any character, followed by `:`. Meant to delete `*F:` (key of F Major) and the like |
| `'/^\*-/d'` | Deletes lines beginning with `*-` (end of spine token) |
| `'/\*M/d'` | Deletes any time containing `*M`. It is meant to delete 'time signatures' (e.g., `M4/4`) and 'tempo' (e.g., `MM72`) markings that come from the original **kern files |
| `'/^\.$/d'` | Deletes lines containing a single `.` (null token, meant for alignment with other voices or text) |
| `'/^!/d'` | Deletes comment lines (i.e., lines starting with `!`) |
| `'/^\*k\[\]/d'` | Deletes empty key signatures (i.e., `*k[]`) |
| `'s/[ip]//g'` | Removes the durational quality of the notes (i.e., removes every lowercase `i` and `p` character from the line) |
| `'s/^\*custos:\(.*\)$/\*custos\1/'` | Edit custodes, remove the `:` preceding the pitch of the custos |


#### B) Sub-tokenization of cleaned-up **mens files

The _\*\*mens_ was sub-tokenized to separate the different type of information of a \*\*mens token. For example, `[s~g#` is sub-tokenized into `[ s ~ g #`, to account for the `[` ligature start, the semibrevis note shape `s`, the coloration of the note `~`, its pitch `g`, and its accidental `#`. This reduces the vocabulary that the OMR model needs to deal with. 

The sub-tokenization was done through the following Python script [tokenizer.py](https://github.com/martha-thomae/primens-zeus-formatted-dataset/blob/main/tokenizer.py).[^1]

[^1]: Notice that this tokenizer script differentiates between two types of ligatures: oblique ones marked by `<` and `>`, and recta ones marked by `[` and `]`.

