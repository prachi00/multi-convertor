import 'package:flutter/material.dart';
import 'item.dart';

class ItemCard extends StatefulWidget {
  final Item item;
  final int index;
  final String selectedUnit;
  final Function(double, double, String, String) calculatePricePerUnit;
  final Function onDelete;
  final double? cheapestPrice;
  final Function refreshCheapest;
  final double? secondCheapestPrice;

  ItemCard({
    required this.item,
    required this.index,
    required this.selectedUnit,
    required this.calculatePricePerUnit,
    required this.onDelete,
    required this.cheapestPrice,
    required this.refreshCheapest,
    required this.secondCheapestPrice,
  });

  @override
  _ItemCardState createState() => _ItemCardState();
}

class _ItemCardState extends State<ItemCard> {
  @override
  Widget build(BuildContext context) {
    double pricePerUnit = widget.calculatePricePerUnit(widget.item.price,
        widget.item.amount, widget.item.unit, widget.selectedUnit);
    bool isCheapest = widget.cheapestPrice == pricePerUnit;
    List<String> units = [];
    if (['100g', 'lb', 'kg'].contains(widget.selectedUnit)) {
      units = ['g', 'lb', 'kg'];
    } else if (['100ml', 'litre', 'gallon'].contains(widget.selectedUnit)) {
      units = ['ml', 'ounce', 'litres', 'gallon'];
    }

    // Reset to a default unit if the current unit is not in the list.
    if (!units.contains(widget.item.unit)) {
      setState(() {
        widget.item.unit = units[0];
      });
    }

    return Card(
      color: isCheapest ? Colors.green[100] : Colors.white,
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      "Select Unit: ",
                      style: TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                    DropdownButton<String>(
                      value: widget.item.unit,
                      onChanged: (String? newValue) {
                        setState(() {
                          widget.item.unit = newValue!;
                        });
                        widget.refreshCheapest();
                      },
                      items: units.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: TextField(
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          setState(() {
                            widget.item.amount = double.tryParse(value) ?? 0;
                          });
                          widget.refreshCheapest();
                        },
                        decoration: InputDecoration(
                          labelText: "Amount",
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: TextField(
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          setState(() {
                            widget.item.price = double.tryParse(value) ?? 0;
                          });
                          widget.refreshCheapest();
                        },
                        decoration: InputDecoration(
                          labelText: "Price",
                          prefixText: "\$",
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    if (widget.index >= 2)
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.grey[500]),
                        onPressed: () {
                          widget.onDelete();
                        },
                      ),
                  ],
                ),
                SizedBox(height: 12),
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: "Price per ${widget.selectedUnit}: ",
                        style: TextStyle(color: Colors.black, fontSize: 14),
                      ),
                      TextSpan(
                        text: (pricePerUnit.isNaN || pricePerUnit == 0)
                            ? "\$0.00"
                            : "\$" + pricePerUnit.toStringAsFixed(2),
                        style: TextStyle(color: Colors.black, fontSize: 18),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
          if (isCheapest)
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.greenAccent[700],
                  borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(16),
                      topRight: Radius.circular(8)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      spreadRadius: 1,
                      blurRadius: 4,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Text(
                  widget.secondCheapestPrice != null
                      ? '\$${(widget.secondCheapestPrice! - widget.cheapestPrice!).toStringAsFixed(2)} Cheaper!'
                      : 'Cheapest!',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
