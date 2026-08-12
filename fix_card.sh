#!/bin/bash
awk 'NR>=2186 && NR<=2204 {next} {print}' lib/views/homes/CardScreen.dart > temp.dart
sed -i '' '2185 a\
                            final result = await _cardService.confirmPhysicalCardDelivery(_currentCardDetails!.id);\
                            if (result["status"] == "success") {\
                              if (mounted) {\
                                ScaffoldMessenger.of(context).showSnackBar(\
                                  SnackBar(content: Text(AppLocalizations.of(context)!.cardDeliveryConfirmed)),\
                                );\
                              }\
                              setState(() {\
                                _optimisticHiddenMailingTabs.add(_currentCardDetails!.id);\
                              });\
                            }\
' temp.dart
mv temp.dart lib/views/homes/CardScreen.dart
