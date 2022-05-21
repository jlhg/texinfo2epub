#!/bin/bash
set -e

checkcmd() {
  if ! $(hash $1 2>/dev/null); then
    echo "$1 command is required."
    exit 1
  fi
}

checkcmd makeinfo
checkcmd xsltproc
checkcmd zip

INPUT_FILE=$1
OUTPUT_FILE=$2

if [[ -z $INPUT_FILE ]] || [[ -z $OUTPUT_FILE ]]; then
  echo ""
  echo "Usage:"
  echo "  ./texinfo2epub.sh input.texi output.epub"
  echo ""
  exit
fi

if [[ ! -f $INPUT_FILE ]]; then
  echo "File ${INPUT_FILE} does not exist."
  exit 1
fi

create_tmp_dir() {
  local tdir
  case "$(uname -s)" in
    Darwin*)
      tdir=$(mktemp -d $PWD/temp-texinfo2epub-XXXX);;
    *)
      tdir=$(mktemp -d -p $PWD -t temp-texinfo2epub-XXXX);;
  esac

  echo ${tdir}
}

INPUT_FILE_PATH=$(cd $(dirname $INPUT_FILE) && pwd)/$(basename $INPUT_FILE)
OUTPUT_FILE_PATH=$(cd $(dirname $OUTPUT_FILE) && pwd)/$(basename $OUTPUT_FILE)
SCRIPT_DIR=$(cd $(dirname $0) && pwd)
EPUB_XSL=$SCRIPT_DIR/docbook-xsl-1.79.2/epub/docbook.xsl
TMP_DIR=$(create_tmp_dir)
trap "rm -rf $TMP_DIR" EXIT

cd $TMP_DIR
makeinfo --docbook $INPUT_FILE_PATH -o out.xml
xsltproc $EPUB_XSL out.xml
echo -n "application/epub+zip" > mimetype
zip -0Xq $OUTPUT_FILE_PATH mimetype
$SCRIPT_DIR/copy-media.py OEBPS/content.opf $(dirname $INPUT_FILE_PATH)
zip -Xr9D $OUTPUT_FILE_PATH META-INF OEBPS
