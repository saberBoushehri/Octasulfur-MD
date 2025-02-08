#!/bin/env bash

for img in *.png; do
  convert $img -fuzz 6% -transparent white "transp-$img"
  mv "transp-$img" $img
  convert $img -trim "transp-$img"
  mv "transp-$img" $img
done
