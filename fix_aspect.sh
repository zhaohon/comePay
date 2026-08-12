#!/bin/bash
find lib/ -type f -name "*.dart" -print0 | xargs -0 sed -i '' 's/4999 \/ 2880/10788 \/ 6216/g'
find lib/ -type f -name "*.dart" -print0 | xargs -0 sed -i '' 's/2880 \/ 4999/6216 \/ 10788/g'
find lib/ -type f -name "*.dart" -print0 | xargs -0 sed -i '' 's/1280 \/ 813/10788 \/ 6216/g'
