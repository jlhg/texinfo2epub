#!/bin/bash
./texinfo2epub.sh test/sample.texi test/sample.epub

if [ $? -eq 0 ]; then
  echo "Test success."
else
  echo "Test failed."
fi
