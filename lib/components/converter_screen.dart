import 'package:flutter/material.dart';
import 'item_card.dart';
import 'item.dart';

class ConverterScreen extends StatefulWidget {
  @override
  _ConverterScreenState createState() => _ConverterScreenState();
}

class _ConverterScreenState extends State<ConverterScreen> {
  List<Item> items = [Item(), Item()];
  String selectedUnit = '100g';
  double? cheapestPrice;
  double? secondCheapestPrice;

  double? findCheapestItem() {
    double? cheapestPrice;
    for (var item in items) {
      double pricePerUnit = calculatePricePerUnit(
          item.price, item.amount, item.unit, selectedUnit);
      if (cheapestPrice == null || pricePerUnit < cheapestPrice) {
        cheapestPrice = pricePerUnit;
      }
    }
    return cheapestPrice;
  }

  @override
  void initState() {
    super.initState();
    cheapestPrice = findCheapestItem();
  }

  void refreshCheapest() {
    bool allInputsFilled =
        items.every((item) => item.amount != 0 && item.price != 0);

    if (allInputsFilled) {
      double cheapest = double.infinity;
      double secondCheapest = double.infinity;

      for (var item in items) {
        double pricePerUnit = calculatePricePerUnit(
            item.price, item.amount, item.unit, selectedUnit);
        if (pricePerUnit < cheapest) {
          secondCheapest = cheapest;
          cheapest = pricePerUnit;
        } else if (pricePerUnit < secondCheapest) {
          secondCheapest = pricePerUnit;
        }
      }

      setState(() {
        cheapestPrice = cheapest;
        secondCheapestPrice = secondCheapest;
      });
    }
  }

  double calculatePricePerUnit(
      double price, double amount, String unit, String selectedUnit) {
    const kgToG = 1000.0;
    const lbToG = 453.592;
    const gallonToLitre = 3.78541;
    const litreToML = 1000.0;
    const ounceToG = 28.3495;

    double amountInBase;
    switch (unit) {
      case 'kg':
        amountInBase = amount * kgToG;
        break;
      case 'lb':
        amountInBase = amount * lbToG;
        break;
      case 'litres':
        amountInBase = amount * litreToML;
        break;
      case 'ml':
        amountInBase = amount;
        break;
      case 'g':
        amountInBase = amount;
        break;
      case 'ounce':
        amountInBase = amount * ounceToG;
        break;
      case 'gallon':
        amountInBase = amount * gallonToLitre * litreToML;
        break;
      default:
        return 0;
    }

    double priceInBase = price / amountInBase;

    double priceInSelectedUnit;
    if (selectedUnit == '100g') {
      priceInSelectedUnit = priceInBase * 100;
    } else if (selectedUnit == 'kg') {
      priceInSelectedUnit = priceInBase * kgToG;
    } else if (selectedUnit == 'lb') {
      priceInSelectedUnit = priceInBase * lbToG;
    } else if (selectedUnit == 'litre') {
      priceInSelectedUnit = priceInBase * litreToML;
    } else if (selectedUnit == '100ml') {
      priceInSelectedUnit = priceInBase * 100;
    } else if (selectedUnit == 'gallon') {
      priceInSelectedUnit = priceInBase * gallonToLitre * litreToML;
    } else {
      return 0;
    }

    return priceInSelectedUnit;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        title: Text(
          "PennyPinch: Cheapest Price Finder",
          style: TextStyle(color: Colors.grey[800]), // Dark gray color
        ),
        backgroundColor: Color(0xFFF2F3F5), // A contrasting blue color
      ),
      backgroundColor: Color(0xFFF2F3F5), // Main background color
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 16.0),
          child: Column(
            children: [
              Row(
                children: [
                  Text(
                    'Compare price per: ',
                    style: TextStyle(fontSize: 16.0, color: Colors.grey[700]),
                  ),
                  DropdownButton<String>(
                    value: selectedUnit,
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedUnit = newValue!;
                        refreshCheapest();
                      });
                    },
                    items: ['100g', 'lb', 'kg', '100ml', 'litre', 'gallon']
                        .map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                ],
              ),
              SizedBox(height: 20),
              ...items.asMap().entries.map((entry) {
                int index = entry.key;
                Item item = entry.value;

                return ItemCard(
                  item: item,
                  index: index,
                  selectedUnit: selectedUnit,
                  calculatePricePerUnit: calculatePricePerUnit,
                  cheapestPrice: cheapestPrice,
                  secondCheapestPrice: secondCheapestPrice,
                  refreshCheapest: refreshCheapest,
                  onDelete: () {
                    setState(() {
                      items.removeAt(index);
                    });
                  },
                );
              }).toList(),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    items.add(Item());
                  });
                },
                child: Text('Add More'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
