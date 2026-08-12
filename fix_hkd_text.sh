#!/bin/bash
sed -i '' 's/coinName: "",/coinName: "HKD",/g' lib/viewmodels/wallet_viewmodel.dart
sed -i '' 's/symbol: "",/symbol: "HKD",/g' lib/viewmodels/wallet_viewmodel.dart
sed -i '' 's/mainSymbol: "",/mainSymbol: "HKD",/g' lib/viewmodels/wallet_viewmodel.dart
