import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ConverterScreen(),
    );
  }
}

class Item {
  double amount = 0;
  double price = 0;
  String unit = 'kg';
}

class ConverterScreen extends StatefulWidget {
  @override
  _ConverterScreenState createState() => _ConverterScreenState();
}

class _ConverterScreenState extends State<ConverterScreen> {
  List<Item> items = [Item(), Item()];
  String selectedUnit = 'Price per 100g';

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
    if (selectedUnit == 'Price per 100g') {
      priceInSelectedUnit = priceInBase * 100;
    } else if (selectedUnit == 'Price per kg') {
      priceInSelectedUnit = priceInBase * kgToG;
    } else if (selectedUnit == 'Price per lb') {
      priceInSelectedUnit = priceInBase * lbToG;
    } else if (selectedUnit == 'Price per litre') {
      priceInSelectedUnit = priceInBase * litreToML;
    } else if (selectedUnit == 'Price per 100ml') {
      priceInSelectedUnit = priceInBase * 100;
    } else if (selectedUnit == 'Price per gallon') {
      priceInSelectedUnit = priceInBase * gallonToLitre * litreToML;
    } else {
      return 0;
    }

    return priceInSelectedUnit;
  }

  @override
  Widget build(BuildContext context) {
    double? cheapestPrice = findCheapestItem();
    return Scaffold(
      appBar: AppBar(title: Text("Multi Converter")),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              DropdownButton<String>(
                value: selectedUnit,
                onChanged: (String? newValue) {
                  setState(() {
                    selectedUnit = newValue!;
                  });
                },
                items: [
                  'Price per 100g',
                  'Price per kg',
                  'Price per lb',
                  'Price per litre',
                  'Price per 100ml',
                  'Price per gallon'
                ].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
              SizedBox(height: 20),
              ...items.asMap().entries.map((entry) {
                int index = entry.key;
                Item item = entry.value;
                double pricePerUnit = calculatePricePerUnit(
                    item.price, item.amount, item.unit, selectedUnit);
                bool allInputsFilled =
                    items.every((item) => item.amount != 0 && item.price != 0);
                bool isCheapest = pricePerUnit == cheapestPrice;

                return Card(
                  color:
                      allInputsFilled && isCheapest ? Colors.green[100] : null,
                  elevation: 4.0,
                  margin: EdgeInsets.symmetric(vertical: 8.0),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                keyboardType: TextInputType.number,
                                onChanged: (value) {
                                  setState(() {
                                    item.amount = double.tryParse(value) ?? 0;
                                  });
                                },
                                decoration:
                                    InputDecoration(labelText: "Amount"),
                              ),
                            ),
                            DropdownButton<String>(
                              value: item.unit,
                              onChanged: (String? newValue) {
                                setState(() {
                                  item.unit = newValue!;
                                });
                              },
                              items: [
                                'g',
                                'kg',
                                'lb',
                                'litres',
                                'ml',
                                'ounce',
                                'gallon'
                              ].map((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: TextField(
                                keyboardType: TextInputType.number,
                                onChanged: (value) {
                                  setState(() {
                                    item.price = double.tryParse(value) ?? 0;
                                  });
                                },
                                decoration: InputDecoration(
                                  labelText: "Price",
                                  prefixText: "\$",
                                ),
                              ),
                            ),
                            if (index >= 2)
                              IconButton(
                                icon: Icon(Icons.delete),
                                onPressed: () {
                                  setState(() {
                                    items.removeAt(index);
                                  });
                                },
                              ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Text(
                            "Price in ${selectedUnit} for ${item.unit}: ${pricePerUnit.isNaN ? '\$0' : pricePerUnit.toStringAsFixed(2)}")
                      ],
                    ),
                  ),
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
              ElevatedButton(
                onPressed: () {
                  double cheapestPrice = double.infinity;
                  String cheapestUnit = '';
                  for (var item in items) {
                    double pricePerUnit = calculatePricePerUnit(
                        item.price, item.amount, item.unit, selectedUnit);
                    if (pricePerUnit < cheapestPrice) {
                      cheapestPrice = pricePerUnit;
                      cheapestUnit = item.unit;
                    }
                  }
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text("Result"),
                        content: Text(
                            "The cheapest option is in $cheapestUnit at $cheapestPrice per $selectedUnit"),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text("Close"),
                          ),
                        ],
                      );
                    },
                  );
                },
                child: Text('Compare'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
